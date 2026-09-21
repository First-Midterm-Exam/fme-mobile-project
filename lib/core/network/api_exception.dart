/// Categorías de error que la interfaz sabe manejar.
enum TipoErrorApi {
  credencialesInvalidas,
  sesionExpirada,
  sinPermiso,
  archivoDemasiadoGrande,
  datosInvalidos,
  demasiadasSolicitudes,
  servicioNoDisponible,
  errorServidor,
  sinConexion,
  tiempoAgotado,
  respuestaInvalida,
}

/// Error de la API con un mensaje listo para mostrar al usuario en español.
class ApiException implements Exception {
  const ApiException(
    this.tipo,
    this.mensaje, {
    this.codigoEstado,
    this.reintentarEn,
  });

  /// Crea la excepción correspondiente a un código de estado HTTP.
  ///
  /// [mensajes] permite que cada endpoint personalice el texto de un código
  /// concreto (por ejemplo, qué significa un 422 al revisar un documento).
  factory ApiException.desdeEstado(
    int codigo, {
    bool autenticado = true,
    Duration? reintentarEn,
    Map<int, String> mensajes = const {},
  }) {
    final tipo = switch (codigo) {
      401 when !autenticado => TipoErrorApi.credencialesInvalidas,
      401 => TipoErrorApi.sesionExpirada,
      403 => TipoErrorApi.sinPermiso,
      413 => TipoErrorApi.archivoDemasiadoGrande,
      422 => TipoErrorApi.datosInvalidos,
      429 => TipoErrorApi.demasiadasSolicitudes,
      503 => TipoErrorApi.servicioNoDisponible,
      _ => TipoErrorApi.errorServidor,
    };
    final mensaje =
        mensajes[codigo] ??
        _mensajePorDefecto(tipo, reintentarEn: reintentarEn);
    return ApiException(
      tipo,
      mensaje,
      codigoEstado: codigo,
      reintentarEn: reintentarEn,
    );
  }

  static const mensajeSesionExpirada =
      'Tu sesión expiró. Vuelve a iniciar sesión.';
  static const mensajeSinPermiso = 'Tu rol no tiene permiso para esta acción.';
  static const mensajeSinConexion =
      'No hay conexión con el servidor. Revisa tu conexión a internet e '
      'inténtalo de nuevo.';
  static const mensajeTiempoAgotado =
      'El servidor tardó demasiado en responder. Inténtalo de nuevo.';
  static const mensajeRespuestaInvalida =
      'La respuesta del servidor no tiene el formato esperado.';

  final TipoErrorApi tipo;
  final String mensaje;
  final int? codigoEstado;

  /// Tiempo sugerido por el encabezado `Retry-After` (solo en 429).
  final Duration? reintentarEn;

  /// Indica si tiene sentido mostrar el botón "Reintentar".
  bool get esReintentable => switch (tipo) {
    TipoErrorApi.sinConexion ||
    TipoErrorApi.tiempoAgotado ||
    TipoErrorApi.servicioNoDisponible ||
    TipoErrorApi.errorServidor ||
    TipoErrorApi.demasiadasSolicitudes => true,
    _ => false,
  };

  static String _mensajePorDefecto(
    TipoErrorApi tipo, {
    Duration? reintentarEn,
  }) {
    return switch (tipo) {
      TipoErrorApi.credencialesInvalidas =>
        'El correo o la contraseña no son correctos.',
      TipoErrorApi.sesionExpirada => mensajeSesionExpirada,
      TipoErrorApi.sinPermiso => mensajeSinPermiso,
      TipoErrorApi.archivoDemasiadoGrande =>
        'El archivo es demasiado grande para enviarlo.',
      TipoErrorApi.datosInvalidos => 'Los datos enviados no son válidos.',
      TipoErrorApi.demasiadasSolicitudes =>
        reintentarEn == null
            ? 'Hiciste demasiadas consultas. Espera un momento e inténtalo '
                  'de nuevo.'
            : 'Hiciste demasiadas consultas. Inténtalo de nuevo en '
                  '${reintentarEn.inSeconds} segundos.',
      TipoErrorApi.servicioNoDisponible =>
        'El servicio no está disponible en este momento. Inténtalo más tarde.',
      TipoErrorApi.errorServidor =>
        'Ocurrió un error en el servidor. Inténtalo más tarde.',
      TipoErrorApi.sinConexion => mensajeSinConexion,
      TipoErrorApi.tiempoAgotado => mensajeTiempoAgotado,
      TipoErrorApi.respuestaInvalida => mensajeRespuestaInvalida,
    };
  }

  @override
  String toString() => 'ApiException($tipo, $codigoEstado): $mensaje';
}
