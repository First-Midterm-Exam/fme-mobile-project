import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../data/models/revision_formato.dart';

/// Resultado de la revisión de formato de un documento.
class ResultadoRevisionView extends StatelessWidget {
  const ResultadoRevisionView({
    required this.resultado,
    required this.alRevisarOtro,
    super.key,
  });

  static const claveInsignia = Key('resultado-insignia');
  static const clavePuntaje = Key('resultado-puntaje');

  final RevisionFormato resultado;
  final VoidCallback alRevisarOtro;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final hallazgos = resultado.hallazgosOrdenados;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _Insignia(cumple: resultado.cumple),
        const SizedBox(height: 12),
        _PuntajeYTipo(
          puntaje: resultado.puntaje,
          tipo: resultado.tipoDetectado,
        ),
        if (resultado.resumen.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    resultado.resumen,
                    style: tema.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          hallazgos.isEmpty ? 'Hallazgos' : 'Hallazgos (${hallazgos.length})',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        if (hallazgos.isEmpty)
          Text(
            'No se encontraron hallazgos.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final hallazgo in hallazgos) ...[
            TarjetaHallazgo(hallazgo: hallazgo),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: alRevisarOtro,
          icon: const Icon(Icons.document_scanner_outlined),
          label: const Text('Revisar otro documento'),
        ),
      ],
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia({required this.cumple});

  final bool cumple;

  @override
  Widget build(BuildContext context) {
    final estado = ColoresEstado.de(context);
    final color = cumple ? estado.exito : estado.peligro;
    final fondo = cumple ? estado.exitoFondo : estado.peligroFondo;

    return Container(
      key: ResultadoRevisionView.claveInsignia,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.verified_rounded : Icons.cancel_rounded,
            color: color,
            size: 44,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              cumple ? 'Cumple el formato' : 'No cumple el formato',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PuntajeYTipo extends StatelessWidget {
  const _PuntajeYTipo({required this.puntaje, required this.tipo});

  final int puntaje;
  final String? tipo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estado = ColoresEstado.de(context);
    final color = switch (puntaje) {
      >= 80 => estado.exito,
      >= 50 => estado.advertencia,
      _ => estado.peligro,
    };
    final tipoTexto = (tipo == null || tipo!.isEmpty)
        ? 'No identificado'
        : tipo!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 84,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: puntaje / 100,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: color,
                    backgroundColor: tema.colorScheme.surfaceContainerHighest,
                  ),
                  Center(
                    child: Text(
                      '$puntaje',
                      key: ResultadoRevisionView.clavePuntaje,
                      style: tema.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Dato(etiqueta: 'Puntaje', valor: '$puntaje de 100'),
                  const SizedBox(height: 12),
                  _Dato(etiqueta: 'Tipo detectado', valor: tipoTexto),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta.toUpperCase(),
          style: tema.textTheme.labelSmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(valor, style: tema.textTheme.titleMedium),
      ],
    );
  }
}

/// Un hallazgo con el color y el ícono de su severidad.
class TarjetaHallazgo extends StatelessWidget {
  const TarjetaHallazgo({required this.hallazgo, super.key});

  final Hallazgo hallazgo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estilo = EstiloSeveridad.de(context, hallazgo.severidad);

    return ClipRRect(
      borderRadius: BorderRadius.circular(TemaApp.radio),
      child: Container(
        decoration: BoxDecoration(
          color: tema.colorScheme.surface,
          border: Border(left: BorderSide(color: estilo.color, width: 4)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(estilo.icono, color: estilo.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hallazgo.elemento.isEmpty
                              ? 'Hallazgo'
                              : hallazgo.elemento,
                          style: tema.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: estilo.fondo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estilo.etiqueta,
                          style: TextStyle(
                            color: estilo.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hallazgo.mensaje.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(hallazgo.mensaje, style: tema.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Color, ícono y etiqueta de cada severidad.
class EstiloSeveridad {
  const EstiloSeveridad({
    required this.color,
    required this.fondo,
    required this.icono,
    required this.etiqueta,
  });

  factory EstiloSeveridad.de(BuildContext context, Severidad severidad) {
    final estado = ColoresEstado.de(context);
    return switch (severidad) {
      Severidad.alta => EstiloSeveridad(
        color: estado.peligro,
        fondo: estado.peligroFondo,
        icono: Icons.error_rounded,
        etiqueta: 'Alta',
      ),
      Severidad.media => EstiloSeveridad(
        color: estado.advertencia,
        fondo: estado.advertenciaFondo,
        icono: Icons.warning_amber_rounded,
        etiqueta: 'Media',
      ),
      Severidad.baja => EstiloSeveridad(
        color: estado.info,
        fondo: estado.infoFondo,
        icono: Icons.info_rounded,
        etiqueta: 'Baja',
      ),
    };
  }

  final Color color;
  final Color fondo;
  final IconData icono;
  final String etiqueta;
}
