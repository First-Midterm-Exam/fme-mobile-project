import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/rutas.dart';
import '../sesion/menu_usuario.dart';

/// Pantalla 2: appraisals a los que el usuario tiene acceso.
class SeleccionAppraisalScreen extends StatelessWidget {
  const SeleccionAppraisalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis appraisals'),
        actions: const [MenuUsuario(), SizedBox(width: 8)],
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go(Rutas.principal),
          child: const Text('Continuar'),
        ),
      ),
    );
  }
}
