import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el token de sesión en el almacenamiento seguro del sistema
/// (Android Keystore) y mantiene una copia en memoria para no leer el disco
/// en cada petición.
class SesionStorage {
  SesionStorage([FlutterSecureStorage? almacenamiento])
    : _almacenamiento = almacenamiento ?? const FlutterSecureStorage();

  static const _claveToken = 'token_sesion';

  final FlutterSecureStorage _almacenamiento;
  String? _token;

  String? get token => _token;

  Future<String?> cargar() async {
    _token = await _almacenamiento.read(key: _claveToken);
    return _token;
  }

  Future<void> guardar(String token) async {
    _token = token;
    await _almacenamiento.write(key: _claveToken, value: token);
  }

  Future<void> borrar() async {
    _token = null;
    await _almacenamiento.delete(key: _claveToken);
  }
}
