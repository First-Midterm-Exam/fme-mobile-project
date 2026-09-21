import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../appraisals/selector_appraisal.dart';
import '../documento/documento_tab.dart';
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
        toolbarHeight: 68,
        titleSpacing: 12,
        title: const SelectorAppraisal(),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: ColoresMarca.degradado),
          child: SizedBox.expand(),
        ),
        actions: const [MenuUsuario(), SizedBox(width: 8)],
      ),
      body: IndexedStack(
        index: _pestana,
        children: const [
          _PestanaVacia(
            icono: Icons.mic,
            texto: 'Consulta la preparación del appraisal',
          ),
          DocumentoTab(),
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
