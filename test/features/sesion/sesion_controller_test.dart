import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/network/api_exception.dart';
import 'package:fme_mobile_project/features/sesion/sesion_controller.dart';
import 'package:http/http.dart' as http;

import '../../helpers/sesion_de_prueba.dart';

const _usuario = {
  'id': 1,
  'nombre': 'María Fernández',
  'email': 'maria@empresa.com',
  'rol': {'id': 2, 'nombre': 'Gestor de Procesos'},
};

/// Respuesta JSON en UTF-8, como la envía Laravel.
http.Response _json(int codigo, Object cuerpo) =>
    http.Response.bytes(utf8.encode(jsonEncode(cuerpo)), codigo);

void main() {
  const tokenGuardado = {SesionDePrueba.claveToken: 'guardado'};

  test('sin token guardado queda sin sesión', () async {
    final prueba = SesionDePrueba((_) async => fail('no debe llamar'));

    await prueba.controller.verificarSesionGuardada();

    expect(prueba.controller.estado, EstadoSesion.sinSesion);
  });

  test('token guardado válido entra directo', () async {
    final prueba = SesionDePrueba(
      (_) async => _json(200, _usuario),
      almacenamientoInicial: tokenGuardado,
    );

    await prueba.controller.verificarSesionGuardada();

    expect(prueba.controller.estado, EstadoSesion.autenticada);
    expect(prueba.controller.usuario?.rol?.nombre, 'Gestor de Procesos');
  });

  test('si /me responde 401 borra el token y avisa', () async {
    final prueba = SesionDePrueba(
      (_) async => _json(401, {}),
      almacenamientoInicial: tokenGuardado,
    );

    await prueba.controller.verificarSesionGuardada();

    expect(prueba.controller.estado, EstadoSesion.sinSesion);
    expect(prueba.storage.token, isNull);
    expect(await prueba.storage.cargar(), isNull);
    expect(
      prueba.controller.aviso,
      'Tu sesión expiró. Vuelve a iniciar sesión.',
    );
  });

  test('sin conexión conserva el token y ofrece reintentar', () async {
    final prueba = SesionDePrueba(
      (_) async => throw const SocketException('sin red'),
      almacenamientoInicial: tokenGuardado,
    );

    await prueba.controller.verificarSesionGuardada();

    expect(prueba.controller.estado, EstadoSesion.verificando);
    expect(prueba.controller.errorVerificacion?.tipo, TipoErrorApi.sinConexion);
    expect(prueba.storage.token, 'guardado');

    await prueba.controller.descartarSesionGuardada();
    expect(prueba.controller.estado, EstadoSesion.sinSesion);
    expect(prueba.storage.token, isNull);
  });

  test('iniciar sesión guarda el token y el usuario', () async {
    late Map<String, dynamic> cuerpo;
    final prueba = SesionDePrueba((peticion) async {
      cuerpo = jsonDecode(peticion.body) as Map<String, dynamic>;
      return _json(200, {'token': 'nuevo', 'user': _usuario});
    });

    await prueba.controller.iniciarSesion(
      email: 'maria@empresa.com',
      password: 'secreta',
    );

    expect(cuerpo, {
      'email': 'maria@empresa.com',
      'password': 'secreta',
      'device_name': 'asistente-movil',
    });
    expect(prueba.controller.estado, EstadoSesion.autenticada);
    expect(await prueba.storage.cargar(), 'nuevo');
  });

  test(
    'cerrar sesión envía el token y limpia sin esperar al servidor',
    () async {
      String? autorizacion;
      final prueba = SesionDePrueba((peticion) async {
        autorizacion = peticion.headers['Authorization'];
        throw const SocketException('sin red');
      }, almacenamientoInicial: tokenGuardado);
      await prueba.storage.cargar();

      await prueba.controller.cerrarSesion();
      await Future<void>.delayed(Duration.zero);

      expect(autorizacion, 'Bearer guardado');
      expect(prueba.controller.estado, EstadoSesion.sinSesion);
      expect(prueba.controller.aviso, isNull);
      expect(await prueba.storage.cargar(), isNull);
    },
  );

  test('un 401 en cualquier petición cierra la sesión', () async {
    final prueba = SesionDePrueba(
      (peticion) async => peticion.url.path.endsWith('/me')
          ? _json(200, _usuario)
          : _json(401, {}),
      almacenamientoInicial: tokenGuardado,
    );
    await prueba.controller.verificarSesionGuardada();

    await expectLater(prueba.api.get('/appraisals'), throwsA(isA<Object>()));
    await Future<void>.delayed(Duration.zero);

    expect(prueba.controller.estado, EstadoSesion.sinSesion);
    expect(prueba.controller.aviso, ApiException.mensajeSesionExpirada);
  });
}
