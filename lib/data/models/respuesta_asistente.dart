import '../../core/network/lectura_json.dart';

enum FormatoArchivo {
  pdf('PDF', 'application/pdf'),
  excel(
    'Excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );

  const FormatoArchivo(this.etiqueta, this.tipoMime);

  final String etiqueta;
  final String tipoMime;

  static FormatoArchivo? desdeTexto(String? texto) =>
      switch (texto?.trim().toLowerCase()) {
        'pdf' => FormatoArchivo.pdf,
        'xlsx' || 'excel' => FormatoArchivo.excel,
        _ => null,
      };
}

class ArchivoReporte {
  const ArchivoReporte({
    required this.id,
    required this.formato,
    required this.nombre,
    required this.url,
    this.tamanoBytes,
    this.expiraEn,
  });

  factory ArchivoReporte.fromJson(Map<String, dynamic> json) {
    final formato = FormatoArchivo.desdeTexto(json.textoOpcional('formato'));
    if (formato == null) {
      throw const FormatException('Formato de archivo desconocido.');
    }
    final id = json.textoRequerido('id');
    final nombre = json.texto('nombre');
    final url = json.textoRequerido('url');
    if (Uri.tryParse(url) == null) {
      throw const FormatException('URL de archivo inválida.');
    }
    return ArchivoReporte(
      id: id,
      formato: formato,
      nombre: nombre.isEmpty
          ? 'reporte-$id.${formato == FormatoArchivo.pdf ? 'pdf' : 'xlsx'}'
          : nombre,
      url: url,
      tamanoBytes: json.enteroOpcional('tamano_bytes'),
      expiraEn: json.fechaOpcional('expira_en'),
    );
  }

  final String id;
  final FormatoArchivo formato;
  final String nombre;
  final String url;
  final int? tamanoBytes;
  final DateTime? expiraEn;
}

class RespuestaAsistente {
  const RespuestaAsistente({
    required this.resumenVoz,
    required this.reporteMarkdown,
    this.tipoReporte,
    this.generadoEn,
    this.archivo,
  });

  factory RespuestaAsistente.fromJson(Map<String, dynamic> json) {
    final resumen = json.texto('resumen_voz');
    final reporte = json.texto('reporte_markdown');
    if (resumen.isEmpty && reporte.isEmpty) {
      throw const FormatException('La respuesta del asistente está vacía.');
    }
    return RespuestaAsistente(
      resumenVoz: resumen,
      reporteMarkdown: reporte,
      tipoReporte: json.textoOpcional('tipo_reporte'),
      generadoEn: json.fechaOpcional('generado_en'),
      archivo: _leerArchivo(json.objetoOpcional('archivo')),
    );
  }

  final String resumenVoz;
  final String reporteMarkdown;
  final String? tipoReporte;
  final DateTime? generadoEn;
  final ArchivoReporte? archivo;

  static ArchivoReporte? _leerArchivo(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    try {
      return ArchivoReporte.fromJson(json);
    } on FormatException {
      return null;
    }
  }
}
