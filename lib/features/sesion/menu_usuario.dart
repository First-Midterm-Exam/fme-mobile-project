import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/tema.dart';
import '../../data/models/usuario.dart';
import 'sesion_controller.dart';

/// Menú del encabezado con el nombre y rol del usuario y "Cerrar sesión".
class MenuUsuario extends StatelessWidget {
  const MenuUsuario({super.key});

  static const claveCerrarSesion = Key('menu-cerrar-sesion');

  Future<void> _confirmarCierre(BuildContext context) async {
    final sesion = context.read<SesionController>();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Se borrará la conversación actual del asistente y tendrás que '
          'volver a ingresar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado ?? false) {
      await sesion.cerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.select<SesionController, Usuario?>(
      (s) => s.usuario,
    );
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Menú de usuario',
      position: PopupMenuPosition.under,
      onSelected: (accion) => accion(),
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: ColoresMarca.turquesa,
        child: Text(
          _iniciales(usuario?.nombre ?? ''),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<VoidCallback>(
          enabled: false,
          child: _DatosUsuario(usuario: usuario),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<VoidCallback>(
          key: claveCerrarSesion,
          value: () => _confirmarCierre(context),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
          ),
        ),
      ],
    );
  }

  static String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    final iniciales = partes
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return iniciales.isEmpty ? '?' : iniciales;
  }
}

class _DatosUsuario extends StatelessWidget {
  const _DatosUsuario({required this.usuario});

  final Usuario? usuario;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = tema.colorScheme.onSurface;
    final usuario = this.usuario;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          usuario?.nombre ?? 'Usuario',
          style: tema.textTheme.titleMedium?.copyWith(color: color),
        ),
        if (usuario?.rol != null)
          Text(
            usuario!.rol!.nombre,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.primary,
            ),
          ),
        if (usuario != null && usuario.email.isNotEmpty)
          Text(
            usuario.email,
            style: tema.textTheme.bodySmall?.copyWith(color: color),
          ),
      ],
    );
  }
}
