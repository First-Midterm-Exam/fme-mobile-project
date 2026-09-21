import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fme_mobile_project/core/network/api_client.dart';
import 'package:fme_mobile_project/core/storage/sesion_storage.dart';
import 'package:fme_mobile_project/data/repositories/auth_repository.dart';
import 'package:fme_mobile_project/features/sesion/sesion_controller.dart';
import 'package:http/testing.dart';

class SesionDePrueba {
  SesionDePrueba(
    MockClientHandler manejador, {
    Map<String, String> almacenamientoInicial = const {},
  }) {
    FlutterSecureStorage.setMockInitialValues(Map.of(almacenamientoInicial));
    storage = SesionStorage();
    api = ApiClient(
      baseUrl: Uri.parse('http://servidor.test/api'),
      httpClient: MockClient(manejador),
      leerToken: () => storage.token,
    );
    controller = SesionController(
      auth: AuthRepository(api),
      storage: storage,
      sesionExpirada: api.sesionExpirada,
    );
  }

  static const claveToken = 'token_sesion';

  late final SesionStorage storage;
  late final ApiClient api;
  late final SesionController controller;
}
