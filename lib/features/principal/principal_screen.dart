import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/rutas.dart';
import '../sesion/menu_usuario.dart';

/// Pantalla 3: principal, con las pestañas "Asistente" y "Documento".
///
/// Usa un [IndexedStack] para que cada pestaña conserve su estado (por
/// ejemplo, la conversación) al cambiar de una a otra.
class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _pestana = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Readiness'),
        actions: [
          IconButton(
            tooltip: 'Cambiar appraisal',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => context.go(Rutas.appraisals),
          ),
          const MenuUsuario(),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _pestana,
        children: const [
          _PestanaVacia(
            icono: Icons.mic,
            texto: 'Consulta la preparación del appraisal',
          ),
          _PestanaVacia(
            icono: Icons.document_scanner,
            texto: 'Revisa el formato de un documento',
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (indice) => setState(() => _pestana = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_none),
            selectedIcon: Icon(Icons.mic),
            label: 'Asistente',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Documento',
          ),
        ],
      ),
    );
  }
}

class _PestanaVacia extends StatelessWidget {
  const _PestanaVacia({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: tema.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 48, color: tema.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            texto,
            style: tema.textTheme.titleMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
