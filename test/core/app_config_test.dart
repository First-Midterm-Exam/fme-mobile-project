import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/config/app_config.dart';

void main() {
  group('AppConfig.desdeMapa', () {
    test('lee la URL y el modo simulado', () {
      final config = AppConfig.desdeMapa({
        'API_BASE_URL': 'http://10.0.2.2:8000/api',
        'USE_MOCK': 'true',
      });

      expect(config.apiBaseUrl.toString(), 'http://10.0.2.2:8000/api');
      expect(config.usarSimulacion, isTrue);
    });

    test('USE_MOCK ausente equivale a false', () {
      final config = AppConfig.desdeMapa({
        'API_BASE_URL': 'https://readiness.empresa.com/api',
      });

      expect(config.usarSimulacion, isFalse);
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
