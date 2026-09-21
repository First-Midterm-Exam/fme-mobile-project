import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum ResultadoPermiso { concedido, denegado, denegadoPermanente }

/// Falla de la cámara con un mensaje listo para mostrar.
class ErrorCamara implements Exception {
  const ErrorCamara(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ErrorCamara: $mensaje';
}

/// Acceso a la cámara para fotografiar documentos.
abstract interface class CamaraDocumentos {
  Future<ResultadoPermiso> solicitarPermiso();

  /// Abre la cámara y devuelve la foto en JPEG, o `null` si se canceló.
  Future<Uint8List?> tomarFoto();

  /// Recupera una foto tomada justo antes de que Android cerrara la app.
  Future<Uint8List?> recuperarFotoPendiente();

  Future<void> abrirAjustes();
}

/// Implementación con la cámara del sistema. Nunca abre la galería.
class CamaraDelSistema implements CamaraDocumentos {
  CamaraDelSistema({ImagePicker? selector})
    : _selector = selector ?? ImagePicker();

  static const anchoMaximo = 1600.0;
  static const calidadJpeg = 80;

  final ImagePicker _selector;

  @override
  Future<ResultadoPermiso> solicitarPermiso() async {
    final estado = await Permission.camera.request();
    if (estado.isGranted || estado.isLimited) {
      return ResultadoPermiso.concedido;
    }
    if (estado.isPermanentlyDenied || estado.isRestricted) {
      return ResultadoPermiso.denegadoPermanente;
    }
    return ResultadoPermiso.denegado;
  }

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
  Future<void> abrirAjustes() => openAppSettings();

  /// Lee la foto y borra el archivo temporal: la imagen no queda guardada
  /// en el teléfono.
  static Future<Uint8List> _leerYDescartar(XFile foto) async {
    final bytes = await foto.readAsBytes();
    try {
      await File(foto.path).delete();
    } on FileSystemException {
      // Si no se puede borrar, el sistema limpia la caché más adelante.
    }
    return bytes;
  }
}
