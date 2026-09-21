import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_exception.dart';

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

  Uri resolver(String url) {
    final uri = Uri.parse(url);
    return uri.hasScheme ? uri : _baseUrl.resolveUri(uri);
  }

  Future<Uint8List> descargar(
    Uri url, {
    Duration? tiempoEspera,
    Map<int, String> mensajes = const {},
  }) async {
    final peticion = http.Request('GET', url);
    final respuesta = await _ejecutar(
      peticion,
      autenticado: _mismoOrigen(url),
      tiempoEspera: tiempoEspera,
      mensajes: mensajes,
      aceptar: '*/*',
    );
    return respuesta.bodyBytes;
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

  bool _mismoOrigen(Uri url) =>
      url.scheme == _baseUrl.scheme &&
      url.host == _baseUrl.host &&
      url.port == _baseUrl.port;

  Future<Map<String, dynamic>> _enviar(
    http.BaseRequest peticion, {
    bool autenticado = true,
    Duration? tiempoEspera,
    Map<int, String> mensajes = const {},
  }) async {
    final respuesta = await _ejecutar(
      peticion,
      autenticado: autenticado,
      tiempoEspera: tiempoEspera,
      mensajes: mensajes,
    );
    return _decodificar(respuesta);
  }

  Future<http.Response> _ejecutar(
    http.BaseRequest peticion, {
    required bool autenticado,
    required Duration? tiempoEspera,
    required Map<int, String> mensajes,
    String aceptar = 'application/json',
  }) async {
    peticion.headers[HttpHeaders.acceptHeader] = aceptar;
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
      return respuesta;
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
    const invalida = ApiException(
      TipoErrorApi.respuestaInvalida,
      ApiException.mensajeRespuestaInvalida,
    );
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException {
      throw invalida;
    }
    if (json is Map<String, dynamic>) {
      return json;
    }
    throw invalida;
  }

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
