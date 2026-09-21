import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/features/asistente/servicios/idiomas.dart';

void main() {
  test('prioriza es_BO sobre el resto', () {
    expect(
      elegirIdioma([
        'en_US',
        'es_ES',
        'es_419',
        'es_BO',
      ], idiomasReconocimiento),
      'es_BO',
    );
  });

  test('usa es_419 si no hay es_BO', () {
    expect(elegirIdioma(['es-ES', 'es-419'], idiomasReconocimiento), 'es-419');
  });

  test('usa es_ES como respaldo', () {
    expect(elegirIdioma(['en_US', 'es_ES'], idiomasReconocimiento), 'es_ES');
  });

  test('acepta cualquier variante de español si no hay preferidas', () {
    expect(elegirIdioma(['en_US', 'es_MX'], idiomasReconocimiento), 'es_MX');
  });

  test('devuelve null si no hay español', () {
    expect(elegirIdioma(['en_US', 'pt_BR'], idiomasReconocimiento), isNull);
  });
}
