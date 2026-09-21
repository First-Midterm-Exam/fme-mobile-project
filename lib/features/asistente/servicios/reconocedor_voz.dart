import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/permisos/permisos.dart';
import 'idiomas.dart';

abstract interface class ReconocedorVoz {
  Future<ResultadoPermiso> solicitarPermiso();

  Future<bool> inicializar();

  Future<void> escuchar({
    required void Function(String texto, {required bool esFinal}) alReconocer,
    required ValueChanged<double> alCambiarNivel,
    required ValueChanged<String> alFallar,
    required VoidCallback alTerminar,
  });

  Future<void> detener();

  Future<void> cancelar();
}

class ReconocedorVozDelSistema implements ReconocedorVoz {
  ReconocedorVozDelSistema({SpeechToText? voz}) : _voz = voz ?? SpeechToText();

  static const pausaParaEnviar = Duration(seconds: 3);
  static const duracionMaxima = Duration(seconds: 60);

  final SpeechToText _voz;
  bool _inicializado = false;
  String? _idioma;
  ValueChanged<String>? _alFallar;
  VoidCallback? _alTerminar;

  @override
  Future<ResultadoPermiso> solicitarPermiso() =>
      pedirPermiso(Permission.microphone);

  @override
  Future<bool> inicializar() async {
    if (_inicializado) {
      return true;
    }
    _inicializado = await _voz.initialize(
      onError: _alRecibirError,
      onStatus: _alRecibirEstado,
    );
    if (_inicializado) {
      final idiomas = await _voz.locales();
      _idioma = elegirIdioma(
        idiomas.map((idioma) => idioma.localeId),
        idiomasReconocimiento,
      );
    }
    return _inicializado;
  }

  @override
  Future<void> escuchar({
    required void Function(String texto, {required bool esFinal}) alReconocer,
    required ValueChanged<double> alCambiarNivel,
    required ValueChanged<String> alFallar,
    required VoidCallback alTerminar,
  }) async {
    _alFallar = alFallar;
    _alTerminar = alTerminar;
    await _voz.listen(
      onResult: (SpeechRecognitionResult resultado) => alReconocer(
        resultado.recognizedWords,
        esFinal: resultado.finalResult,
      ),
      onSoundLevelChange: alCambiarNivel,
      listenOptions: SpeechListenOptions(
        localeId: _idioma,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.search,
        pauseFor: pausaParaEnviar,
        listenFor: duracionMaxima,
      ),
    );
  }

  @override
  Future<void> detener() => _voz.stop();

  @override
  Future<void> cancelar() => _voz.cancel();

  void _alRecibirError(SpeechRecognitionError error) =>
      _alFallar?.call(error.errorMsg);

  void _alRecibirEstado(String estado) {
    if (estado == SpeechToText.doneStatus) {
      _alTerminar?.call();
    }
  }
}
