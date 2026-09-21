import 'api_exception.dart';

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

  List<Map<String, dynamic>> listaDeObjetos(String clave) {
    final valor = this[clave];
    if (valor is! List<dynamic>) {
      return const [];
    }
    return valor.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}

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
