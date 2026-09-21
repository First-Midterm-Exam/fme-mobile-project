import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../features/appraisals/appraisal_controller.dart';
import '../features/appraisals/seleccion_appraisal_screen.dart';
import '../features/principal/principal_screen.dart';
import '../features/sesion/login_screen.dart';
import '../features/sesion/sesion_controller.dart';

abstract final class Rutas {
  static const login = '/login';
  static const appraisals = '/appraisals';
  static const principal = '/principal';
}

GoRouter crearRouter(SesionController sesion, AppraisalController appraisals) {
  return GoRouter(
    initialLocation: Rutas.login,
    refreshListenable: Listenable.merge([sesion, appraisals]),
    redirect: (context, state) {
      final ubicacion = state.matchedLocation;
      if (sesion.estado != EstadoSesion.autenticada) {
        return ubicacion == Rutas.login ? null : Rutas.login;
      }
      final destino = appraisals.seleccionado == null
          ? Rutas.appraisals
          : Rutas.principal;
      return ubicacion == destino ? null : destino;
    },
    routes: [
      GoRoute(
        path: Rutas.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Rutas.appraisals,
        builder: (context, state) => const SeleccionAppraisalScreen(),
      ),
      GoRoute(
        path: Rutas.principal,
        builder: (context, state) => const PrincipalScreen(),
      ),
    ],
  );
}
