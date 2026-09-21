import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ResultadoApertura { abierto, sinAplicacion, fallido }

abstract interface class ArchivosReporte {
  Future<String> guardar(String nombre, Uint8List bytes);

  Future<ResultadoApertura> abrir(String ruta, String tipoMime);

  Future<void> compartirArchivo(String ruta, String tipoMime);

  Future<void> compartirTexto(String texto, {required String asunto});

  Future<void> limpiar();
}

class ArchivosReporteDelSistema implements ArchivosReporte {
  static const _carpeta = 'reportes';

  @override
  Future<String> guardar(String nombre, Uint8List bytes) async {
    final carpeta = await _directorio();
    await carpeta.create(recursive: true);
    final seguro = nombre.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final archivo = File('${carpeta.path}${Platform.pathSeparator}$seguro');
    await archivo.writeAsBytes(bytes, flush: true);
    return archivo.path;
  }

  @override
  Future<ResultadoApertura> abrir(String ruta, String tipoMime) async {
    final resultado = await OpenFilex.open(ruta, type: tipoMime);
    return switch (resultado.type) {
      ResultType.done => ResultadoApertura.abierto,
      ResultType.noAppToOpen => ResultadoApertura.sinAplicacion,
      _ => ResultadoApertura.fallido,
    };
  }

  @override
  Future<void> compartirArchivo(String ruta, String tipoMime) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(ruta, mimeType: tipoMime)]),
    );
  }

  @override
  Future<void> compartirTexto(String texto, {required String asunto}) async {
    await SharePlus.instance.share(ShareParams(text: texto, subject: asunto));
  }

  @override
  Future<void> limpiar() async {
    final carpeta = await _directorio();
    if (carpeta.existsSync()) {
      await carpeta.delete(recursive: true);
    }
  }

  Future<Directory> _directorio() async {
    final temporal = await getTemporaryDirectory();
    return Directory('${temporal.path}${Platform.pathSeparator}$_carpeta');
  }
}
