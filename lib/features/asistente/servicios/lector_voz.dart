import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'idiomas.dart';

abstract interface class LectorVoz {
  Future<void> leer(String texto, {required VoidCallback alTerminar});

  Future<void> detener();
}

class LectorVozDelSistema implements LectorVoz {
  LectorVozDelSistema({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configurado = false;
  VoidCallback? _alTerminar;

  @override
  Future<void> leer(String texto, {required VoidCallback alTerminar}) async {
    await _configurar();
    _alTerminar = alTerminar;
    await _tts.speak(texto);
  }

  @override
  Future<void> detener() async {
    await _tts.stop();
    _terminar();
  }

  Future<void> _configurar() async {
    if (_configurado) {
      return;
    }
    _configurado = true;
    _tts
      ..setCompletionHandler(_terminar)
      ..setCancelHandler(_terminar)
      ..setErrorHandler((_) => _terminar());
    final idiomas = await _tts.getLanguages;
    final idioma = elegirIdioma(
      idiomas is List<Object?>
          ? idiomas.map((idioma) => '$idioma')
          : const <String>[],
      idiomasLectura,
    );
    if (idioma != null) {
      await _tts.setLanguage(idioma);
    }
    await _tts.setSpeechRate(0.5);
  }

  void _terminar() {
    final alTerminar = _alTerminar;
    _alTerminar = null;
    alTerminar?.call();
  }
}
