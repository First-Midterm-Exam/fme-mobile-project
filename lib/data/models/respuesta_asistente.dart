import '../../core/network/lectura_json.dart';

/// Resultado de `POST /asistente/consultas`.
class RespuestaAsistente {
  const RespuestaAsistente({
    required this.resumenVoz,
    required this.reporteMarkdown,
    this.tipoReporte,
    this.generadoEn,
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
    );
  }

  /// Texto corto que se lee en voz alta.
  final String resumenVoz;

  /// Reporte completo que se muestra en pantalla.
  final String reporteMarkdown;
  final String? tipoReporte;
  final DateTime? generadoEn;
}
