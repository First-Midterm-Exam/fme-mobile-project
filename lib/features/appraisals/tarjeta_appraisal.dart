import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../data/models/appraisal.dart';
import '../../shared/formatos.dart';

/// Tarjeta con los datos de un appraisal: nivel objetivo, proyecto y meta.
class TarjetaAppraisal extends StatelessWidget {
  const TarjetaAppraisal({
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
    final nivel = appraisal.nivelObjetivo;
    final meta = appraisal.fechaMeta;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: seleccionado ? colores.primary : colores.outlineVariant,
          width: seleccionado ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _InsigniaNivel(nivel: nivel),
              const SizedBox(width: 16),
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
                    if (meta != null) ...[
                      const SizedBox(height: 10),
                      _EtiquetaMeta(meta: meta),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                seleccionado
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: seleccionado ? colores.primary : colores.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsigniaNivel extends StatelessWidget {
  const _InsigniaNivel({required this.nivel});

  final int? nivel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: ColoresMarca.degradado,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: nivel == null
          ? const Icon(Icons.flag_rounded, color: Colors.white)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ML',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '$nivel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
    );
  }
}

class _EtiquetaMeta extends StatelessWidget {
  const _EtiquetaMeta({required this.meta});

  final DateTime meta;

  @override
  Widget build(BuildContext context) {
    final estado = ColoresEstado.de(context);
    final vencido = meta.isBefore(DateTime.now());
    final color = vencido ? estado.peligro : estado.info;
    final fondo = vencido ? estado.peligroFondo : estado.infoFondo;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Etiqueta(
          icono: Icons.event_rounded,
          texto: 'Meta ${Formatos.fecha(meta)}',
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fondo: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        _Etiqueta(
          icono: Icons.schedule_rounded,
          texto: Formatos.plazo(meta),
          color: color,
          fondo: fondo,
        ),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.icono,
    required this.texto,
    required this.color,
    required this.fondo,
  });

  final IconData icono;
  final String texto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
