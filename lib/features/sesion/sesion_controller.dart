import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/sesion_storage.dart';
import '../../data/models/usuario.dart';
import '../../data/repositories/auth_repository.dart';

enum EstadoSesion { verificando, sinSesion, autenticada }

/// Estado global de la sesión. El router lo escucha para decidir la pantalla.
class SesionController extends ChangeNotifier {
  SesionController({
    required AuthRepository auth,
    required SesionStorage storage,
    required Stream<void> sesionExpirada,
  }) : _auth = auth,
       _storage = storage {
    _suscripcion = sesionExpirada.listen((_) => unawaited(_alExpirar()));
  }

  final AuthRepository _auth;
  final SesionStorage _storage;
  late final StreamSubscription<void> _suscripcion;

  EstadoSesion _estado = EstadoSesion.verificando;
  Usuario? _usuario;
  String? _aviso;
  ApiException? _errorVerificacion;

  EstadoSesion get estado => _estado;
  Usuario? get usuario => _usuario;

  /// Mensaje para mostrar en el login (por ejemplo, sesión expirada).
  String? get aviso => _aviso;

  /// Error de red al validar un token guardado; se ofrece "Reintentar".
  ApiException? get errorVerificacion => _errorVerificacion;

  /// Si hay un token guardado, lo valida con `GET /me`.
  Future<void> verificarSesionGuardada() async {
    _estado = EstadoSesion.verificando;
    _errorVerificacion = null;
    notifyListeners();

    final token = await _storage.cargar();
    if (token == null) {
      _cambiarEstado(EstadoSesion.sinSesion);
      return;
    }
    try {
      _usuario = await _auth.usuarioActual();
      _cambiarEstado(EstadoSesion.autenticada);
    } on ApiException catch (error) {
      if (error.tipo == TipoErrorApi.sesionExpirada) {
        await _alExpirar();
      } else {
        _errorVerificacion = error;
        notifyListeners();
      }
    }
  }

  /// Inicia sesión. Lanza [ApiException] si el servidor lo rechaza.
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final sesion = await _auth.iniciarSesion(email: email, password: password);
    await _storage.guardar(sesion.token);
    _usuario = sesion.usuario;
    _aviso = null;
    _cambiarEstado(EstadoSesion.autenticada);
  }

  /// Cierra la sesión en el servidor (si se puede) y siempre localmente.
  Future<void> cerrarSesion() async {
    try {
      await _auth.cerrarSesion();
    } on ApiException {
      // Aunque el servidor falle, la sesión local se cierra igual.
    }
    await _limpiar();
    _aviso = null;
    _cambiarEstado(EstadoSesion.sinSesion);
  }

  void descartarAviso() {
    if (_aviso != null) {
      _aviso = null;
      notifyListeners();
    }
  }

  Future<void> _alExpirar() async {
    if (_estado == EstadoSesion.sinSesion && _storage.token == null) {
      return;
    }
    await _limpiar();
    _aviso = ApiException.mensajeSesionExpirada;
    _cambiarEstado(EstadoSesion.sinSesion);
  }

  Future<void> _limpiar() async {
    _usuario = null;
    _errorVerificacion = null;
    await _storage.borrar();
  }

  void _cambiarEstado(EstadoSesion estado) {
    _estado = estado;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_suscripcion.cancel());
    super.dispose();
  }
}
