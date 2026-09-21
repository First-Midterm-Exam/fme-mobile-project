import '../../core/network/api_client.dart';
import '../../core/network/lectura_json.dart';
import '../models/usuario.dart';

class AuthRepository {
  const AuthRepository(this._api);

  static const nombreDispositivo = 'asistente-movil';

  /// Mensajes de login que no revelan si el correo existe.
  static const mensajesLogin = {
    401: 'El correo o la contraseña no son correctos.',
    422: 'El correo o la contraseña no son correctos.',
  };

  final ApiClient _api;

  Future<SesionIniciada> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final json = await _api.post(
      '/login',
      cuerpo: {
        'email': email,
        'password': password,
        'device_name': nombreDispositivo,
      },
      autenticado: false,
      mensajes: mensajesLogin,
    );
    return parsearRespuesta(() => SesionIniciada.fromJson(json));
  }

  Future<void> cerrarSesion() => _api.post('/logout');

  Future<Usuario> usuarioActual() async {
    final json = await _api.get('/me');
    return parsearRespuesta(() => Usuario.fromJson(json));
  }
}
