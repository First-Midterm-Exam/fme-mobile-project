import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/appraisal.dart';
import '../../shared/widgets/estructura.dart';
import 'appraisal_controller.dart';
import 'tarjeta_appraisal.dart';

class BarraContextoAppraisal extends StatelessWidget
    implements PreferredSizeWidget {
  const BarraContextoAppraisal({super.key});

  static const alto = 64.0;

  @override
  Size get preferredSize => const Size.fromHeight(alto);

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
    final colores = tema.colorScheme;

    return Material(
      color: colores.surface,
      child: InkWell(
        onTap: () => _mostrarOpciones(context),
        child: Container(
          height: alto,
          padding: const EdgeInsets.only(left: 16, right: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colores.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APPRAISAL ACTIVO',
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: colores.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        appraisal?.nombre ?? 'Sin seleccionar',
                        if (appraisal != null && appraisal.proyecto.isNotEmpty)
                          appraisal.proyecto,
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _mostrarOpciones(context),
                child: const Text('Cambiar'),
              ),
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
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (context, desplazamiento) => ListView(
        controller: desplazamiento,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text('Cambiar appraisal', style: tema.textTheme.titleLarge),
          const TituloSeccion('Appraisals activos'),
          GrupoSeccion(
            children: [
              for (final appraisal in controlador.appraisals)
                FilaAppraisal(
                  appraisal: appraisal,
                  seleccionado: appraisal.id == controlador.seleccionado?.id,
                  alTocar: () {
                    controlador.seleccionar(appraisal);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
