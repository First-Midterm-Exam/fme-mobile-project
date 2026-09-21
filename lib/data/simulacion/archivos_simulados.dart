import 'dart:convert';
import 'dart:typed_data';

typedef FilaReporte = ({List<String> celdas, bool encabezado});

({String titulo, List<FilaReporte> filas}) tablaDesdeMarkdown(String markdown) {
  var titulo = 'Reporte';
  final filas = <FilaReporte>[];
  var enTabla = false;
  for (final linea in const LineSplitter().convert(markdown)) {
    final texto = linea.replaceAll('**', '').trim();
    if (texto.isEmpty) {
      enTabla = false;
      continue;
    }
    if (texto.startsWith('## ')) {
      titulo = texto.substring(3);
    } else if (texto.startsWith('|')) {
      final celdas = texto
          .substring(1, texto.length - 1)
          .split('|')
          .map((c) => c.trim())
          .toList();
      if (celdas.every((c) => RegExp(r'^-+$').hasMatch(c))) {
        continue;
      }
      filas.add((celdas: celdas, encabezado: !enTabla));
      enTabla = true;
    } else if (texto.startsWith('### ')) {
      filas.add((celdas: [texto.substring(4)], encabezado: true));
    } else {
      final sinVineta = texto.startsWith('- ') ? texto.substring(2) : texto;
      filas.add((celdas: [sinVineta], encabezado: false));
    }
  }
  return (titulo: titulo, filas: filas);
}

Uint8List generarPdf(String titulo, List<FilaReporte> filas) {
  final contenido = StringBuffer()
    ..writeln('BT /F2 18 Tf 50 790 Td (${_textoPdf(titulo)}) Tj ET')
    ..writeln(
      'BT /F1 9 Tf 50 772 Td '
      '(CMMI Appraisal Readiness Platform) Tj ET',
    );
  var y = 740;
  for (final fila in filas) {
    if (y < 60) {
      break;
    }
    final fuente = fila.encabezado ? '/F2' : '/F1';
    final ancho = fila.celdas.length > 1 ? 500 ~/ fila.celdas.length : 500;
    for (var i = 0; i < fila.celdas.length; i++) {
      contenido.writeln(
        'BT $fuente 10 Tf ${50 + i * ancho} $y Td '
        '(${_textoPdf(fila.celdas[i])}) Tj ET',
      );
    }
    y -= 18;
  }

  final flujo = _latin1(contenido.toString());
  final objetos = <List<int>>[
    _latin1('<< /Type /Catalog /Pages 2 0 R >>'),
    _latin1('<< /Type /Pages /Kids [3 0 R] /Count 1 >>'),
    _latin1(
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
      '/Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>',
    ),
    _latin1(
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica '
      '/Encoding /WinAnsiEncoding >>',
    ),
    _latin1(
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold '
      '/Encoding /WinAnsiEncoding >>',
    ),
    [
      ..._latin1('<< /Length ${flujo.length} >>\nstream\n'),
      ...flujo,
      ..._latin1('\nendstream'),
    ],
  ];

  final salida = <int>[..._latin1('%PDF-1.4\n')];
  final posiciones = <int>[];
  for (var i = 0; i < objetos.length; i++) {
    posiciones.add(salida.length);
    salida
      ..addAll(_latin1('${i + 1} 0 obj\n'))
      ..addAll(objetos[i])
      ..addAll(_latin1('\nendobj\n'));
  }
  final inicioXref = salida.length;
  final xref = StringBuffer()
    ..write('xref\n0 ${objetos.length + 1}\n')
    ..write('0000000000 65535 f \n');
  for (final posicion in posiciones) {
    xref.write('${posicion.toString().padLeft(10, '0')} 00000 n \n');
  }
  xref
    ..write('trailer\n<< /Size ${objetos.length + 1} /Root 1 0 R >>\n')
    ..write('startxref\n$inicioXref\n%%EOF\n');
  salida.addAll(_latin1(xref.toString()));
  return Uint8List.fromList(salida);
}

Uint8List generarXlsx(String titulo, List<FilaReporte> filas) {
  final hoja = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/'
    'main"><sheetData>',
  );
  final todas = [
    (celdas: [titulo], encabezado: true),
    (celdas: const <String>[], encabezado: false),
    ...filas,
  ];
  for (var r = 0; r < todas.length; r++) {
    hoja.write('<row r="${r + 1}">');
    final celdas = todas[r].celdas;
    for (var c = 0; c < celdas.length && c < 26; c++) {
      final referencia = '${String.fromCharCode(65 + c)}${r + 1}';
      hoja.write(
        '<c r="$referencia" t="inlineStr"><is><t>'
        '${_xml(celdas[c])}</t></is></c>',
      );
    }
    hoja.write('</row>');
  }
  hoja.write('</sheetData></worksheet>');

  const relaciones =
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
  const paquete = 'http://schemas.openxmlformats.org/package/2006';
  const tipoHoja =
      'application/vnd.openxmlformats-officedocument.spreadsheetml';

  return _zip({
    '[Content_Types].xml':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="$paquete/content-types">'
        '<Default Extension="rels" '
        'ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" '
        'ContentType="$tipoHoja.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" '
        'ContentType="$tipoHoja.worksheet+xml"/>'
        '</Types>',
    '_rels/.rels':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="$paquete/relationships">'
        '<Relationship Id="rId1" Type="$relaciones/officeDocument" '
        'Target="xl/workbook.xml"/></Relationships>',
    'xl/workbook.xml':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/'
        '2006/main" xmlns:r="$relaciones"><sheets>'
        '<sheet name="Reporte" sheetId="1" r:id="rId1"/></sheets></workbook>',
    'xl/_rels/workbook.xml.rels':
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="$paquete/relationships">'
        '<Relationship Id="rId1" Type="$relaciones/worksheet" '
        'Target="worksheets/sheet1.xml"/></Relationships>',
    'xl/worksheets/sheet1.xml': hoja.toString(),
  });
}

String _textoPdf(String texto) => texto
    .replaceAll('→', '->')
    .replaceAll(r'\', r'\\')
    .replaceAll('(', r'\(')
    .replaceAll(')', r'\)');

List<int> _latin1(String texto) =>
    texto.runes.map((r) => r < 256 ? r : 0x3F).toList();

String _xml(String texto) => texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

Uint8List _zip(Map<String, String> archivos) {
  final salida = BytesBuilder();
  final central = BytesBuilder();
  for (final MapEntry(key: nombre, value: contenido) in archivos.entries) {
    final datos = utf8.encode(contenido);
    final nombreBytes = utf8.encode(nombre);
    final crc = _crc32(datos);
    final posicion = salida.length;
    salida
      ..add(_enteros([0x04034b50], 4))
      ..add(_enteros([20, 0, 0, 0, 0x21], 2))
      ..add(_enteros([crc, datos.length, datos.length], 4))
      ..add(_enteros([nombreBytes.length, 0], 2))
      ..add(nombreBytes)
      ..add(datos);
    central
      ..add(_enteros([0x02014b50], 4))
      ..add(_enteros([20, 20, 0, 0, 0, 0x21], 2))
      ..add(_enteros([crc, datos.length, datos.length], 4))
      ..add(_enteros([nombreBytes.length, 0, 0, 0, 0], 2))
      ..add(_enteros([0, posicion], 4))
      ..add(nombreBytes);
  }
  final inicioCentral = salida.length;
  final tamanoCentral = central.length;
  salida
    ..add(central.takeBytes())
    ..add(_enteros([0x06054b50], 4))
    ..add(_enteros([0, 0, archivos.length, archivos.length], 2))
    ..add(_enteros([tamanoCentral, inicioCentral], 4))
    ..add(_enteros([0], 2));
  return salida.takeBytes();
}

Uint8List _enteros(List<int> valores, int bytesPorValor) {
  final datos = ByteData(valores.length * bytesPorValor);
  for (var i = 0; i < valores.length; i++) {
    if (bytesPorValor == 4) {
      datos.setUint32(i * 4, valores[i], Endian.little);
    } else {
      datos.setUint16(i * 2, valores[i], Endian.little);
    }
  }
  return datos.buffer.asUint8List();
}

final List<int> _tablaCrc = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
  }
  return c;
});

int _crc32(List<int> datos) {
  var crc = 0xFFFFFFFF;
  for (final byte in datos) {
    crc = _tablaCrc[(crc ^ byte) & 0xFF] ^ (crc >>> 8);
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
