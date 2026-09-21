import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/network/api_client.dart';
import 'package:fme_mobile_project/core/network/api_exception.dart';
import 'package:fme_mobile_project/data/models/respuesta_asistente.dart';
import 'package:fme_mobile_project/data/repositories/appraisal_repository.dart';
import 'package:fme_mobile_project/data/repositories/asistente_repository.dart';
import 'package:fme_mobile_project/data/repositories/auth_repository.dart';
import 'package:fme_mobile_project/data/repositories/documento_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/dobles.dart';

const _usuario = {
  'id': 2,
  'nombre': 'Gestor de Procesos DIMA',
  'email': 'gestor@dima.cl',
  'rol': {'id': 2, 'nombre': 'Gestor de Procesos'},
};

TypeMatcher<ApiException> _error(TipoErrorApi tipo, String mensaje) =>
    isA<ApiException>()
        .having((e) => e.tipo, 'tipo', tipo)
        .having((e) => e.mensaje, 'mensaje', contains(mensaje));

void main() {
  group('AuthRepository', () {
    test('login envía las credenciales y lee token y usuario', () async {
      late http.Request enviada;
      final repo = AuthRepository(
        apiDePrueba((peticion) async {
          enviada = peticion;
          return respuestaJson(200, {'token': '7|abc', 'user': _usuario});
        }),
      );

      final sesion = await repo.iniciarSesion(
        email: 'gestor@dima.cl',
        password: 'password',
      );

      expect(enviada.url.path, '/api/login');
      expect(enviada.headers.containsKey('Authorization'), isFalse);
      expect(jsonDecode(enviada.body), {
        'email': 'gestor@dima.cl',
        'password': 'password',
        'device_name': 'asistente-movil',
      });
      expect(sesion.token, '7|abc');
      expect(sesion.usuario.rol?.nombre, 'Gestor de Procesos');
    });

    for (final codigo in [401, 422]) {
      test('login con $codigo no revela si el correo existe', () {
        final repo = AuthRepository(
          apiDePrueba((_) async => respuestaJson(codigo, {'message': 'x'})),
        );

        expect(
          repo.iniciarSesion(email: 'a@b.cl', password: 'x'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.mensaje,
              'mensaje',
              'El correo o la contraseña no son correctos.',
            ),
          ),
        );
      });
    }

    test('me con token vencido pide volver a iniciar sesión', () {
      final repo = AuthRepository(
        apiDePrueba((_) async => respuestaJson(401, {})),
      );

      expect(
        repo.usuarioActual(),
        throwsA(_error(TipoErrorApi.sesionExpirada, 'Tu sesión expiró.')),
      );
    });
  });

  group('AppraisalRepository', () {
    test('pide solo los activos y lee la lista dentro de data', () async {
      late Uri url;
      final repo = AppraisalRepository(
        apiDePrueba((peticion) async {
          url = peticion.url;
          return respuestaJson(200, {
            'data': [
              {
                'id': 1,
                'nombre': 'Appraisal CMMI Nivel 3 - H1',
                'proyecto': 'Sistema de Facturación DIMA',
                'nivel_objetivo': 3,
                'fecha_meta': '2026-11-30',
                'estado': 'activo',
              },
            ],
          });
        }),
      );

      final lista = await repo.listarActivos();

      expect(url.queryParameters, {'estado': 'activo'});
      expect(lista.single.nivelObjetivo, 3);
      expect(lista.single.fechaMeta, DateTime(2026, 11, 30));
    });

    test('403 usa el mensaje de permisos', () {
      final repo = AppraisalRepository(
        apiDePrueba((_) async => respuestaJson(403, {})),
      );

      expect(
        repo.listarActivos(),
        throwsA(
          _error(
            TipoErrorApi.sinPermiso,
            'Tu rol no tiene permiso para esta acción.',
          ),
        ),
      );
    });
  });

  group('DocumentoRepository', () {
    test('envía la imagen como multipart y lee el resultado', () async {
      late http.Request enviada;
      final repo = DocumentoRepository(
        apiDePrueba((peticion) async {
          enviada = peticion;
          return respuestaJson(200, {
            'cumple': true,
            'puntaje': 88,
            'tipo_detectado': 'Acta',
            'resumen': 'Correcto.',
            'hallazgos': <Object>[],
          });
        }),
      );

      final revision = await repo.revisarFormato(Uint8List.fromList([1, 2]));

      expect(enviada.url.path, '/api/documentos/revision-formato');
      expect(
        enviada.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      expect(
        latin1.decode(enviada.bodyBytes),
        contains('name="imagen"; filename="documento.jpg"'),
      );
      expect(revision.puntaje, 88);
    });

    for (final (codigo, tipo, mensaje) in [
      (413, TipoErrorApi.archivoDemasiadoGrande, 'máximo permitido es 5 MB'),
      (422, TipoErrorApi.datosInvalidos, 'Toma otra foto'),
      (503, TipoErrorApi.servicioNoDisponible, 'análisis de documentos'),
    ]) {
      test('$codigo tiene su mensaje en español', () {
        final repo = DocumentoRepository(
          apiDePrueba((_) async => respuestaJson(codigo, {})),
        );

        expect(
          repo.revisarFormato(Uint8List(1)),
          throwsA(_error(tipo, mensaje)),
        );
      });
    }
  });

  group('AsistenteRepository', () {
    test('envía la pregunta y lee el archivo del reporte', () async {
      late http.Request enviada;
      final repo = AsistenteRepository(
        apiDePrueba((peticion) async {
          enviada = peticion;
          return respuestaJson(200, {
            'resumen_voz': 'El reporte está listo.',
            'reporte_markdown': '## Gaps críticos',
            'tipo_reporte': 'gaps_criticos',
            'generado_en': '2026-09-21T21:01:21Z',
            'archivo': {
              'id': 'rep-1',
              'formato': 'pdf',
              'nombre': 'reporte.pdf',
              'url': 'http://servidor.test/api/asistente/archivos/rep-1',
              'tamano_bytes': 22160,
            },
          });
        }),
      );

      final respuesta = await repo.consultar(
        appraisalId: 1,
        pregunta: 'Genera el reporte en PDF',
      );

      expect(jsonDecode(enviada.body), {
        'appraisal_id': 1,
        'pregunta': 'Genera el reporte en PDF',
      });
      expect(respuesta.archivo?.formato, FormatoArchivo.pdf);
    });

    test('429 respeta Retry-After', () {
      final repo = AsistenteRepository(
        apiDePrueba(
          (_) async => http.Response('{}', 429, headers: {'retry-after': '31'}),
        ),
      );

      expect(
        repo.consultar(appraisalId: 1, pregunta: 'x'),
        throwsA(
          _error(TipoErrorApi.demasiadasSolicitudes, '31 segundos').having(
            (e) => e.reintentarEn,
            'reintentarEn',
            const Duration(seconds: 31),
          ),
        ),
      );
    });

    for (final (codigo, tipo, mensaje) in [
      (422, TipoErrorApi.datosInvalidos, 'La pregunta está vacía'),
      (503, TipoErrorApi.servicioNoDisponible, 'generación de reportes'),
    ]) {
      test('$codigo tiene su mensaje en español', () {
        final repo = AsistenteRepository(
          apiDePrueba((_) async => respuestaJson(codigo, {})),
        );

        expect(
          repo.consultar(appraisalId: 1, pregunta: 'x'),
          throwsA(_error(tipo, mensaje)),
        );
      });
    }

    test('la descarga envía el token solo al mismo servidor', () async {
      final autorizaciones = <String, String?>{};
      final repo = AsistenteRepository(
        ApiClient(
          baseUrl: Uri.parse('http://servidor.test/api'),
          httpClient: MockClient((peticion) async {
            autorizaciones[peticion.url.host] =
                peticion.headers['Authorization'];
            return http.Response.bytes([37, 80, 68, 70], 200);
          }),
          leerToken: () => 'secreto',
        ),
      );

      final bytes = await repo.descargarArchivo(
        const ArchivoReporte(
          id: '1',
          formato: FormatoArchivo.pdf,
          nombre: 'a.pdf',
          url: 'http://servidor.test/api/asistente/archivos/1/descarga',
        ),
      );
      await repo.descargarArchivo(
        const ArchivoReporte(
          id: '2',
          formato: FormatoArchivo.excel,
          nombre: 'b.xlsx',
          url: 'https://almacen.externo.com/b.xlsx',
        ),
      );

      expect(bytes, [37, 80, 68, 70]);
      expect(autorizaciones['servidor.test'], 'Bearer secreto');
      expect(autorizaciones['almacen.externo.com'], isNull);
    });

    test('un archivo vencido da un mensaje claro', () {
      final repo = AsistenteRepository(
        apiDePrueba((_) async => respuestaJson(404, {})),
      );

      expect(
        repo.descargarArchivo(
          const ArchivoReporte(
            id: '1',
            formato: FormatoArchivo.pdf,
            nombre: 'a.pdf',
            url: '/api/asistente/archivos/1/descarga',
          ),
        ),
        throwsA(_error(TipoErrorApi.noEncontrado, 'ya no está disponible')),
      );
    });
  });
}
