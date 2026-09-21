import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/network/api_client.dart';
import 'package:fme_mobile_project/core/network/api_exception.dart';
import 'package:fme_mobile_project/data/repositories/appraisal_repository.dart';
import 'package:fme_mobile_project/data/repositories/asistente_repository.dart';
import 'package:fme_mobile_project/data/repositories/auth_repository.dart';
import 'package:fme_mobile_project/data/repositories/documento_repository.dart';
import 'package:fme_mobile_project/data/simulacion/backend_simulado.dart';
import 'package:fme_mobile_project/data/simulacion/datos_simulados.dart';

void main() {
  final base = Uri.parse('http://10.0.2.2:8000/api');
  late String? token;
  late ApiClient api;

  setUp(() {
    token = null;
    api = ApiClient(
      baseUrl: base,
      httpClient: BackendSimulado(baseUrl: base, latencia: Duration.zero),
      leerToken: () => token,
    );
  });

  test('inicio de sesión y consumo de todos los endpoints', () async {
    final sesion = await AuthRepository(
      api,
    ).iniciarSesion(email: emailRegistrado, password: passwordRegistrado);
    token = sesion.token;

    expect(sesion.usuario.rol?.nombre, 'Gestor de Procesos');
    expect((await AuthRepository(api).usuarioActual()).email, emailRegistrado);
    expect(await AppraisalRepository(api).listarActivos(), hasLength(2));

    final revision = await DocumentoRepository(
      api,
    ).revisarFormato(Uint8List.fromList([1, 2, 3]));
    expect(revision.puntaje, 72);

    final respuesta = await AsistenteRepository(
      api,
    ).consultar(appraisalId: 3, pregunta: '¿Qué acciones están vencidas?');
    expect(respuesta.tipoReporte, 'acciones_vencidas');

    await AuthRepository(api).cerrarSesion();
  });

  test('credenciales incorrectas dan un mensaje que no revela el correo', () {
    expect(
      AuthRepository(api).iniciarSesion(email: emailRegistrado, password: 'x'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          'El correo o la contraseña no son correctos.',
        ),
      ),
    );
  });

  test('sin token el backend responde 401', () {
    expect(
      AppraisalRepository(api).listarActivos(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.tipo,
          'tipo',
          TipoErrorApi.sesionExpirada,
        ),
      ),
    );
  });
}
