import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/network/api_client.dart';
import 'package:fme_mobile_project/core/network/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _base = Uri.parse('http://servidor.test/api');

ApiClient _cliente(MockClientHandler manejador, {String? token = 'abc'}) =>
    ApiClient(
      baseUrl: _base,
      httpClient: MockClient(manejador),
      leerToken: () => token,
      tiempoEsperaPorDefecto: const Duration(milliseconds: 200),
    );

TypeMatcher<ApiException> _errorApi(TipoErrorApi tipo, String mensaje) =>
    isA<ApiException>()
        .having((e) => e.tipo, 'tipo', tipo)
        .having((e) => e.mensaje, 'mensaje', mensaje);

void main() {
  test('arma la URL con el prefijo y envía token y Accept', () async {
    late http.Request enviada;
    final api = _cliente((peticion) async {
      enviada = peticion;
      return http.Response('{"ok":true}', 200);
    });

    final json = await api.get('/appraisals', consulta: {'estado': 'activo'});

    expect(json, {'ok': true});
    expect(
      enviada.url.toString(),
      'http://servidor.test/api/appraisals?estado=activo',
    );
    expect(enviada.headers['Authorization'], 'Bearer abc');
    expect(enviada.headers['Accept'], 'application/json');
  });

  test('las peticiones no autenticadas no envían el token', () async {
    late http.Request enviada;
    final api = _cliente((peticion) async {
      enviada = peticion;
      return http.Response('{}', 200);
    });

    await api.post('/login', cuerpo: {'email': 'a'}, autenticado: false);

    expect(enviada.headers.containsKey('Authorization'), isFalse);
  });

  test('una respuesta 204 sin cuerpo devuelve un mapa vacío', () async {
    final api = _cliente((_) async => http.Response('', 204));

    expect(await api.post('/logout'), isEmpty);
  });

  test('401 autenticado avisa que la sesión expiró', () async {
    final api = _cliente((_) async => http.Response('{}', 401));
    final eventos = <void>[];
    api.sesionExpirada.listen(eventos.add);

    await expectLater(
      api.get('/me'),
      throwsA(
        _errorApi(
          TipoErrorApi.sesionExpirada,
          'Tu sesión expiró. Vuelve a iniciar sesión.',
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(eventos, hasLength(1));
  });

  test('401 en login es credencial inválida y no expira la sesión', () async {
    final api = _cliente((_) async => http.Response('{}', 401));
    var expiro = false;
    api.sesionExpirada.listen((_) => expiro = true);

    await expectLater(
      api.post('/login', autenticado: false),
      throwsA(
        isA<ApiException>().having(
          (e) => e.tipo,
          'tipo',
          TipoErrorApi.credencialesInvalidas,
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(expiro, isFalse);
  });

  test('403 usa el mensaje de permiso', () async {
    final api = _cliente((_) async => http.Response('{}', 403));

    await expectLater(
      api.get('/appraisals'),
      throwsA(
        _errorApi(
          TipoErrorApi.sinPermiso,
          'Tu rol no tiene permiso para esta acción.',
        ),
      ),
    );
  });

  test('429 lee Retry-After', () async {
    final api = _cliente(
      (_) async => http.Response('{}', 429, headers: {'retry-after': '30'}),
    );

    await expectLater(
      api.post('/asistente/consultas'),
      throwsA(
        _errorApi(
          TipoErrorApi.demasiadasSolicitudes,
          'Hiciste demasiadas consultas. Inténtalo de nuevo en 30 segundos.',
        ).having(
          (e) => e.reintentarEn,
          'reintentarEn',
          const Duration(seconds: 30),
        ),
      ),
    );
  });

  test('los mensajes por endpoint reemplazan al genérico', () async {
    final api = _cliente((_) async => http.Response('{}', 503));

    await expectLater(
      api.get('/x', mensajes: {503: 'Análisis no disponible.'}),
      throwsA(
        _errorApi(TipoErrorApi.servicioNoDisponible, 'Análisis no disponible.'),
      ),
    );
  });

  test('sin conexión da un error reintentable', () async {
    final api = _cliente((_) async => throw const SocketException('sin red'));

    await expectLater(
      api.get('/me'),
      throwsA(
        _errorApi(
          TipoErrorApi.sinConexion,
          ApiException.mensajeSinConexion,
        ).having((e) => e.esReintentable, 'esReintentable', isTrue),
      ),
    );
  });

  test('tiempo agotado da un error reintentable', () async {
    final api = _cliente((_) => Completer<http.Response>().future);

    await expectLater(
      api.get('/me'),
      throwsA(
        _errorApi(
          TipoErrorApi.tiempoAgotado,
          ApiException.mensajeTiempoAgotado,
        ),
      ),
    );
  });

  test('un cuerpo que no es JSON es respuesta inválida', () async {
    final api = _cliente((_) async => http.Response('<html>', 200));

    await expectLater(
      api.get('/me'),
      throwsA(
        _errorApi(
          TipoErrorApi.respuestaInvalida,
          ApiException.mensajeRespuestaInvalida,
        ),
      ),
    );
  });
}
