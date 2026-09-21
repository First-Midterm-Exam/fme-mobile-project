import 'package:go_router/go_router.dart';

import '../features/appraisals/seleccion_appraisal_screen.dart';
import '../features/principal/principal_screen.dart';
import '../features/sesion/login_screen.dart';
import '../features/sesion/sesion_controller.dart';

abstract final class Rutas {
  static const login = '/login';
  static const appraisals = '/appraisals';
  static const principal = '/principal';
}

/// Router de la app. Se reevalúa cada vez que cambia la sesión: sin sesión
/// siempre se muestra el login; con sesión, el login redirige a appraisals.
GoRouter crearRouter(SesionController sesion) {
  return GoRouter(
    initialLocation: Rutas.login,
    refreshListenable: sesion,
    redirect: (context, state) {
      final enLogin = state.matchedLocation == Rutas.login;
      if (sesion.estado != EstadoSesion.autenticada) {
        return enLogin ? null : Rutas.login;
      }
      return enLogin ? Rutas.appraisals : null;
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
