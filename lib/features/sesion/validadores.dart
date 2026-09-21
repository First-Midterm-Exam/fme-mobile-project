/// Validaciones locales del formulario de inicio de sesión.
///
/// Devuelven `null` si el valor es válido o el mensaje de error en español.
abstract final class Validadores {
  static final _formatoCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? correo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return 'Ingresa tu correo.';
    }
    if (!_formatoCorreo.hasMatch(texto)) {
      return 'Ingresa un correo válido, por ejemplo nombre@empresa.com.';
    }
    return null;
  }

  static String? contrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    return null;
  }
}
