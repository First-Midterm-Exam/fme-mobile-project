import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de la app leída desde el archivo `.env`.
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.usarSimulacion});

  /// Construye la configuración a partir de un mapa de variables.
  ///
  /// Lanza [StateError] si `API_BASE_URL` falta o no es una URL http(s).
  factory AppConfig.desdeMapa(Map<String, String> variables) {
    final urlTexto = variables['API_BASE_URL']?.trim() ?? '';
    final url = Uri.tryParse(urlTexto);
    if (url == null || !url.hasScheme || !url.scheme.startsWith('http')) {
      throw StateError(
        'API_BASE_URL no está configurada o no es válida en el archivo .env.',
      );
    }
    final simulacion = variables['USE_MOCK']?.trim().toLowerCase() ?? 'false';
    return AppConfig(apiBaseUrl: url, usarSimulacion: simulacion == 'true');
  }

  /// URL base de la API, incluido el prefijo `/api`.
  final Uri apiBaseUrl;

  /// Si es `true`, las peticiones se responden con datos simulados.
  final bool usarSimulacion;

  /// Carga el archivo `.env` empaquetado como asset.
  static Future<AppConfig> cargar({String archivo = '.env'}) async {
    await dotenv.load(fileName: archivo);
    return AppConfig.desdeMapa(dotenv.env);
  }
}
