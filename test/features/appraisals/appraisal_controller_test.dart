import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fme_mobile_project/core/network/api_exception.dart';
import 'package:fme_mobile_project/data/repositories/appraisal_repository.dart';
import 'package:fme_mobile_project/features/appraisals/appraisal_controller.dart';

import '../../helpers/dobles.dart';

Map<String, Object?> _appraisal(int id) => {
  'id': id,
  'nombre': 'Appraisal $id',
  'proyecto': 'Proyecto $id',
  'nivel_objetivo': 2,
  'fecha_meta': '2026-11-30',
};

Future<AppraisalController> _controlador(List<int> ids, {int? guardado}) async {
  final api = apiDePrueba(
    (_) async => respuestaJson(200, {'data': ids.map(_appraisal).toList()}),
  );
  return AppraisalController(
    repositorio: AppraisalRepository(api),
    preferencias: await preferenciasDePrueba(appraisalId: guardado),
  );
}

void main() {
  test('con un solo appraisal lo selecciona y lo recuerda', () async {
    final api = apiDePrueba(
      (_) async => respuestaJson(200, {
        'data': [_appraisal(3)],
      }),
    );
    final preferencias = await preferenciasDePrueba();
    final controlador = AppraisalController(
      repositorio: AppraisalRepository(api),
      preferencias: preferencias,
    );

    await controlador.cargar();

    expect(controlador.estado, EstadoAppraisals.listo);
    expect(controlador.seleccionado?.id, 3);
    expect(preferencias.appraisalId, 3);
  });

  test('con varios appraisals espera a que el usuario elija', () async {
    final controlador = await _controlador([3, 5]);

    await controlador.cargar();

    expect(controlador.appraisals, hasLength(2));
    expect(controlador.seleccionado, isNull);
  });

  test('recupera el appraisal recordado entre sesiones', () async {
    final controlador = await _controlador([3, 5], guardado: 5);

    await controlador.cargar();

    expect(controlador.seleccionado?.id, 5);
  });

  test('olvida un appraisal recordado que ya no está disponible', () async {
    final api = apiDePrueba(
      (_) async => respuestaJson(200, {
        'data': [_appraisal(3), _appraisal(5)],
      }),
    );
    final preferencias = await preferenciasDePrueba(appraisalId: 9);
    final controlador = AppraisalController(
      repositorio: AppraisalRepository(api),
      preferencias: preferencias,
    );

    await controlador.cargar();

    expect(controlador.seleccionado, isNull);
    expect(preferencias.appraisalId, isNull);
  });

  test('seleccionar guarda la preferencia', () async {
    final api = apiDePrueba(
      (_) async => respuestaJson(200, {
        'data': [_appraisal(3), _appraisal(5)],
      }),
    );
    final preferencias = await preferenciasDePrueba();
    final controlador = AppraisalController(
      repositorio: AppraisalRepository(api),
      preferencias: preferencias,
    );
    await controlador.cargar();

    await controlador.seleccionar(controlador.appraisals.last);

    expect(controlador.seleccionado?.id, 5);
    expect(preferencias.appraisalId, 5);
  });

  test('un error de red queda disponible para reintentar', () async {
    final api = apiDePrueba((_) async => throw const SocketException('x'));
    final controlador = AppraisalController(
      repositorio: AppraisalRepository(api),
      preferencias: await preferenciasDePrueba(),
    );

    await controlador.cargar();

    expect(controlador.estado, EstadoAppraisals.error);
    expect(controlador.error?.tipo, TipoErrorApi.sinConexion);
    expect(controlador.error?.esReintentable, isTrue);
  });

  test('reiniciar olvida la lista pero conserva la preferencia', () async {
    final controlador = await _controlador([3]);
    await controlador.cargar();

    controlador.reiniciar();

    expect(controlador.estado, EstadoAppraisals.sinCargar);
    expect(controlador.appraisals, isEmpty);
    expect(controlador.seleccionado, isNull);
  });
}
