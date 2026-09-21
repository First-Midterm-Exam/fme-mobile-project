import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:fme_mobile_project/core/network/api_client.dart';
import 'package:fme_mobile_project/core/storage/preferencias_storage.dart';
import 'package:fme_mobile_project/features/asistente/servicios/archivos_reporte.dart';
import 'package:fme_mobile_project/features/asistente/servicios/lector_voz.dart';
import 'package:fme_mobile_project/features/asistente/servicios/reconocedor_voz.dart';
import 'package:fme_mobile_project/features/documento/camara_documentos.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

http.Response respuestaJson(int codigo, Object cuerpo) =>
    http.Response.bytes(utf8.encode(jsonEncode(cuerpo)), codigo);

ApiClient apiDePrueba(MockClientHandler manejador) => ApiClient(
  baseUrl: Uri.parse('http://servidor.test/api'),
  httpClient: MockClient(manejador),
  leerToken: () => 'token',
);

Future<PreferenciasStorage> preferenciasDePrueba({int? appraisalId}) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({'appraisal_id': ?appraisalId});
  return PreferenciasStorage.crear();
}

class CamaraFalsa implements CamaraDocumentos {
  CamaraFalsa({
    this.permiso = ResultadoPermiso.concedido,
    this.foto,
    this.error,
  });

  ResultadoPermiso permiso;
  Uint8List? foto;
  ErrorCamara? error;
  Uint8List? fotoPendiente;
  int aperturasDeAjustes = 0;

  @override
  Future<ResultadoPermiso> solicitarPermiso() async => permiso;

  @override
  Future<Uint8List?> tomarFoto() async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return foto;
  }

  @override
  Future<Uint8List?> recuperarFotoPendiente() async => fotoPendiente;

  @override
  Future<void> abrirAjustes() async => aperturasDeAjustes++;
}

class ReconocedorFalso implements ReconocedorVoz {
  ResultadoPermiso permiso = ResultadoPermiso.concedido;
  bool disponible = true;
  bool escuchando = false;
  int detenciones = 0;
  void Function(String texto, {required bool esFinal})? _alReconocer;
  ValueChanged<String>? _alFallar;
  VoidCallback? _alTerminar;

  void decir(String texto, {bool esFinal = false}) =>
      _alReconocer?.call(texto, esFinal: esFinal);

  void fallar(String codigo) => _alFallar?.call(codigo);

  void terminar() => _alTerminar?.call();

  @override
  Future<ResultadoPermiso> solicitarPermiso() async => permiso;

  @override
  Future<bool> inicializar() async => disponible;

  @override
  Future<void> escuchar({
    required void Function(String texto, {required bool esFinal}) alReconocer,
    required ValueChanged<double> alCambiarNivel,
    required ValueChanged<String> alFallar,
    required VoidCallback alTerminar,
  }) async {
    escuchando = true;
    _alReconocer = alReconocer;
    _alFallar = alFallar;
    _alTerminar = alTerminar;
  }

  @override
  Future<void> detener() async {
    detenciones++;
    escuchando = false;
  }

  @override
  Future<void> cancelar() async => escuchando = false;
}

class LectorFalso implements LectorVoz {
  final List<String> leidos = [];
  VoidCallback? _alTerminar;

  void terminarLectura() => _alTerminar?.call();

  @override
  Future<void> leer(String texto, {required VoidCallback alTerminar}) async {
    leidos.add(texto);
    _alTerminar = alTerminar;
  }

  @override
  Future<void> detener() async {
    final alTerminar = _alTerminar;
    _alTerminar = null;
    alTerminar?.call();
  }
}

class ArchivosFalsos implements ArchivosReporte {
  final Map<String, Uint8List> guardados = {};
  final List<String> abiertos = [];
  final List<String> textosCompartidos = [];
  ResultadoApertura resultadoApertura = ResultadoApertura.abierto;

  @override
  Future<String> guardar(String nombre, Uint8List bytes) async {
    guardados[nombre] = bytes;
    return nombre;
  }

  @override
  Future<ResultadoApertura> abrir(String ruta, String tipoMime) async {
    abiertos.add(ruta);
    return resultadoApertura;
  }

  @override
  Future<void> compartirArchivo(String ruta, String tipoMime) async {}

  @override
  Future<void> compartirTexto(String texto, {required String asunto}) async =>
      textosCompartidos.add(texto);

  @override
  Future<void> limpiar() async => guardados.clear();
}
