import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/revision_formato.dart';
import '../../data/repositories/documento_repository.dart';
import '../../shared/formatos.dart';
import 'camara_documentos.dart';

enum PasoDocumento {
  inicio,
  permisoDenegado,
  vistaPrevia,
  analizando,
  resultado,
}

/// Flujo de la pestaña "Documento": foto, vista previa, envío y resultado.
class DocumentoController extends ChangeNotifier {
  DocumentoController({
    required DocumentoRepository repositorio,
    required CamaraDocumentos camara,
  }) : _repositorio = repositorio,
       _camara = camara;

  final DocumentoRepository _repositorio;
  final CamaraDocumentos _camara;

  PasoDocumento _paso = PasoDocumento.inicio;
  Uint8List? _foto;
  RevisionFormato? _resultado;
  String? _aviso;
  bool _avisoReintentable = false;
  bool _permisoPermanente = false;
  bool _abriendoCamara = false;
  bool _descartado = false;

  PasoDocumento get paso => _paso;
  Uint8List? get foto => _foto;
  RevisionFormato? get resultado => _resultado;

  /// Mensaje de error o advertencia del paso actual.
  String? get aviso => _aviso;
  bool get avisoReintentable => _avisoReintentable;
  bool get permisoPermanente => _permisoPermanente;
  bool get abriendoCamara => _abriendoCamara;

  bool get fotoDemasiadoGrande =>
      (_foto?.length ?? 0) > DocumentoRepository.tamanoMaximoBytes;

  bool get puedeEnviar =>
      _paso == PasoDocumento.vistaPrevia &&
      _foto != null &&
      !fotoDemasiadoGrande;

  Future<void> tomarFoto() async {
    if (_abriendoCamara || _paso == PasoDocumento.analizando) {
      return;
    }
    _abriendoCamara = true;
    _notificar();
    try {
      final permiso = await _camara.solicitarPermiso();
      if (permiso != ResultadoPermiso.concedido) {
        _permisoPermanente = permiso == ResultadoPermiso.denegadoPermanente;
        _paso = PasoDocumento.permisoDenegado;
        return;
      }
      final foto = await _camara.tomarFoto();
      if (foto != null) {
        _mostrarVistaPrevia(foto);
      }
    } on ErrorCamara catch (error) {
      _aviso = error.mensaje;
      _avisoReintentable = false;
    } finally {
      _abriendoCamara = false;
      _notificar();
    }
  }

  /// Si Android cerró la app mientras la cámara estaba abierta, retoma la foto.
  Future<void> recuperarFotoPendiente() async {
    final foto = await _camara.recuperarFotoPendiente();
    if (foto != null && _paso == PasoDocumento.inicio) {
      _mostrarVistaPrevia(foto);
      _notificar();
    }
  }

  Future<void> enviar() async {
    final foto = _foto;
    if (!puedeEnviar || foto == null) {
      return;
    }
    _paso = PasoDocumento.analizando;
    _aviso = null;
    _notificar();
    try {
      _resultado = await _repositorio.revisarFormato(foto);
      _paso = PasoDocumento.resultado;
    } on ApiException catch (error) {
      _paso = PasoDocumento.vistaPrevia;
      _aviso = error.mensaje;
      _avisoReintentable = error.esReintentable;
    }
    _notificar();
  }

  Future<void> abrirAjustes() => _camara.abrirAjustes();

  /// Vuelve al inicio de la pestaña y descarta la foto y el resultado.
  void reiniciar() {
    _paso = PasoDocumento.inicio;
    _foto = null;
    _resultado = null;
    _aviso = null;
    _avisoReintentable = false;
    _notificar();
  }

  void _mostrarVistaPrevia(Uint8List foto) {
    _foto = foto;
    _resultado = null;
    _paso = PasoDocumento.vistaPrevia;
    _avisoReintentable = false;
    _aviso = fotoDemasiadoGrande
        ? 'La foto pesa ${Formatos.tamano(foto.length)} y supera el máximo '
              'de 5 MB. Toma otra foto un poco más lejos o con menos detalle.'
        : null;
  }

  void _notificar() {
    if (!_descartado) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
