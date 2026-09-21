import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/features/sesion/login_screen.dart';
import 'package:fme_mobile_project/features/sesion/sesion_controller.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../helpers/sesion_de_prueba.dart';

Future<void> _mostrarFormulario(
  WidgetTester tester,
  SesionController sesion,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: sesion,
      child: const MaterialApp(home: Scaffold(body: FormularioLogin())),
    ),
  );
}

FilledButton _botonIngresar(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(FormularioLogin.claveIngresar));

void main() {
  testWidgets('valida campos vacíos y correo con formato inválido', (
    tester,
  ) async {
    var peticiones = 0;
    final prueba = SesionDePrueba((_) async {
      peticiones++;
      return http.Response('{}', 500);
    });
    await _mostrarFormulario(tester, prueba.controller);

    await tester.tap(find.byKey(FormularioLogin.claveIngresar));
    await tester.pump();

    expect(find.text('Ingresa tu correo.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);

    await tester.enterText(find.byKey(FormularioLogin.claveCorreo), 'maria');
    await tester.pump();

    expect(find.textContaining('Ingresa un correo válido'), findsOneWidget);
    expect(peticiones, 0);
  });

  testWidgets('deshabilita "Ingresar" mientras espera la respuesta', (
    tester,
  ) async {
    final respuesta = Completer<http.Response>();
    final prueba = SesionDePrueba((_) => respuesta.future);
    await _mostrarFormulario(tester, prueba.controller);

    await tester.enterText(
      find.byKey(FormularioLogin.claveCorreo),
      'maria@empresa.com',
    );
    await tester.enterText(
      find.byKey(FormularioLogin.claveContrasena),
      'secreta',
    );
    await tester.tap(find.byKey(FormularioLogin.claveIngresar));
    await tester.pump();

    expect(_botonIngresar(tester).onPressed, isNull);
    expect(find.text('Ingresando...'), findsOneWidget);

    respuesta.complete(http.Response('{}', 401));
    await tester.pumpAndSettle();

    expect(_botonIngresar(tester).onPressed, isNotNull);
    expect(
      find.text('El correo o la contraseña no son correctos.'),
      findsOneWidget,
    );
  });
}
