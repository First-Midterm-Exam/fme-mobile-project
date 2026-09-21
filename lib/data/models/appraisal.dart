import '../../core/network/lectura_json.dart';

class Appraisal {
  const Appraisal({
    required this.id,
    required this.nombre,
    required this.proyecto,
    this.nivelObjetivo,
    this.fechaMeta,
  });

  factory Appraisal.fromJson(Map<String, dynamic> json) => Appraisal(
    id: json.enteroRequerido('id'),
    nombre: json.texto('nombre'),
    proyecto: json.texto('proyecto'),
    nivelObjetivo: json.enteroOpcional('nivel_objetivo'),
    fechaMeta: json.fechaOpcional('fecha_meta'),
  );

  /// Lee la lista de `GET /appraisals`, que viene dentro de `data`.
  static List<Appraisal> listaFromJson(Map<String, dynamic> json) => json
      .listaDeObjetos('data')
      .map(Appraisal.fromJson)
      .toList(growable: false);

  final int id;
  final String nombre;
  final String proyecto;
  final int? nivelObjetivo;
  final DateTime? fechaMeta;
}
