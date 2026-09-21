import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/error_reintentar.dart';
import '../../shared/widgets/estructura.dart';
import '../sesion/menu_usuario.dart';
import 'appraisal_controller.dart';
import 'tarjeta_appraisal.dart';

class SeleccionAppraisalScreen extends StatelessWidget {
  const SeleccionAppraisalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AppraisalController>();
    final error = controlador.error;

    final Widget contenido;
    if (controlador.estado == EstadoAppraisals.error && error != null) {
      contenido = ErrorReintentar(
        mensaje: error.mensaje,
        alReintentar: error.esReintentable ? controlador.cargar : null,
      );
    } else if (controlador.estado != EstadoAppraisals.listo) {
      contenido = const Center(child: CircularProgressIndicator());
    } else if (controlador.appraisals.isEmpty) {
      contenido = const _SinAppraisals();
    } else {
      contenido = RefreshIndicator(
        onRefresh: controlador.cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const TituloSeccion('Appraisals activos'),
            GrupoSeccion(
              children: [
                for (final appraisal in controlador.appraisals)
                  FilaAppraisal(
                    appraisal: appraisal,
                    seleccionado: appraisal.id == controlador.seleccionado?.id,
                    alTocar: () => controlador.seleccionar(appraisal),
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 12, 4, 0),
              child: TextoSecundario(
                'El asistente y la revisión de documentos trabajarán con el '
                'appraisal que elijas. Puedes cambiarlo después desde la '
                'pantalla principal.',
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar appraisal'),
        actions: const [MenuUsuario(), SizedBox(width: 8)],
      ),
      body: contenido,
    );
  }
}

class _SinAppraisals extends StatelessWidget {
  const _SinAppraisals();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No tienes appraisals activos',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const TextoSecundario(
              'Solicita a un administrador de la plataforma que te asigne a '
              'un proyecto con un appraisal activo.',
              alineacion: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: context.read<AppraisalController>().cargar,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
