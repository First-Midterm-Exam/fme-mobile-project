import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

import '../../core/network/api_client.dart';
import '../../core/network/lectura_json.dart';
import '../models/revision_formato.dart';

class DocumentoRepository {
  const DocumentoRepository(this._api);

  static const tamanoMaximoBytes = 5 * 1024 * 1024;
  static const tiempoEspera = Duration(seconds: 60);

  static const mensajes = {
    413: 'La imagen es demasiado grande. El máximo permitido es 5 MB.',
    422:
        'No se pudo leer la imagen o no parece un documento. Toma otra foto '
        'con buena luz y el documento completo.',
    503:
        'El servicio de análisis de documentos no está disponible. Inténtalo '
        'más tarde.',
  };

  final ApiClient _api;

  /// Envía la foto (JPEG) al modelo que analiza el formato.
  Future<RevisionFormato> revisarFormato(Uint8List imagenJpeg) async {
    final json = await _api.postArchivo(
      '/documentos/revision-formato',
      campo: 'imagen',
      bytes: imagenJpeg,
      nombreArchivo: 'documento.jpg',
      tipoContenido: MediaType('image', 'jpeg'),
      tiempoEspera: tiempoEspera,
      mensajes: mensajes,
    );
    return parsearRespuesta(() => RevisionFormato.fromJson(json));
  }
}
