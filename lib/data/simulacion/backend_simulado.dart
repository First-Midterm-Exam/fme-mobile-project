import 'dart:convert';

import 'package:http/http.dart' as http;

import 'datos_simulados.dart';

class BackendSimulado extends http.BaseClient {
  BackendSimulado({
    required Uri baseUrl,
    this.latencia = const Duration(milliseconds: 700),
  }) : _prefijo = _sinBarraFinal(baseUrl.path),
       _urlBase = _sinBarraFinal(baseUrl.toString());

  final String _prefijo;
  final String _urlBase;
  final Duration latencia;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final cuerpo = await request.finalize().toBytes();
    await Future<void>.delayed(latencia);

    final ruta = request.url.path.startsWith(_prefijo)
        ? request.url.path.substring(_prefijo.length)
        : request.url.path;
    final autorizado =
        request.headers['Authorization'] == 'Bearer $tokenSimulado';
    final metodoRuta = '${request.method} $ruta';

    if (metodoRuta == 'POST /login') {
      return _login(cuerpo);
    }
    if (!autorizado) {
      return _json(401, {'message': 'Unauthenticated.'});
    }
    final descarga = RegExp(
      r'^GET /asistente/archivos/([^/]+)/descarga$',
    ).firstMatch(metodoRuta);
    if (descarga != null) {
      return _archivo(descarga.group(1)!);
    }
    return switch (metodoRuta) {
      'POST /logout' => _vacio(204),
      'GET /me' => _json(200, usuarioSimulado),
      'GET /appraisals' => _json(200, appraisalsSimulados),
      'POST /documentos/revision-formato' => _json(
        200,
        revisionFormatoSimulada,
      ),
      'POST /asistente/consultas' => _consulta(cuerpo),
      _ => _json(404, {'message': 'Not Found'}),
    };
  }

  http.StreamedResponse _login(List<int> cuerpo) {
    final datos = _leerJson(cuerpo);
    final email = '${datos['email'] ?? ''}'.trim();
    final password = '${datos['password'] ?? ''}';
    if (email.isEmpty || password.isEmpty) {
      return _json(422, {
        'message': 'The email field is required.',
        'errors': {
          'email': ['The email field is required.'],
        },
      });
    }
    if (email.toLowerCase() != emailRegistrado ||
        password != passwordRegistrado) {
      return _json(401, {'message': 'Invalid credentials.'});
    }
    return _json(200, {'token': tokenSimulado, 'user': usuarioSimulado});
  }

  http.StreamedResponse _consulta(List<int> cuerpo) {
    final datos = _leerJson(cuerpo);
    final pregunta = '${datos['pregunta'] ?? ''}'.trim();
    if (pregunta.isEmpty || datos['appraisal_id'] is! int) {
      return _json(422, {'message': 'The given data was invalid.'});
    }
    return _json(200, respuestaAsistenteSimulada(pregunta, urlBase: _urlBase));
  }

  http.StreamedResponse _archivo(String id) {
    final bytes = archivoSimulado(id);
    if (bytes == null) {
      return _json(404, {'message': 'Not Found'});
    }
    final esPdf = id.endsWith('.pdf');
    return http.StreamedResponse(
      Stream.value(bytes),
      200,
      contentLength: bytes.length,
      headers: {
        'content-type': esPdf
            ? 'application/pdf'
            : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'content-disposition': 'attachment; filename="reporte-$id"',
      },
    );
  }

  static String _sinBarraFinal(String texto) =>
      texto.endsWith('/') ? texto.substring(0, texto.length - 1) : texto;

  static Map<String, dynamic> _leerJson(List<int> cuerpo) {
    try {
      final json = jsonDecode(utf8.decode(cuerpo));
      return json is Map<String, dynamic> ? json : const {};
    } on FormatException {
      return const {};
    }
  }

  static http.StreamedResponse _json(int codigo, Object cuerpo) {
    final bytes = utf8.encode(jsonEncode(cuerpo));
    return http.StreamedResponse(
      Stream.value(bytes),
      codigo,
      contentLength: bytes.length,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  static http.StreamedResponse _vacio(int codigo) =>
      http.StreamedResponse(const Stream.empty(), codigo);
}
