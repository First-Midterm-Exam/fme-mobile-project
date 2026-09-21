import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../data/models/appraisal.dart';
import '../../shared/formatos.dart';
import '../../shared/widgets/estructura.dart';

class FilaAppraisal extends StatelessWidget {
  const FilaAppraisal({
    required this.appraisal,
    required this.alTocar,
    this.seleccionado = false,
    super.key,
  });

  final Appraisal appraisal;
  final VoidCallback alTocar;
  final bool seleccionado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final estado = ColoresEstado.de(context);
    final nivel = appraisal.nivelObjetivo;
    final meta = appraisal.fechaMeta;
    final vencido = meta != null && meta.isBefore(DateTime.now());

    final detalle = [
      if (nivel != null) 'Nivel objetivo ML$nivel',
      if (meta != null) 'Meta ${Formatos.fecha(meta)}',
    ].join('  ·  ');

    return Material(
      color: seleccionado ? colores.primaryContainer : colores.surface,
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appraisal.nombre.isEmpty
                          ? 'Appraisal ${appraisal.id}'
                          : appraisal.nombre,
                      style: tema.textTheme.titleMedium,
                    ),
                    if (appraisal.proyecto.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        appraisal.proyecto,
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (detalle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            detalle,
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: colores.onSurfaceVariant,
                            ),
                          ),
                          if (meta != null)
                            Etiqueta(
                              texto: Formatos.plazo(meta),
                              color: vencido ? estado.peligro : estado.info,
                              fondo: vencido
                                  ? estado.peligroFondo
                                  : estado.infoFondo,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                seleccionado ? Icons.check : Icons.chevron_right,
                color: seleccionado ? colores.primary : colores.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
