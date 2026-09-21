import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/permisos/permisos.dart';

export '../../core/permisos/permisos.dart' show ResultadoPermiso;

class ErrorCamara implements Exception {
  const ErrorCamara(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ErrorCamara: $mensaje';
}

abstract interface class CamaraDocumentos {
  Future<ResultadoPermiso> solicitarPermiso();

  Future<Uint8List?> tomarFoto();

  Future<Uint8List?> recuperarFotoPendiente();

  Future<void> abrirAjustes();
}

class CamaraDelSistema implements CamaraDocumentos {
  CamaraDelSistema({ImagePicker? selector})
    : _selector = selector ?? ImagePicker();

  static const anchoMaximo = 1600.0;
  static const calidadJpeg = 80;

  final ImagePicker _selector;

  @override
  Future<ResultadoPermiso> solicitarPermiso() =>
      pedirPermiso(Permission.camera);

  @override
  Future<Uint8List?> tomarFoto() async {
    try {
      final foto = await _selector.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: anchoMaximo,
        imageQuality: calidadJpeg,
        requestFullMetadata: false,
      );
      return foto == null ? null : _leerYDescartar(foto);
    } on PlatformException catch (error) {
      if (error.code == 'camera_access_denied') {
        throw const ErrorCamara(
          'No se pudo abrir la cámara porque el permiso fue denegado.',
        );
      }
      throw const ErrorCamara(
        'No se pudo abrir la cámara del teléfono. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<Uint8List?> recuperarFotoPendiente() async {
    if (!Platform.isAndroid) {
      return null;
    }
    final perdida = await _selector.retrieveLostData();
    final foto = perdida.file;
    if (perdida.isEmpty || foto == null) {
      return null;
    }
    return _leerYDescartar(foto);
  }

  @override
  Future<void> abrirAjustes() => abrirAjustesDeLaApp();

  static Future<Uint8List> _leerYDescartar(XFile foto) async {
    final bytes = await foto.readAsBytes();
    try {
      await File(foto.path).delete();
    } on FileSystemException {
      return bytes;
    }
    return bytes;
  }
}
