import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/appraisal.dart';
import 'appraisal_controller.dart';
import 'tarjeta_appraisal.dart';

/// Selector del appraisal activo para el encabezado de la pantalla principal.
class SelectorAppraisal extends StatelessWidget {
  const SelectorAppraisal({super.key});

  Future<void> _mostrarOpciones(BuildContext context) {
    final controlador = context.read<AppraisalController>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (contextoHoja) => ChangeNotifierProvider.value(
        value: controlador,
        child: const _HojaAppraisals(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appraisal = context.select<AppraisalController, Appraisal?>(
      (c) => c.seleccionado,
    );
    final tema = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Cambiar appraisal activo',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarOpciones(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'APPRAISAL ACTIVO',
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      appraisal?.nombre ?? 'Elige un appraisal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _HojaAppraisals extends StatelessWidget {
  const _HojaAppraisals();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AppraisalController>();
    final tema = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, desplazamiento) => ListView(
        controller: desplazamiento,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text('Cambiar appraisal', style: tema.textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final appraisal in controlador.appraisals) ...[
            TarjetaAppraisal(
              appraisal: appraisal,
              seleccionado: appraisal.id == controlador.seleccionado?.id,
              alTocar: () {
                controlador.seleccionar(appraisal);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
