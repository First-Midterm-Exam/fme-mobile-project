import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasStorage {
  PreferenciasStorage._(this._preferencias);

  static const _claveAppraisal = 'appraisal_id';

  final SharedPreferencesWithCache _preferencias;

  static Future<PreferenciasStorage> crear() async {
    final preferencias = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_claveAppraisal},
      ),
    );
    return PreferenciasStorage._(preferencias);
  }

  int? get appraisalId => _preferencias.getInt(_claveAppraisal);

  Future<void> guardarAppraisalId(int id) =>
      _preferencias.setInt(_claveAppraisal, id);

  Future<void> borrarAppraisalId() => _preferencias.remove(_claveAppraisal);
}
