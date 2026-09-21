import 'dart:typed_data';

import 'archivos_simulados.dart';

const emailRegistrado = 'mfernandez@empresa.com';
const passwordRegistrado = 'Readiness2026';
const tokenSimulado = 'token-simulado-asistente-movil';

const Map<String, Object?> usuarioSimulado = {
  'id': 1,
  'nombre': 'María Fernández',
  'email': emailRegistrado,
  'rol': {'id': 2, 'nombre': 'Gestor de Procesos'},
};

const Map<String, Object?> appraisalsSimulados = {
  'data': [
    {
      'id': 3,
      'nombre': 'Appraisal ML2 2026',
      'proyecto': 'Sistema de Facturación',
      'nivel_objetivo': 2,
      'fecha_meta': '2026-11-30',
    },
    {
      'id': 5,
      'nombre': 'Appraisal ML3 2027',
      'proyecto': 'Portal de Clientes',
      'nivel_objetivo': 3,
      'fecha_meta': '2027-04-15',
    },
  ],
};

const Map<String, Object?> revisionFormatoSimulada = {
  'cumple': false,
  'puntaje': 72,
  'tipo_detectado': 'Plan de Proyecto',
  'resumen':
      'El documento tiene la estructura general pero le faltan secciones.',
  'hallazgos': [
    {
      'severidad': 'media',
      'elemento': 'Responsables',
      'mensaje': 'La tabla de responsables está incompleta.',
    },
    {
      'severidad': 'baja',
      'elemento': 'Encabezado',
      'mensaje': 'El encabezado no indica la versión del documento.',
    },
    {
      'severidad': 'alta',
      'elemento': 'Cronograma',
      'mensaje': 'No se encontró la sección de cronograma.',
    },
  ],
};

const Map<String, Map<String, Object?>> respuestasAsistenteSimuladas = {
  'que_nos_falta': {
    'resumen_voz':
        'Te faltan dos gaps altos y cinco evidencias sin verificar. '
        'El Readiness Score actual es 68 por ciento.',
    'reporte_markdown':
        '## Qué falta para el appraisal\n\n'
        '**Readiness Score:** 68 %\n\n'
        '### Gaps altos abiertos\n'
        '- **PP 2.1** Estimaciones sin evidencia de revisión.\n'
        '- **MC 2.3** Seguimiento de riesgos sin actas recientes.\n\n'
        '### Evidencias sin verificar\n'
        '| Práctica | Evidencia | Responsable |\n'
        '|---|---|---|\n'
        '| REQM 2.1 | Matriz de trazabilidad | Ana Rojas |\n'
        '| PP 2.2 | Plan de proyecto v3 | Luis Paz |\n'
        '| CM 2.1 | Línea base de configuración | Ana Rojas |\n'
        '| PPQA 2.1 | Checklist de auditoría | Carlos Vega |\n'
        '| MC 2.1 | Informe de avance semanal | Luis Paz |\n',
    'tipo_reporte': 'que_nos_falta',
    'generado_en': '2026-09-21T15:04:00Z',
  },
  'gaps_criticos': {
    'resumen_voz':
        'Hay dos gaps críticos abiertos, ambos en planificación y '
        'monitoreo del proyecto.',
    'reporte_markdown':
        '## Gaps críticos\n\n'
        '1. **PP 2.1** Estimaciones sin evidencia de revisión. '
        'Acción correctiva vence el 30/09.\n'
        '2. **MC 2.3** Seguimiento de riesgos sin actas recientes. '
        'Sin acción correctiva asignada.\n',
    'tipo_reporte': 'gaps_criticos',
    'generado_en': '2026-09-21T15:04:00Z',
  },
  'acciones_vencidas': {
    'resumen_voz': 'Tienes tres acciones correctivas vencidas.',
    'reporte_markdown':
        '## Acciones correctivas vencidas\n\n'
        '| Acción | Responsable | Venció |\n'
        '|---|---|---|\n'
        '| Actualizar plan de riesgos | Luis Paz | 15/09/2026 |\n'
        '| Completar matriz RACI | Ana Rojas | 12/09/2026 |\n'
        '| Registrar revisión de pares | Carlos Vega | 10/09/2026 |\n',
    'tipo_reporte': 'acciones_vencidas',
    'generado_en': '2026-09-21T15:04:00Z',
  },
  'cumplimiento_area': {
    'resumen_voz':
        'Gestión de proyectos va al 74 por ciento, soporte al 61 y '
        'calidad al 70.',
    'reporte_markdown':
        '## Cumplimiento por área\n\n'
        '| Área | Cumplimiento |\n'
        '|---|---|\n'
        '| Gestión de proyectos | 74 % |\n'
        '| Soporte | 61 % |\n'
        '| Calidad | 70 % |\n',
    'tipo_reporte': 'cumplimiento_area',
    'generado_en': '2026-09-21T15:04:00Z',
  },
  'progreso_semanal': {
    'resumen_voz':
        'Sí, el Readiness Score subió cuatro puntos esta semana, de 64 a 68.',
    'reporte_markdown':
        '## Progreso de la semana\n\n'
        '- Readiness Score: **64 % → 68 %**\n'
        '- Evidencias verificadas: 6\n'
        '- Gaps cerrados: 2\n',
    'tipo_reporte': 'progreso_semanal',
    'generado_en': '2026-09-21T15:04:00Z',
  },
  'general': {
    'resumen_voz':
        'El appraisal está al 68 por ciento de preparación. Puedes '
        'preguntarme por gaps, acciones vencidas o cumplimiento por área.',
    'reporte_markdown':
        '## Estado general\n\n'
        '- Readiness Score: **68 %**\n'
        '- Gaps abiertos: 7 (2 altos)\n'
        '- Acciones vencidas: 3\n',
    'tipo_reporte': 'general',
    'generado_en': '2026-09-21T15:04:00Z',
  },
};

String _claveRespuesta(String texto) => switch (texto) {
  _ when texto.contains('falta') => 'que_nos_falta',
  _ when texto.contains('gap') => 'gaps_criticos',
  _ when texto.contains('vencid') => 'acciones_vencidas',
  _ when texto.contains('área') || texto.contains('area') =>
    'cumplimiento_area',
  _ when texto.contains('semana') || texto.contains('mejor') =>
    'progreso_semanal',
  _ => 'general',
};

String? _formatoSolicitado(String texto) {
  if (texto.contains('excel') ||
      texto.contains('xlsx') ||
      texto.contains('hoja de cálculo')) {
    return 'xlsx';
  }
  if (texto.contains('pdf') ||
      texto.contains('reporte') ||
      texto.contains('informe') ||
      texto.contains('exporta')) {
    return 'pdf';
  }
  return null;
}

Map<String, Object?> respuestaAsistenteSimulada(
  String pregunta, {
  required String urlBase,
}) {
  final texto = pregunta.toLowerCase();
  final clave = _claveRespuesta(texto);
  final respuesta = respuestasAsistenteSimuladas[clave]!;
  final formato = _formatoSolicitado(texto);
  if (formato == null) {
    return respuesta;
  }
  final id = '$clave.$formato';
  final nombreFormato = formato == 'pdf' ? 'PDF' : 'Excel';
  return {
    ...respuesta,
    'resumen_voz':
        'Listo. Generé el reporte en $nombreFormato con los datos actuales '
        'del appraisal. Puedes abrirlo o descargarlo desde la respuesta.',
    'archivo': {
      'id': id,
      'formato': formato,
      'nombre': 'reporte-${clave.replaceAll('_', '-')}-2026-09-21.$formato',
      'url': '$urlBase/asistente/archivos/$id/descarga',
      'tamano_bytes': null,
      'expira_en': '2026-09-22T15:04:00Z',
    },
  };
}

Uint8List? archivoSimulado(String id) {
  final partes = id.split('.');
  if (partes.length != 2) {
    return null;
  }
  final respuesta = respuestasAsistenteSimuladas[partes.first];
  if (respuesta == null) {
    return null;
  }
  final tabla = tablaDesdeMarkdown('${respuesta['reporte_markdown']}');
  return switch (partes.last) {
    'pdf' => generarPdf(tabla.titulo, tabla.filas),
    'xlsx' => generarXlsx(tabla.titulo, tabla.filas),
    _ => null,
  };
}
