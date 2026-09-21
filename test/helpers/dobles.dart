import 'dart:convert';
import 'dart:typed_data';

import 'package:fme_mobile_project/core/network/api_client.dart';
import 'package:fme_mobile_project/core/storage/preferencias_storage.dart';
import 'package:fme_mobile_project/features/documento/camara_documentos.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Respuesta JSON en UTF-8, como la envía Laravel.
http.Response respuestaJson(int codigo, Object cuerpo) =>
    http.Response.bytes(utf8.encode(jsonEncode(cuerpo)), codigo);

/// [ApiClient] con token fijo cuyo HTTP responde con [manejador].
ApiClient apiDePrueba(MockClientHandler manejador) => ApiClient(
  baseUrl: Uri.parse('http://servidor.test/api'),
  httpClient: MockClient(manejador),
  leerToken: () => 'token',
);

/// Preferencias en memoria, opcionalmente con un appraisal ya guardado.
Future<PreferenciasStorage> preferenciasDePrueba({int? appraisalId}) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({'appraisal_id': ?appraisalId});
  return PreferenciasStorage.crear();
}

/// Cámara falsa que devuelve el permiso y la foto configurados.
class CamaraFalsa implements CamaraDocumentos {
  CamaraFalsa({
    this.permiso = ResultadoPermiso.concedido,
    this.foto,
    this.error,
  });

  ResultadoPermiso permiso;
  Uint8List? foto;
  ErrorCamara? error;
  Uint8List? fotoPendiente;
  int aperturasDeAjustes = 0;

  @override
  Future<ResultadoPermiso> solicitarPermiso() async => permiso;

  @override
  Future<Uint8List?> tomarFoto() async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return foto;
  }

  @override
  Future<Uint8List?> recuperarFotoPendiente() async => fotoPendiente;

  @override
  Future<void> abrirAjustes() async => aperturasDeAjustes++;
}
