import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../core/permisos/permisos.dart';
import '../../data/models/appraisal.dart';
import '../../data/models/respuesta_asistente.dart';
import '../../data/repositories/asistente_repository.dart';
import 'servicios/archivos_reporte.dart';
import 'servicios/lector_voz.dart';
import 'servicios/reconocedor_voz.dart';

enum EstadoAsistente { inactivo, escuchando, procesando, respondiendo }

enum AccesoMicrofono {
  sinSolicitar,
  concedido,
  denegado,
  bloqueado,
  noDisponible,
}

enum EstadoArchivo { pendiente, descargando, listo, fallido }

class Intercambio {
  Intercambio({
    required this.id,
    required this.pregunta,
    required this.appraisal,
    required this.fecha,
  });

  final int id;
  final String pregunta;
  final String appraisal;
  final DateTime fecha;
  RespuestaAsistente? respuesta;
  ApiException? error;
  EstadoArchivo estadoArchivo = EstadoArchivo.pendiente;
  String? rutaArchivo;
  String? avisoArchivo;

  bool get enCurso => respuesta == null && error == null;
}

class AsistenteController extends ChangeNotifier {
  AsistenteController({
    required AsistenteRepository repositorio,
    required ReconocedorVoz reconocedor,
    required LectorVoz lector,
    required ArchivosReporte archivos,
    required Appraisal? Function() appraisalActivo,
    DateTime Function()? reloj,
  }) : _repositorio = repositorio,
       _reconocedor = reconocedor,
       _lector = lector,
       _archivos = archivos,
       _appraisalActivo = appraisalActivo,
       _reloj = reloj ?? DateTime.now;

  static const esperaPorDefecto = Duration(seconds: 30);

  static const preguntasSugeridas = [
    '¿Qué nos falta para estar listos?',
    'Dame los gaps críticos',
    '¿Qué acciones están vencidas?',
    '¿Cómo va el cumplimiento por área?',
    '¿Mejoramos esta semana?',
    'Genera el reporte de gaps críticos en PDF',
    'Exporta las acciones vencidas a Excel',
  ];

  final AsistenteRepository _repositorio;
  final ReconocedorVoz _reconocedor;
  final LectorVoz _lector;
  final ArchivosReporte _archivos;
  final Appraisal? Function() _appraisalActivo;
  final DateTime Function() _reloj;

  final List<Intercambio> _intercambios = [];
  EstadoAsistente _estado = EstadoAsistente.inactivo;
  AccesoMicrofono _microfono = AccesoMicrofono.sinSolicitar;
  String _transcripcion = '';
  double _nivelSonido = 0;
  String? _aviso;
  DateTime? _bloqueadoHasta;
  Timer? _temporizador;
  int _siguienteId = 0;
  bool _descartado = false;

  List<Intercambio> get intercambios => List.unmodifiable(_intercambios);
  EstadoAsistente get estado => _estado;
  AccesoMicrofono get microfono => _microfono;
  String get transcripcion => _transcripcion;
  double get nivelSonido => _nivelSonido;
  String? get aviso => _aviso;
  bool get hayAppraisal => _appraisalActivo() != null;

  int get segundosDeEspera {
    final hasta = _bloqueadoHasta;
    if (hasta == null) {
      return 0;
    }
    final restante = hasta.difference(_reloj());
    return restante.isNegative ? 0 : (restante.inMilliseconds / 1000).ceil();
  }

  bool get estaBloqueado => segundosDeEspera > 0;

  bool get puedePreguntar =>
      hayAppraisal &&
      !estaBloqueado &&
      _estado != EstadoAsistente.procesando &&
      _estado != EstadoAsistente.escuchando;

  bool get microfonoHabilitado =>
      hayAppraisal &&
      !estaBloqueado &&
      _estado != EstadoAsistente.procesando &&
      _microfono != AccesoMicrofono.noDisponible;

  Future<void> alternarMicrofono() async {
    if (_estado == EstadoAsistente.escuchando) {
      await _reconocedor.detener();
      return;
    }
    if (!microfonoHabilitado) {
      return;
    }
    if (_estado == EstadoAsistente.respondiendo) {
      await detenerLectura();
    }
    final permiso = await _reconocedor.solicitarPermiso();
    if (permiso != ResultadoPermiso.concedido) {
      _microfono = permiso == ResultadoPermiso.denegadoPermanente
          ? AccesoMicrofono.bloqueado
          : AccesoMicrofono.denegado;
      _notificar();
      return;
    }
    if (!await _reconocedor.inicializar()) {
      _microfono = AccesoMicrofono.noDisponible;
      _notificar();
      return;
    }
    _microfono = AccesoMicrofono.concedido;
    _estado = EstadoAsistente.escuchando;
    _transcripcion = '';
    _nivelSonido = 0;
    _aviso = null;
    _notificar();
    await _reconocedor.escuchar(
      alReconocer: _alReconocer,
      alCambiarNivel: _alCambiarNivel,
      alFallar: _alFallarReconocimiento,
      alTerminar: _alTerminarEscucha,
    );
  }

  Future<void> preguntar(String pregunta) async {
    final texto = pregunta.trim();
    final appraisal = _appraisalActivo();
    if (texto.isEmpty || appraisal == null || estaBloqueado) {
      return;
    }
    if (_estado == EstadoAsistente.procesando) {
      return;
    }
    final anterior = _estado;
    final intercambio = Intercambio(
      id: _siguienteId++,
      pregunta: texto,
      appraisal: appraisal.nombre,
      fecha: _reloj(),
    );
    _intercambios.add(intercambio);
    _estado = EstadoAsistente.procesando;
    _transcripcion = '';
    _aviso = null;
    _notificar();

    if (anterior == EstadoAsistente.respondiendo) {
      await _lector.detener();
    } else if (anterior == EstadoAsistente.escuchando) {
      await _reconocedor.cancelar();
    }
    await _consultar(intercambio, appraisal.id);
  }

  Future<void> reintentar(Intercambio intercambio) async {
    final appraisal = _appraisalActivo();
    if (intercambio.error == null || appraisal == null || !puedePreguntar) {
      return;
    }
    if (_estado == EstadoAsistente.respondiendo) {
      await _lector.detener();
    }
    intercambio.error = null;
    _estado = EstadoAsistente.procesando;
    _notificar();
    await _consultar(intercambio, appraisal.id);
  }

  Future<void> detenerLectura() async {
    await _lector.detener();
    if (_estado == EstadoAsistente.respondiendo) {
      _estado = EstadoAsistente.inactivo;
      _notificar();
    }
  }

  Future<void> abrirAjustes() => abrirAjustesDeLaApp();

  Future<void> abrirArchivo(Intercambio intercambio) async {
    final archivo = intercambio.respuesta?.archivo;
    final ruta = await _asegurarArchivo(intercambio);
    if (archivo == null || ruta == null) {
      return;
    }
    final resultado = await _archivos.abrir(ruta, archivo.formato.tipoMime);
    intercambio.avisoArchivo = switch (resultado) {
      ResultadoApertura.abierto => null,
      ResultadoApertura.sinAplicacion =>
        'No hay una aplicación para abrir archivos '
            '${archivo.formato.etiqueta} en este teléfono. Usa "Guardar" '
            'para enviarlo a otra app.',
      ResultadoApertura.fallido => 'No se pudo abrir el archivo.',
    };
    _notificar();
  }

  Future<void> compartirArchivo(Intercambio intercambio) async {
    final archivo = intercambio.respuesta?.archivo;
    final ruta = await _asegurarArchivo(intercambio);
    if (archivo == null || ruta == null) {
      return;
    }
    await _archivos.compartirArchivo(ruta, archivo.formato.tipoMime);
  }

  Future<void> compartirReporte(Intercambio intercambio) async {
    final respuesta = intercambio.respuesta;
    if (respuesta == null) {
      return;
    }
    final texto = respuesta.reporteMarkdown.isEmpty
        ? respuesta.resumenVoz
        : respuesta.reporteMarkdown;
    await _archivos.compartirTexto(
      texto,
      asunto: 'Reporte de preparación · ${intercambio.appraisal}',
    );
  }

  Future<void> _consultar(Intercambio intercambio, int appraisalId) async {
    try {
      final respuesta = await _repositorio.consultar(
        appraisalId: appraisalId,
        pregunta: intercambio.pregunta,
      );
      intercambio.respuesta = respuesta;
      if (respuesta.resumenVoz.isEmpty || _descartado) {
        _estado = EstadoAsistente.inactivo;
        _notificar();
        return;
      }
      _estado = EstadoAsistente.respondiendo;
      _notificar();
      await _lector.leer(respuesta.resumenVoz, alTerminar: _alTerminarLectura);
    } on ApiException catch (error) {
      intercambio.error = error;
      _estado = EstadoAsistente.inactivo;
      if (error.tipo == TipoErrorApi.demasiadasSolicitudes) {
        _bloquear(error.reintentarEn ?? esperaPorDefecto);
      }
      _notificar();
    }
  }

  Future<String?> _asegurarArchivo(Intercambio intercambio) async {
    final archivo = intercambio.respuesta?.archivo;
    if (archivo == null ||
        intercambio.estadoArchivo == EstadoArchivo.descargando) {
      return null;
    }
    final existente = intercambio.rutaArchivo;
    if (existente != null && File(existente).existsSync()) {
      return existente;
    }
    intercambio
      ..estadoArchivo = EstadoArchivo.descargando
      ..avisoArchivo = null;
    _notificar();
    try {
      final bytes = await _repositorio.descargarArchivo(archivo);
      final ruta = await _archivos.guardar(archivo.nombre, bytes);
      intercambio
        ..rutaArchivo = ruta
        ..estadoArchivo = EstadoArchivo.listo;
      _notificar();
      return ruta;
    } on ApiException catch (error) {
      intercambio
        ..estadoArchivo = EstadoArchivo.fallido
        ..avisoArchivo = error.mensaje;
    } on FileSystemException {
      intercambio
        ..estadoArchivo = EstadoArchivo.fallido
        ..avisoArchivo = 'No se pudo guardar el archivo en el teléfono.';
    }
    _notificar();
    return null;
  }

  void _alReconocer(String texto, {required bool esFinal}) {
    if (_estado != EstadoAsistente.escuchando) {
      return;
    }
    _transcripcion = texto;
    if (esFinal) {
      _enviarTranscripcion();
    } else {
      _notificar();
    }
  }

  void _alCambiarNivel(double nivel) {
    if (_estado == EstadoAsistente.escuchando) {
      _nivelSonido = ((nivel + 2) / 12).clamp(0, 1);
      _notificar();
    }
  }

  void _alTerminarEscucha() {
    if (_estado == EstadoAsistente.escuchando) {
      _enviarTranscripcion();
    }
  }

  void _enviarTranscripcion() {
    final texto = _transcripcion.trim();
    if (texto.isEmpty) {
      _estado = EstadoAsistente.inactivo;
      _aviso = 'No te escuché. Toca el micrófono e inténtalo de nuevo.';
      _notificar();
      return;
    }
    _estado = EstadoAsistente.inactivo;
    unawaited(preguntar(texto));
  }

  void _alFallarReconocimiento(String codigo) {
    if (_estado != EstadoAsistente.escuchando) {
      return;
    }
    _estado = EstadoAsistente.inactivo;
    _transcripcion = '';
    _aviso = switch (codigo) {
      'error_no_match' || 'error_speech_timeout' =>
        'No te escuché bien. Toca el micrófono e inténtalo de nuevo.',
      'error_network' || 'error_network_timeout' || 'error_server' =>
        'El reconocimiento de voz necesita conexión a internet.',
      'error_busy' ||
      'error_audio' => 'El micrófono está ocupado por otra aplicación.',
      'error_permission' || 'error_insufficient_permissions' =>
        'La app no tiene permiso para usar el micrófono.',
      _ => 'No se pudo usar el reconocimiento de voz. Inténtalo de nuevo.',
    };
    _notificar();
  }

  void _alTerminarLectura() {
    if (_estado == EstadoAsistente.respondiendo) {
      _estado = EstadoAsistente.inactivo;
      _notificar();
    }
  }

  void _bloquear(Duration espera) {
    _bloqueadoHasta = _reloj().add(espera);
    _temporizador?.cancel();
    _temporizador = Timer.periodic(const Duration(seconds: 1), (temporizador) {
      if (!estaBloqueado) {
        temporizador.cancel();
        _bloqueadoHasta = null;
      }
      _notificar();
    });
  }

  void _notificar() {
    if (!_descartado) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _temporizador?.cancel();
    unawaited(_reconocedor.cancelar());
    unawaited(_lector.detener());
    unawaited(_archivos.limpiar());
    super.dispose();
  }
}
