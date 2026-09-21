import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/config/app_config.dart';

void main() {
  group('AppConfig.desdeMapa', () {
    test('lee la URL base de la API', () {
      final config = AppConfig.desdeMapa({
        'API_BASE_URL': ' http://192.168.100.7:8000/api ',
      });

      expect(config.apiBaseUrl.toString(), 'http://192.168.100.7:8000/api');
    });

    test('falla si falta API_BASE_URL o no es http', () {
      expect(() => AppConfig.desdeMapa({}), throwsStateError);
      expect(
        () => AppConfig.desdeMapa({'API_BASE_URL': 'ftp://servidor'}),
        throwsStateError,
      );
    });
  });
}
