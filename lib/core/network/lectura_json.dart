import 'api_exception.dart';

/// Lectura tolerante de campos JSON.
///
/// Los métodos `*Requerido` lanzan [FormatException] si el campo falta o tiene
/// un tipo inesperado; el resto devuelve un valor por defecto o `null`.
extension LecturaJson on Map<String, dynamic> {
  int enteroRequerido(String clave) =>
      enteroOpcional(clave) ?? (throw FormatException('Falta "$clave".'));

  int? enteroOpcional(String clave) {
    final valor = this[clave];
    if (valor is num) {
      return valor.toInt();
    }
    if (valor is String) {
      return int.tryParse(valor) ?? double.tryParse(valor)?.round();
    }
    return null;
  }

  String textoRequerido(String clave) {
    final valor = textoOpcional(clave);
    if (valor == null || valor.isEmpty) {
      throw FormatException('Falta "$clave".');
    }
    return valor;
  }

  String? textoOpcional(String clave) {
    final valor = this[clave];
    if (valor is String) {
      return valor;
    }
    if (valor is num || valor is bool) {
      return '$valor';
    }
    return null;
  }

  String texto(String clave) => textoOpcional(clave) ?? '';

  bool booleano(String clave) {
    final valor = this[clave];
    return valor == true || valor == 1 || valor == 'true' || valor == '1';
  }

  DateTime? fechaOpcional(String clave) {
    final valor = textoOpcional(clave);
    return valor == null ? null : DateTime.tryParse(valor);
  }

  Map<String, dynamic>? objetoOpcional(String clave) {
    final valor = this[clave];
    return valor is Map<String, dynamic> ? valor : null;
  }

  Map<String, dynamic> objetoRequerido(String clave) =>
      objetoOpcional(clave) ?? (throw FormatException('Falta "$clave".'));

  /// Devuelve solo los elementos que son objetos; ignora el resto.
  List<Map<String, dynamic>> listaDeObjetos(String clave) {
    final valor = this[clave];
    if (valor is! List<dynamic>) {
      return const [];
    }
    return valor.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}

/// Ejecuta [parsear] y convierte cualquier [FormatException] en una
/// [ApiException] de respuesta inválida.
T parsearRespuesta<T>(T Function() parsear) {
  try {
    return parsear();
  } on FormatException {
    throw const ApiException(
      TipoErrorApi.respuestaInvalida,
      ApiException.mensajeRespuestaInvalida,
    );
  }
}
