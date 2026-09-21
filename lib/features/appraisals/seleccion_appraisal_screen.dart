import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/error_reintentar.dart';
import '../sesion/menu_usuario.dart';
import 'appraisal_controller.dart';
import 'tarjeta_appraisal.dart';

/// Pantalla 2: appraisals a los que el usuario tiene acceso.
///
/// Al elegir uno, el router abre la pantalla principal.
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
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          itemCount: controlador.appraisals.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, indice) {
            if (indice == 0) {
              return const _Encabezado();
            }
            final appraisal = controlador.appraisals[indice - 1];
            return TarjetaAppraisal(
              appraisal: appraisal,
              seleccionado: appraisal.id == controlador.seleccionado?.id,
              alTocar: () => controlador.seleccionar(appraisal),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis appraisals'),
        actions: const [MenuUsuario(), SizedBox(width: 8)],
      ),
      body: contenido,
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Elige un appraisal', style: tema.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'El asistente y la revisión de documentos trabajarán con el '
            'appraisal que elijas. Puedes cambiarlo después desde el '
            'encabezado.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: tema.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes appraisals activos',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Pide a un administrador de la plataforma que te asigne a un '
              'proyecto con un appraisal activo.',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: context.read<AppraisalController>().cargar,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
