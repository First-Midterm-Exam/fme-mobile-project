import '../../core/network/api_client.dart';
import '../../core/network/lectura_json.dart';
import '../models/appraisal.dart';

class AppraisalRepository {
  const AppraisalRepository(this._api);

  final ApiClient _api;

  /// Appraisals activos a los que el usuario tiene acceso.
  Future<List<Appraisal>> listarActivos() async {
    final json = await _api.get('/appraisals', consulta: {'estado': 'activo'});
    return parsearRespuesta(() => Appraisal.listaFromJson(json));
  }
}
