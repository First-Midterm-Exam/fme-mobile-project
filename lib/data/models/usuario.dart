import '../../core/network/lectura_json.dart';

class Rol {
  const Rol({required this.id, required this.nombre});

  factory Rol.fromJson(Map<String, dynamic> json) =>
      Rol(id: json.enteroRequerido('id'), nombre: json.texto('nombre'));

  final int id;
  final String nombre;
}

class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final rol = json.objetoOpcional('rol');
    return Usuario(
      id: json.enteroRequerido('id'),
      nombre: json.texto('nombre'),
      email: json.texto('email'),
      rol: rol == null ? null : Rol.fromJson(rol),
    );
  }

  final int id;
  final String nombre;
  final String email;

  final Rol? rol;
}

class SesionIniciada {
  const SesionIniciada({required this.token, required this.usuario});

  factory SesionIniciada.fromJson(Map<String, dynamic> json) => SesionIniciada(
    token: json.textoRequerido('token'),
    usuario: Usuario.fromJson(json.objetoRequerido('user')),
  );

  final String token;
  final Usuario usuario;
}
