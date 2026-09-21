import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/preferencias_storage.dart';
import '../../data/models/appraisal.dart';
import '../../data/repositories/appraisal_repository.dart';

enum EstadoAppraisals { sinCargar, cargando, listo, error }

class AppraisalController extends ChangeNotifier {
  AppraisalController({
    required AppraisalRepository repositorio,
    required PreferenciasStorage preferencias,
  }) : _repositorio = repositorio,
       _preferencias = preferencias;

  final AppraisalRepository _repositorio;
  final PreferenciasStorage _preferencias;

  EstadoAppraisals _estado = EstadoAppraisals.sinCargar;
  List<Appraisal> _appraisals = const [];
  Appraisal? _seleccionado;
  ApiException? _error;
  int _version = 0;

  EstadoAppraisals get estado => _estado;
  List<Appraisal> get appraisals => _appraisals;
  Appraisal? get seleccionado => _seleccionado;
  ApiException? get error => _error;

  Future<void> cargar() async {
    final version = ++_version;
    _estado = EstadoAppraisals.cargando;
    _error = null;
    notifyListeners();

    try {
      final lista = await _repositorio.listarActivos();
      if (version != _version) {
        return;
      }
      _appraisals = lista;
      _seleccionado = await _resolverSeleccion(lista);
      _estado = EstadoAppraisals.listo;
    } on ApiException catch (error) {
      if (version != _version) {
        return;
      }
      _error = error;
      _estado = EstadoAppraisals.error;
    }
    notifyListeners();
  }

  Future<void> seleccionar(Appraisal appraisal) async {
    _seleccionado = appraisal;
    notifyListeners();
    await _preferencias.guardarAppraisalId(appraisal.id);
  }

  void reiniciar() {
    _version++;
    _estado = EstadoAppraisals.sinCargar;
    _appraisals = const [];
    _seleccionado = null;
    _error = null;
    notifyListeners();
  }

  Future<Appraisal?> _resolverSeleccion(List<Appraisal> lista) async {
    final idGuardado = _preferencias.appraisalId;
    for (final appraisal in lista) {
      if (appraisal.id == idGuardado) {
        return appraisal;
      }
    }
    if (lista.length == 1) {
      await _preferencias.guardarAppraisalId(lista.single.id);
      return lista.single;
    }
    if (idGuardado != null) {
      await _preferencias.borrarAppraisalId();
    }
    return null;
  }
}
