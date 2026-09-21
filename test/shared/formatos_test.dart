import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/shared/formatos.dart';

void main() {
  test('fecha en formato dd/MM/aaaa', () {
    expect(Formatos.fecha(DateTime(2026, 3, 5)), '05/03/2026');
  });

  test('tamaño en KB y MB con coma decimal', () {
    expect(Formatos.tamano(850 * 1024), '850 KB');
    expect(Formatos.tamano((1.25 * 1024 * 1024).round()), '1,3 MB');
  });

  test('plazo hasta la fecha meta', () {
    final hoy = DateTime(2026, 9, 21, 18);
    expect(Formatos.plazo(DateTime(2026, 9, 21), hoy: hoy), 'Vence hoy');
    expect(Formatos.plazo(DateTime(2026, 9, 22), hoy: hoy), 'Falta 1 día');
    expect(Formatos.plazo(DateTime(2026, 11, 30), hoy: hoy), 'Faltan 70 días');
    expect(
      Formatos.plazo(DateTime(2026, 9, 18), hoy: hoy),
      'Venció hace 3 días',
    );
  });
}
