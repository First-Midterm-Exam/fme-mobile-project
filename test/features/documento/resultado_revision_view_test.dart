import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/app/tema.dart';
import 'package:fme_mobile_project/data/models/revision_formato.dart';
import 'package:fme_mobile_project/features/documento/resultado_revision_view.dart';

Future<void> _mostrar(WidgetTester tester, RevisionFormato resultado) {
  return tester.pumpWidget(
    MaterialApp(
      theme: TemaApp.claro(),
      home: Scaffold(
        body: ResultadoRevisionView(resultado: resultado, alRevisarOtro: () {}),
      ),
    ),
  );
}

void main() {
  final noCumple = RevisionFormato.fromJson({
    'cumple': false,
    'puntaje': 72,
    'tipo_detectado': 'Plan de Proyecto',
    'resumen': 'Le faltan secciones.',
    'hallazgos': [
      {'severidad': 'baja', 'elemento': 'Encabezado', 'mensaje': 'b'},
      {'severidad': 'media', 'elemento': 'Responsables', 'mensaje': 'm'},
      {'severidad': 'alta', 'elemento': 'Cronograma', 'mensaje': 'a'},
    ],
  });

  testWidgets('muestra la insignia roja, el puntaje y el tipo', (tester) async {
    await _mostrar(tester, noCumple);

    expect(find.text('No cumple el formato'), findsOneWidget);
    final insignia = tester.widget<Container>(
      find.byKey(ResultadoRevisionView.claveInsignia),
    );
    final decoracion = insignia.decoration! as BoxDecoration;
    expect(decoracion.color, ColoresEstado.claro.peligroFondo);
    expect(
      tester.widget<Text>(find.byKey(ResultadoRevisionView.clavePuntaje)).data,
      '72',
    );
    expect(find.text('Plan de Proyecto'), findsOneWidget);
    expect(find.text('Le faltan secciones.'), findsOneWidget);
  });

  testWidgets('ordena los hallazgos de alta a baja', (tester) async {
    await _mostrar(tester, noCumple);

    final alta = tester.getTopLeft(find.text('Cronograma')).dy;
    final media = tester.getTopLeft(find.text('Responsables')).dy;
    final baja = tester.getTopLeft(find.text('Encabezado')).dy;

    expect(alta, lessThan(media));
    expect(media, lessThan(baja));
    expect(find.text('HALLAZGOS (3)'), findsOneWidget);
  });

  testWidgets('muestra la insignia verde cuando cumple', (tester) async {
    await _mostrar(
      tester,
      RevisionFormato.fromJson({'cumple': true, 'puntaje': 95}),
    );

    expect(find.text('Cumple el formato'), findsOneWidget);
    final insignia = tester.widget<Container>(
      find.byKey(ResultadoRevisionView.claveInsignia),
    );
    final decoracion = insignia.decoration! as BoxDecoration;
    expect(decoracion.color, ColoresEstado.claro.exitoFondo);
    expect(find.text('No se encontraron hallazgos.'), findsOneWidget);
    expect(find.text('No identificado'), findsOneWidget);
  });
}
