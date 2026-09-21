import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/features/sesion/validadores.dart';

void main() {
  group('Validadores.correo', () {
    test('rechaza vacío y solo espacios', () {
      expect(Validadores.correo(null), 'Ingresa tu correo.');
      expect(Validadores.correo('   '), 'Ingresa tu correo.');
    });

    test('rechaza formatos inválidos', () {
      for (final correo in ['maria', 'maria@', '@empresa.com', 'a b@c.com']) {
        expect(Validadores.correo(correo), startsWith('Ingresa un correo'));
      }
    });

    test('acepta un correo válido con espacios alrededor', () {
      expect(Validadores.correo(' maria@empresa.com '), isNull);
    });
  });

  group('Validadores.contrasena', () {
    test('rechaza vacío y acepta cualquier texto', () {
      expect(Validadores.contrasena(''), 'Ingresa tu contraseña.');
      expect(Validadores.contrasena('x'), isNull);
    });
  });
}
