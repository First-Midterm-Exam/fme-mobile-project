import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/network/api_client.dart';
import 'package:fme_mobile_project/core/network/api_exception.dart';
import 'package:fme_mobile_project/data/models/respuesta_asistente.dart';
import 'package:fme_mobile_project/data/repositories/asistente_repository.dart';
import 'package:fme_mobile_project/data/simulacion/backend_simulado.dart';
import 'package:fme_mobile_project/data/simulacion/datos_simulados.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final base = Uri.parse('http://10.0.2.2:8000/api');
  final api = ApiClient(
    baseUrl: base,
    httpClient: BackendSimulado(baseUrl: base, latencia: Duration.zero),
    leerToken: () => tokenSimulado,
  );
  final repositorio = AsistenteRepository(api);

  test('una pregunta normal no genera archivo', () async {
    final respuesta = await repositorio.consultar(
      appraisalId: 3,
      pregunta: '¿Qué acciones están vencidas?',
    );

    expect(respuesta.archivo, isNull);
  });

  test('pedir un PDF devuelve un archivo descargable válido', () async {
    final respuesta = await repositorio.consultar(
      appraisalId: 3,
      pregunta: 'Genera el reporte de gaps críticos en PDF',
    );
    final archivo = respuesta.archivo!;
    final bytes = await repositorio.descargarArchivo(archivo);

    expect(archivo.formato, FormatoArchivo.pdf);
    expect(respuesta.resumenVoz, contains('PDF'));
    expect(latin1.decode(bytes.sublist(0, 8)), '%PDF-1.4');
    expect(latin1.decode(bytes).trimRight(), endsWith('%%EOF'));
  });

  test('pedir un Excel devuelve un XLSX válido', () async {
    final respuesta = await repositorio.consultar(
      appraisalId: 3,
      pregunta: 'Exporta las acciones vencidas a Excel',
    );
    final bytes = await repositorio.descargarArchivo(respuesta.archivo!);
    final contenido = latin1.decode(bytes);

    expect(respuesta.archivo!.formato, FormatoArchivo.excel);
    expect(bytes.sublist(0, 2), [0x50, 0x4B]);
    expect(contenido, contains('xl/worksheets/sheet1.xml'));
    expect(utf8.decode(bytes, allowMalformed: true), contains('Luis Paz'));
  });

  test('la descarga envía el token solo al mismo servidor', () async {
    final autorizaciones = <String, String?>{};
    final cliente = ApiClient(
      baseUrl: base,
      httpClient: MockClient((peticion) async {
        autorizaciones[peticion.url.host] = peticion.headers['Authorization'];
        return http.Response.bytes([1, 2, 3], 200);
      }),
      leerToken: () => 'secreto',
    );
    final repo = AsistenteRepository(cliente);

    await repo.descargarArchivo(
      const ArchivoReporte(
        id: '1',
        formato: FormatoArchivo.pdf,
        nombre: 'a.pdf',
        url: '/api/asistente/archivos/1/descarga',
      ),
    );
    await repo.descargarArchivo(
      const ArchivoReporte(
        id: '2',
        formato: FormatoArchivo.pdf,
        nombre: 'b.pdf',
        url: 'https://almacen.externo.com/b.pdf',
      ),
    );

    expect(autorizaciones['10.0.2.2'], 'Bearer secreto');
    expect(autorizaciones['almacen.externo.com'], isNull);
  });

  test('un archivo vencido da un mensaje claro', () async {
    final respuesta = await repositorio.consultar(
      appraisalId: 3,
      pregunta: 'Genera el reporte de gaps críticos en PDF',
    );
    final vencido = ArchivoReporte(
      id: 'x',
      formato: FormatoArchivo.pdf,
      nombre: 'x.pdf',
      url: respuesta.archivo!.url.replaceAll('gaps_criticos.pdf', 'nada.pdf'),
    );

    expect(
      repositorio.descargarArchivo(vencido),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          'El archivo ya no está disponible. Vuelve a pedir el reporte.',
        ),
      ),
    );
  });
}
