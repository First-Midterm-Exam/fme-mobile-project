import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/preferencias_storage.dart';
import '../core/storage/sesion_storage.dart';
import '../data/repositories/appraisal_repository.dart';
import '../data/repositories/asistente_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/documento_repository.dart';
import '../data/simulacion/backend_simulado.dart';
import '../features/documento/camara_documentos.dart';

/// Objetos compartidos por toda la app, creados una sola vez al arrancar.
class Dependencias {
  Dependencias._({
    required this.config,
    required this.apiClient,
    required this.sesionStorage,
    required this.preferencias,
  }) : auth = AuthRepository(apiClient),
       appraisals = AppraisalRepository(apiClient),
       documentos = DocumentoRepository(apiClient),
       asistente = AsistenteRepository(apiClient);

  static Future<Dependencias> crear(AppConfig config) async {
    final sesionStorage = SesionStorage();
    final preferencias = await PreferenciasStorage.crear();
    final httpClient = config.usarSimulacion
        ? BackendSimulado(baseUrl: config.apiBaseUrl)
        : http.Client();
    final apiClient = ApiClient(
      baseUrl: config.apiBaseUrl,
      httpClient: httpClient,
      leerToken: () => sesionStorage.token,
    );
    return Dependencias._(
      config: config,
      apiClient: apiClient,
      sesionStorage: sesionStorage,
      preferencias: preferencias,
    );
  }

  final AppConfig config;
  final ApiClient apiClient;
  final SesionStorage sesionStorage;
  final PreferenciasStorage preferencias;
  final AuthRepository auth;
  final AppraisalRepository appraisals;
  final DocumentoRepository documentos;
  final AsistenteRepository asistente;

  /// Tipada como la interfaz para que las pruebas puedan reemplazarla.
  final CamaraDocumentos camara = CamaraDelSistema();
}
