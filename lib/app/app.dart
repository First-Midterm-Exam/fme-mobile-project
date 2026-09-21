import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/appraisals/appraisal_controller.dart';
import '../features/sesion/sesion_controller.dart';
import 'dependencias.dart';
import 'rutas.dart';
import 'tema.dart';

class AsistenteReadinessApp extends StatefulWidget {
  const AsistenteReadinessApp({required this.dependencias, super.key});

  final Dependencias dependencias;

  @override
  State<AsistenteReadinessApp> createState() => _AsistenteReadinessAppState();
}

class _AsistenteReadinessAppState extends State<AsistenteReadinessApp> {
  late final SesionController _sesion;
  late final AppraisalController _appraisals;
  late final GoRouter _router;
  EstadoSesion? _estadoAnterior;

  @override
  void initState() {
    super.initState();
    final dependencias = widget.dependencias;
    _sesion = SesionController(
      auth: dependencias.auth,
      storage: dependencias.sesionStorage,
      sesionExpirada: dependencias.apiClient.sesionExpirada,
    );
    _appraisals = AppraisalController(
      repositorio: dependencias.appraisals,
      preferencias: dependencias.preferencias,
    );
    _sesion.addListener(_alCambiarSesion);
    _router = crearRouter(_sesion, _appraisals);
    unawaited(_sesion.verificarSesionGuardada());
  }

  /// Carga los appraisals al iniciar sesión y los olvida al cerrarla.
  void _alCambiarSesion() {
    final estado = _sesion.estado;
    if (estado == _estadoAnterior) {
      return;
    }
    _estadoAnterior = estado;
    if (estado == EstadoSesion.autenticada) {
      unawaited(_appraisals.cargar());
    } else {
      _appraisals.reiniciar();
    }
  }

  @override
  void dispose() {
    _sesion.removeListener(_alCambiarSesion);
    _router.dispose();
    _appraisals.dispose();
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
        Provider.value(value: dependencias.camara),
        ChangeNotifierProvider.value(value: _sesion),
        ChangeNotifierProvider.value(value: _appraisals),
      ],
      child: MaterialApp.router(
        title: 'Asistente Readiness',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.claro(),
        darkTheme: TemaApp.oscuro(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: _router,
      ),
    );
  }
}
