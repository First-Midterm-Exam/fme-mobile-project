import 'package:permission_handler/permission_handler.dart';

enum ResultadoPermiso { concedido, denegado, denegadoPermanente }

Future<ResultadoPermiso> pedirPermiso(Permission permiso) async {
  final estado = await permiso.request();
  if (estado.isGranted || estado.isLimited) {
    return ResultadoPermiso.concedido;
  }
  if (estado.isPermanentlyDenied || estado.isRestricted) {
    return ResultadoPermiso.denegadoPermanente;
  }
  return ResultadoPermiso.denegado;
}

Future<void> abrirAjustesDeLaApp() => openAppSettings();
