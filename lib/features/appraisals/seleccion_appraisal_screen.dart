import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/rutas.dart';
import '../sesion/sesion_controller.dart';

/// Pantalla 2: appraisals a los que el usuario tiene acceso.
///
/// Etapa 1: pantalla vacía. La lista real se construye en la etapa 3.
class SeleccionAppraisalScreen extends StatelessWidget {
  const SeleccionAppraisalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis appraisals'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: context.read<SesionController>().cerrarSesion,
          ),
        ],
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go(Rutas.principal),
          child: const Text('Continuar (provisional)'),
        ),
      ),
    );
  }
}
