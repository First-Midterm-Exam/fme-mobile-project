import '../../core/network/api_client.dart';
import '../../core/network/lectura_json.dart';
import '../models/respuesta_asistente.dart';

class AsistenteRepository {
  const AsistenteRepository(this._api);

  static const tiempoEspera = Duration(seconds: 60);

  static const mensajes = {
    422: 'La pregunta está vacía o el appraisal seleccionado no es válido.',
    503:
        'El servicio de generación de reportes no está disponible. Inténtalo '
        'más tarde.',
  };

  final ApiClient _api;

  Future<RespuestaAsistente> consultar({
    required int appraisalId,
    required String pregunta,
  }) async {
    final json = await _api.post(
      '/asistente/consultas',
      cuerpo: {'appraisal_id': appraisalId, 'pregunta': pregunta},
      tiempoEspera: tiempoEspera,
      mensajes: mensajes,
    );
    return parsearRespuesta(() => RespuestaAsistente.fromJson(json));
  }
}
