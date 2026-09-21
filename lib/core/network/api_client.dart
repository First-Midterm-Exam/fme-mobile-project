import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_exception.dart';

/// Cliente HTTP único de la app.
///
/// Agrega el token de sesión, aplica tiempos de espera, decodifica JSON y
/// traduce cualquier falla a una [ApiException] con mensaje en español.
class ApiClient {
  ApiClient({
    required Uri baseUrl,
    required http.Client httpClient,
    required String? Function() leerToken,
    this.tiempoEsperaPorDefecto = const Duration(seconds: 20),
  }) : _baseUrl = baseUrl,
       _http = httpClient,
       _leerToken = leerToken;

  final Uri _baseUrl;
  final http.Client _http;
  final String? Function() _leerToken;
  final Duration tiempoEsperaPorDefecto;

  final StreamController<void> _sesionExpirada =
      StreamController<void>.broadcast();

  /// Emite un evento cada vez que una petición autenticada recibe un 401.
  Stream<void> get sesionExpirada => _sesionExpirada.stream;

  Future<Map<String, dynamic>> get(
    String ruta, {
    Map<String, String>? consulta,
    Duration? tiempoEspera,
    Map<int, String> mensajes = const {},
  }) {
    final peticion = http.Request('GET', _url(ruta, consulta));
    return _enviar(peticion, tiempoEspera: tiempoEspera, mensajes: mensajes);
  }

  Future<Map<String, dynamic>> post(
    String ruta, {
    Map<String, Object?>? cuerpo,
    bool autenticado = true,
    Duration? tiempoEspera,
    Map<int, String> mensajes = const {},
  }) {
    final peticion = http.Request('POST', _url(ruta));
    if (cuerpo != null) {
      peticion.headers[HttpHeaders.contentTypeHeader] =
          'application/json; charset=utf-8';
      peticion.body = jsonEncode(cuerpo);
    }
    return _enviar(
      peticion,
      autenticado: autenticado,
      tiempoEspera: tiempoEspera,
      mensajes: mensajes,
    );
  }

  /// Envía un archivo como `multipart/form-data`.
  Future<Map<String, dynamic>> postArchivo(
    String ruta, {
    required String campo,
    required Uint8List bytes,
    required String nombreArchivo,
    required MediaType tipoContenido,
    Duration? tiempoEspera,
    Map<int, String> mensajes = const {},
  }) {
    final peticion = http.MultipartRequest('POST', _url(ruta))
      ..files.add(
        http.MultipartFile.fromBytes(
          campo,
          bytes,
          filename: nombreArchivo,
          contentType: tipoContenido,
        ),
      );
    return _enviar(peticion, tiempoEspera: tiempoEspera, mensajes: mensajes);
  }

  Future<void> cerrar() async {
    await _sesionExpirada.close();
    _http.close();
  }

  Uri _url(String ruta, [Map<String, String>? consulta]) {
    final base = _baseUrl.path.endsWith('/')
        ? _baseUrl.path.substring(0, _baseUrl.path.length - 1)
        : _baseUrl.path;
    return _baseUrl.replace(
      path: '$base$ruta',
      queryParameters: consulta == null || consulta.isEmpty ? null : consulta,
    );
  }

  Future<Map<String, dynamic>> _enviar(
    http.BaseRequest peticion, {
    bool autenticado = true,
    Duration? tiempoEspera,
    Map<int, String> mensajes = const {},
  }) async {
    peticion.headers[HttpHeaders.acceptHeader] = 'application/json';
    final token = _leerToken();
    if (autenticado && token != null) {
      peticion.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    final http.Response respuesta;
    try {
      final flujo = await _http
          .send(peticion)
          .timeout(tiempoEspera ?? tiempoEsperaPorDefecto);
      respuesta = await http.Response.fromStream(flujo);
    } on TimeoutException {
      throw const ApiException(
        TipoErrorApi.tiempoAgotado,
        ApiException.mensajeTiempoAgotado,
      );
    } on SocketException {
      throw const ApiException(
        TipoErrorApi.sinConexion,
        ApiException.mensajeSinConexion,
      );
    } on http.ClientException {
      throw const ApiException(
        TipoErrorApi.sinConexion,
        ApiException.mensajeSinConexion,
      );
    }

    final codigo = respuesta.statusCode;
    if (codigo >= 200 && codigo < 300) {
      return _decodificar(respuesta);
    }

    if (codigo == 401 && autenticado) {
      _sesionExpirada.add(null);
    }
    throw ApiException.desdeEstado(
      codigo,
      autenticado: autenticado,
      reintentarEn: _leerRetryAfter(respuesta.headers['retry-after']),
      mensajes: mensajes,
    );
  }

  Map<String, dynamic> _decodificar(http.Response respuesta) {
    if (respuesta.bodyBytes.isEmpty) {
      return const {};
    }
    try {
      final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (json is Map<String, dynamic>) {
        return json;
      }
    } on FormatException {
      // Se maneja abajo como respuesta inválida.
    }
    throw const ApiException(
      TipoErrorApi.respuestaInvalida,
      ApiException.mensajeRespuestaInvalida,
    );
  }

  /// Interpreta `Retry-After`, que puede venir en segundos o como fecha HTTP.
  static Duration? _leerRetryAfter(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }
    final segundos = int.tryParse(valor.trim());
    if (segundos != null) {
      return Duration(seconds: segundos);
    }
    try {
      final diferencia = HttpDate.parse(valor).difference(DateTime.now());
      return diferencia.isNegative ? Duration.zero : diferencia;
    } on HttpException {
      return null;
    }
  }
}
