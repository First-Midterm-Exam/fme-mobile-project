import '../../core/network/lectura_json.dart';

enum Severidad {
  alta,
  media,
  baja;

  static Severidad desdeTexto(String? texto) =>
      switch (texto?.trim().toLowerCase()) {
        'alta' => Severidad.alta,
        'media' => Severidad.media,
        _ => Severidad.baja,
      };
}

class Hallazgo {
  const Hallazgo({
    required this.severidad,
    required this.elemento,
    required this.mensaje,
  });

  factory Hallazgo.fromJson(Map<String, dynamic> json) => Hallazgo(
    severidad: Severidad.desdeTexto(json.textoOpcional('severidad')),
    elemento: json.texto('elemento'),
    mensaje: json.texto('mensaje'),
  );

  final Severidad severidad;
  final String elemento;
  final String mensaje;
}

class RevisionFormato {
  const RevisionFormato({
    required this.cumple,
    required this.puntaje,
    required this.resumen,
    required this.hallazgos,
    this.tipoDetectado,
  });

  factory RevisionFormato.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('cumple')) {
      throw const FormatException('Falta "cumple".');
    }
    return RevisionFormato(
      cumple: json.booleano('cumple'),
      puntaje: (json.enteroOpcional('puntaje') ?? 0).clamp(0, 100),
      tipoDetectado: json.textoOpcional('tipo_detectado'),
      resumen: json.texto('resumen'),
      hallazgos: json
          .listaDeObjetos('hallazgos')
          .map(Hallazgo.fromJson)
          .toList(growable: false),
    );
  }

  final bool cumple;

  final int puntaje;
  final String? tipoDetectado;
  final String resumen;
  final List<Hallazgo> hallazgos;

  List<Hallazgo> get hallazgosOrdenados {
    final indexados = hallazgos.indexed.toList()
      ..sort((a, b) {
        final porSeveridad = a.$2.severidad.index.compareTo(
          b.$2.severidad.index,
        );
        return porSeveridad != 0 ? porSeveridad : a.$1.compareTo(b.$1);
      });
    return indexados.map((e) => e.$2).toList(growable: false);
  }
}
