import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/data/models/respuesta_asistente.dart';

void main() {
  const base = {
    'resumen_voz': 'Te faltan dos gaps.',
    'reporte_markdown': '## Qué falta',
    'tipo_reporte': 'que_nos_falta',
    'generado_en': '2026-09-21T15:04:00Z',
  };

  test('lee una respuesta sin archivo', () {
    final respuesta = RespuestaAsistente.fromJson(base);

    expect(respuesta.resumenVoz, 'Te faltan dos gaps.');
    expect(respuesta.generadoEn, DateTime.utc(2026, 9, 21, 15, 4));
    expect(respuesta.archivo, isNull);
  });

  test('lee el archivo PDF o Excel del reporte', () {
    final respuesta = RespuestaAsistente.fromJson({
      ...base,
      'archivo': {
        'id': 'rep-42',
        'formato': 'xlsx',
        'nombre': 'gaps.xlsx',
        'url': 'https://servidor/api/asistente/archivos/rep-42/descarga',
        'tamano_bytes': 5120,
        'expira_en': '2026-09-22T15:04:00Z',
      },
    });

    final archivo = respuesta.archivo!;
    expect(archivo.formato, FormatoArchivo.excel);
    expect(archivo.nombre, 'gaps.xlsx');
    expect(archivo.tamanoBytes, 5120);
    expect(archivo.expiraEn, DateTime.utc(2026, 9, 22, 15, 4));
  });

  test('un archivo con formato desconocido se ignora', () {
    final respuesta = RespuestaAsistente.fromJson({
      ...base,
      'archivo': {'id': 'x', 'formato': 'docx', 'url': '/x'},
    });

    expect(respuesta.archivo, isNull);
    expect(respuesta.reporteMarkdown, '## Qué falta');
  });

  test('un archivo sin nombre recibe uno con su extensión', () {
    final respuesta = RespuestaAsistente.fromJson({
      ...base,
      'archivo': {'id': '7', 'formato': 'pdf', 'url': '/a/7'},
    });

    expect(respuesta.archivo?.nombre, 'reporte-7.pdf');
  });

  test('una respuesta vacía es inválida', () {
    expect(
      () => RespuestaAsistente.fromJson({'tipo_reporte': 'x'}),
      throwsFormatException,
    );
  });
}
