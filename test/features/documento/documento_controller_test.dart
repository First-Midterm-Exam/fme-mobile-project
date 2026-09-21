import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/data/repositories/documento_repository.dart';
import 'package:fme_mobile_project/features/documento/camara_documentos.dart';
import 'package:fme_mobile_project/features/documento/documento_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/dobles.dart';

const _revision = {
  'cumple': true,
  'puntaje': 91,
  'tipo_detectado': 'Acta de reunión',
  'resumen': 'Correcto.',
  'hallazgos': <Object>[],
};

DocumentoController _controlador(
  CamaraFalsa camara, {
  MockClientHandler? servidor,
}) => DocumentoController(
  repositorio: DocumentoRepository(
    apiDePrueba(servidor ?? (_) async => respuestaJson(200, _revision)),
  ),
  camara: camara,
);

void main() {
  final fotoValida = Uint8List(1024);

  test('permiso denegado muestra la explicación', () async {
    final controlador = _controlador(
      CamaraFalsa(permiso: ResultadoPermiso.denegado),
    );

    await controlador.tomarFoto();

    expect(controlador.paso, PasoDocumento.permisoDenegado);
    expect(controlador.permisoPermanente, isFalse);
  });

  test('permiso denegado permanente ofrece abrir ajustes', () async {
    final camara = CamaraFalsa(permiso: ResultadoPermiso.denegadoPermanente);
    final controlador = _controlador(camara);

    await controlador.tomarFoto();
    await controlador.abrirAjustes();

    expect(controlador.permisoPermanente, isTrue);
    expect(camara.aperturasDeAjustes, 1);
  });

  test('cancelar la cámara deja la pestaña como estaba', () async {
    final controlador = _controlador(CamaraFalsa());

    await controlador.tomarFoto();

    expect(controlador.paso, PasoDocumento.inicio);
    expect(controlador.foto, isNull);
  });

  test('un error de la cámara se muestra como aviso', () async {
    final controlador = _controlador(
      CamaraFalsa(error: const ErrorCamara('Sin cámara.')),
    );

    await controlador.tomarFoto();

    expect(controlador.paso, PasoDocumento.inicio);
    expect(controlador.aviso, 'Sin cámara.');
  });

  test('una foto de más de 5 MB se avisa y no se envía', () async {
    var envios = 0;
    final controlador = _controlador(
      CamaraFalsa(foto: Uint8List(DocumentoRepository.tamanoMaximoBytes + 1)),
      servidor: (_) async {
        envios++;
        return respuestaJson(200, _revision);
      },
    );

    await controlador.tomarFoto();
    await controlador.enviar();

    expect(controlador.paso, PasoDocumento.vistaPrevia);
    expect(controlador.puedeEnviar, isFalse);
    expect(controlador.aviso, contains('supera el máximo de 5 MB'));
    expect(envios, 0);
  });

  test('envía la foto, muestra "analizando" y luego el resultado', () async {
    final respuesta = Completer<http.Response>();
    late http.Request enviada;
    final controlador = _controlador(
      CamaraFalsa(foto: fotoValida),
      servidor: (peticion) {
        enviada = peticion;
        return respuesta.future;
      },
    );
    await controlador.tomarFoto();
    expect(controlador.paso, PasoDocumento.vistaPrevia);

    final envio = controlador.enviar();
    expect(controlador.paso, PasoDocumento.analizando);
    respuesta.complete(respuestaJson(200, _revision));
    await envio;

    expect(controlador.paso, PasoDocumento.resultado);
    expect(controlador.resultado?.puntaje, 91);
    final cuerpo = latin1.decode(enviada.bodyBytes);
    expect(enviada.headers['content-type'], startsWith('multipart/form-data'));
    expect(cuerpo, contains('name="imagen"; filename="documento.jpg"'));
    expect(cuerpo, contains('content-type: image/jpeg'));
  });

  test('un 503 vuelve a la vista previa con opción de reintentar', () async {
    final controlador = _controlador(
      CamaraFalsa(foto: fotoValida),
      servidor: (_) async => respuestaJson(503, {}),
    );
    await controlador.tomarFoto();

    await controlador.enviar();

    expect(controlador.paso, PasoDocumento.vistaPrevia);
    expect(controlador.avisoReintentable, isTrue);
    expect(controlador.aviso, contains('análisis de documentos'));
  });

  test('un 422 pide otra foto sin ofrecer reintentar', () async {
    final controlador = _controlador(
      CamaraFalsa(foto: fotoValida),
      servidor: (_) async => respuestaJson(422, {}),
    );
    await controlador.tomarFoto();

    await controlador.enviar();

    expect(controlador.avisoReintentable, isFalse);
    expect(controlador.aviso, contains('Toma otra foto'));
  });

  test('recupera una foto pendiente y reiniciar vuelve al inicio', () async {
    final camara = CamaraFalsa()..fotoPendiente = fotoValida;
    final controlador = _controlador(camara);

    await controlador.recuperarFotoPendiente();
    expect(controlador.paso, PasoDocumento.vistaPrevia);

    controlador.reiniciar();
    expect(controlador.paso, PasoDocumento.inicio);
    expect(controlador.foto, isNull);
  });
}
