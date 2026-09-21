import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.usarSimulacion});

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

  final Uri apiBaseUrl;

  final bool usarSimulacion;

  static Future<AppConfig> cargar({String archivo = '.env'}) async {
    await dotenv.load(fileName: archivo);
    return AppConfig.desdeMapa(dotenv.env);
  }
}
