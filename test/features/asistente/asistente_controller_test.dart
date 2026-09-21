import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/permisos/permisos.dart';
import 'package:fme_mobile_project/data/models/appraisal.dart';
import 'package:fme_mobile_project/data/repositories/asistente_repository.dart';
import 'package:fme_mobile_project/features/asistente/asistente_controller.dart';
import 'package:fme_mobile_project/features/asistente/servicios/archivos_reporte.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/dobles.dart';

const _appraisalPrueba = Appraisal(
  id: 3,
  nombre: 'Appraisal ML2',
  proyecto: 'P',
);

const _respuesta = {
  'resumen_voz': 'Te faltan dos gaps altos.',
  'reporte_markdown': '## Qué falta\n- Gap 1',
  'tipo_reporte': 'que_nos_falta',
};

const _respuestaConPdf = {
  ..._respuesta,
  'archivo': {
    'id': 'r1',
    'formato': 'pdf',
    'nombre': 'reporte.pdf',
    'url': '/api/asistente/archivos/r1/descarga',
  },
};

class _Prueba {
  _Prueba({
    MockClientHandler? servidor,
    Appraisal? appraisal = _appraisalPrueba,
    DateTime Function()? reloj,
  }) : _appraisal = appraisal {
    controlador = AsistenteController(
      repositorio: AsistenteRepository(
        apiDePrueba(
          servidor ??
              (peticion) async {
                preguntas.add(
                  (jsonDecode(peticion.body)
                          as Map<String, dynamic>)['pregunta']
                      as String,
                );
                return respuestaJson(200, _respuesta);
              },
        ),
      ),
      reconocedor: reconocedor,
      lector: lector,
      archivos: archivos,
      appraisalActivo: () => _appraisal,
      reloj: reloj,
    );
  }

  final Appraisal? _appraisal;
  final reconocedor = ReconocedorFalso();
  final lector = LectorFalso();
  final archivos = ArchivosFalsos();
  final preguntas = <String>[];
  late final AsistenteController controlador;
}

Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'flujo de voz: escucha, transcribe, envía y lee solo el resumen',
    () async {
      final prueba = _Prueba();
      final controlador = prueba.controlador;

      await controlador.alternarMicrofono();
      expect(controlador.estado, EstadoAsistente.escuchando);

      prueba.reconocedor.decir('qué nos');
      expect(controlador.transcripcion, 'qué nos');

      prueba.reconocedor.decir('qué nos falta', esFinal: true);
      await _esperar();
      await _esperar();

      expect(prueba.preguntas, ['qué nos falta']);
      expect(controlador.estado, EstadoAsistente.respondiendo);
      expect(prueba.lector.leidos, ['Te faltan dos gaps altos.']);
      expect(
        controlador.intercambios.single.respuesta?.reporteMarkdown,
        startsWith('## Qué falta'),
      );

      prueba.lector.terminarLectura();
      expect(controlador.estado, EstadoAsistente.inactivo);
    },
  );

  test('tocar el micrófono mientras escucha detiene y envía', () async {
    final prueba = _Prueba();
    await prueba.controlador.alternarMicrofono();
    prueba.reconocedor.decir('dame los gaps críticos');

    await prueba.controlador.alternarMicrofono();
    prueba.reconocedor.terminar();
    await _esperar();
    await _esperar();

    expect(prueba.reconocedor.detenciones, 1);
    expect(prueba.preguntas, ['dame los gaps críticos']);
  });

  test('silencio sin palabras no envía nada y avisa', () async {
    final prueba = _Prueba();
    await prueba.controlador.alternarMicrofono();

    prueba.reconocedor.terminar();

    expect(prueba.preguntas, isEmpty);
    expect(prueba.controlador.estado, EstadoAsistente.inactivo);
    expect(prueba.controlador.aviso, startsWith('No te escuché'));
  });

  test('un error de reconocimiento se explica en español', () async {
    final prueba = _Prueba();
    await prueba.controlador.alternarMicrofono();

    prueba.reconocedor.fallar('error_network');

    expect(prueba.controlador.aviso, contains('conexión a internet'));
  });

  test('permiso de micrófono denegado deja usar las sugerencias', () async {
    final prueba = _Prueba();
    prueba.reconocedor.permiso = ResultadoPermiso.denegadoPermanente;

    await prueba.controlador.alternarMicrofono();

    expect(prueba.controlador.microfono, AccesoMicrofono.bloqueado);
    expect(prueba.controlador.puedePreguntar, isTrue);

    await prueba.controlador.preguntar(
      AsistenteController.preguntasSugeridas.first,
    );
    expect(prueba.preguntas, ['¿Qué nos falta para estar listos?']);
  });

  test('sin reconocimiento de voz en el teléfono lo indica', () async {
    final prueba = _Prueba();
    prueba.reconocedor.disponible = false;

    await prueba.controlador.alternarMicrofono();

    expect(prueba.controlador.microfono, AccesoMicrofono.noDisponible);
    expect(prueba.controlador.microfonoHabilitado, isFalse);
  });

  test('sin appraisal seleccionado el micrófono queda deshabilitado', () async {
    final prueba = _Prueba(appraisal: null);

    await prueba.controlador.alternarMicrofono();
    await prueba.controlador.preguntar('hola');

    expect(prueba.controlador.microfonoHabilitado, isFalse);
    expect(prueba.controlador.estado, EstadoAsistente.inactivo);
    expect(prueba.controlador.intercambios, isEmpty);
  });

  test('un 429 bloquea las preguntas según Retry-After', () async {
    var ahora = DateTime(2026, 9, 21, 15);
    final prueba = _Prueba(
      reloj: () => ahora,
      servidor: (_) async =>
          http.Response('{}', 429, headers: {'retry-after': '20'}),
    );

    await prueba.controlador.preguntar('¿Qué nos falta?');

    expect(prueba.controlador.estaBloqueado, isTrue);
    expect(prueba.controlador.segundosDeEspera, 20);
    expect(prueba.controlador.puedePreguntar, isFalse);
    expect(
      prueba.controlador.intercambios.single.error?.mensaje,
      contains('20 segundos'),
    );

    ahora = ahora.add(const Duration(seconds: 21));
    expect(prueba.controlador.puedePreguntar, isTrue);
    prueba.controlador.dispose();
  });

  test('un 503 permite reintentar la misma pregunta', () async {
    var intentos = 0;
    final prueba = _Prueba(
      servidor: (_) async {
        intentos++;
        return intentos == 1
            ? respuestaJson(503, {})
            : respuestaJson(200, _respuesta);
      },
    );

    await prueba.controlador.preguntar('¿Qué nos falta?');
    final intercambio = prueba.controlador.intercambios.single;
    expect(intercambio.error?.esReintentable, isTrue);

    await prueba.controlador.reintentar(intercambio);

    expect(intercambio.error, isNull);
    expect(intercambio.respuesta, isNotNull);
    expect(prueba.controlador.intercambios, hasLength(1));
  });

  test('descarga y abre el PDF del reporte', () async {
    final prueba = _Prueba(
      servidor: (peticion) async => peticion.method == 'POST'
          ? respuestaJson(200, _respuestaConPdf)
          : http.Response.bytes(utf8.encode('%PDF'), 200),
    );
    await prueba.controlador.preguntar('Genera el reporte en PDF');
    final intercambio = prueba.controlador.intercambios.single;

    await prueba.controlador.abrirArchivo(intercambio);

    expect(intercambio.estadoArchivo, EstadoArchivo.listo);
    expect(prueba.archivos.guardados.keys, ['reporte.pdf']);
    expect(prueba.archivos.abiertos, ['reporte.pdf']);
  });

  test('sin app para abrir el archivo sugiere guardarlo', () async {
    final prueba = _Prueba(
      servidor: (peticion) async => peticion.method == 'POST'
          ? respuestaJson(200, _respuestaConPdf)
          : http.Response.bytes([1], 200),
    );
    prueba.archivos.resultadoApertura = ResultadoApertura.sinAplicacion;
    await prueba.controlador.preguntar('Genera el reporte en PDF');
    final intercambio = prueba.controlador.intercambios.single;

    await prueba.controlador.abrirArchivo(intercambio);

    expect(intercambio.avisoArchivo, contains('Usa "Guardar"'));
  });

  test('un archivo vencido muestra el motivo', () async {
    final prueba = _Prueba(
      servidor: (peticion) async => peticion.method == 'POST'
          ? respuestaJson(200, _respuestaConPdf)
          : respuestaJson(410, {}),
    );
    await prueba.controlador.preguntar('Genera el reporte en PDF');
    final intercambio = prueba.controlador.intercambios.single;

    await prueba.controlador.abrirArchivo(intercambio);

    expect(intercambio.estadoArchivo, EstadoArchivo.fallido);
    expect(intercambio.avisoArchivo, contains('ya no está disponible'));
  });

  test('compartir envía el texto del reporte', () async {
    final prueba = _Prueba();
    await prueba.controlador.preguntar('¿Qué nos falta?');

    await prueba.controlador.compartirReporte(
      prueba.controlador.intercambios.single,
    );

    expect(prueba.archivos.textosCompartidos, ['## Qué falta\n- Gap 1']);
  });

  test('una nueva pregunta detiene la lectura en curso', () async {
    final prueba = _Prueba();
    await prueba.controlador.preguntar('primera');
    expect(prueba.controlador.estado, EstadoAsistente.respondiendo);

    final segunda = Completer<void>();
    unawaited(prueba.controlador.preguntar('segunda').then(segunda.complete));
    await segunda.future;

    expect(prueba.preguntas, ['primera', 'segunda']);
    expect(prueba.controlador.intercambios, hasLength(2));
  });
}
