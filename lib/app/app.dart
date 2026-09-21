import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/sesion/sesion_controller.dart';
import 'dependencias.dart';
import 'rutas.dart';

class AsistenteReadinessApp extends StatefulWidget {
  const AsistenteReadinessApp({required this.dependencias, super.key});

  final Dependencias dependencias;

  @override
  State<AsistenteReadinessApp> createState() => _AsistenteReadinessAppState();
}

class _AsistenteReadinessAppState extends State<AsistenteReadinessApp> {
  late final SesionController _sesion;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final dependencias = widget.dependencias;
    _sesion = SesionController(
      auth: dependencias.auth,
      storage: dependencias.sesionStorage,
      sesionExpirada: dependencias.apiClient.sesionExpirada,
    );
    _router = crearRouter(_sesion);
    unawaited(_sesion.verificarSesionGuardada());
  }

  @override
  void dispose() {
    _router.dispose();
    _sesion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencias = widget.dependencias;
    return MultiProvider(
      providers: [
        Provider.value(value: dependencias.auth),
        Provider.value(value: dependencias.appraisals),
        Provider.value(value: dependencias.documentos),
        Provider.value(value: dependencias.asistente),
        Provider.value(value: dependencias.preferencias),
        ChangeNotifierProvider.value(value: _sesion),
      ],
      child: MaterialApp.router(
        title: 'Asistente Readiness',
        debugShowCheckedModeBanner: false,
        theme: _tema(Brightness.light),
        darkTheme: _tema(Brightness.dark),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: _router,
      ),
    );
  }

  static ThemeData _tema(Brightness brillo) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E5AA8),
      brightness: brillo,
    ),
  );
}
