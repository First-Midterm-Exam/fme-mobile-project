import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../data/models/revision_formato.dart';
import '../../shared/widgets/estructura.dart';

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
    final tipo = resultado.tipoDetectado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              _Insignia(cumple: resultado.cumple),
              const TituloSeccion('Detalle'),
              GrupoSeccion(
                children: [
                  _FilaPuntaje(puntaje: resultado.puntaje),
                  _FilaDato(
                    etiqueta: 'Tipo detectado',
                    valor: tipo == null || tipo.isEmpty
                        ? 'No identificado'
                        : tipo,
                  ),
                ],
              ),
              if (resultado.resumen.isNotEmpty) ...[
                const TituloSeccion('Resumen'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      resultado.resumen,
                      style: tema.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ),
                ),
              ],
              TituloSeccion(
                hallazgos.isEmpty
                    ? 'Hallazgos'
                    : 'Hallazgos (${hallazgos.length})',
              ),
              if (hallazgos.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: TextoSecundario('No se encontraron hallazgos.'),
                  ),
                )
              else
                GrupoSeccion(
                  children: [
                    for (final hallazgo in hallazgos)
                      FilaHallazgo(hallazgo: hallazgo),
                  ],
                ),
            ],
          ),
        ),
        BarraAccionInferior(
          child: FilledButton(
            onPressed: alRevisarOtro,
            child: const Text('Revisar otro documento'),
          ),
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
    final tema = Theme.of(context);
    final estado = ColoresEstado.de(context);
    final color = cumple ? estado.exito : estado.peligro;
    final fondo = cumple ? estado.exitoFondo : estado.peligroFondo;

    return Container(
      key: ResultadoRevisionView.claveInsignia,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(TemaApp.radioTarjeta),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cumple ? 'Cumple el formato' : 'No cumple el formato',
                  style: tema.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Resultado del análisis de formato',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaPuntaje extends StatelessWidget {
  const _FilaPuntaje({required this.puntaje});

  final int puntaje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estado = ColoresEstado.de(context);
    final color = switch (puntaje) {
      >= 80 => estado.exito,
      >= 50 => estado.advertencia,
      _ => estado.peligro,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Puntaje',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '$puntaje',
                key: ResultadoRevisionView.clavePuntaje,
                style: tema.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' / 100',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: puntaje / 100,
              minHeight: 6,
              color: color,
              backgroundColor: tema.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            etiqueta,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: tema.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class FilaHallazgo extends StatelessWidget {
  const FilaHallazgo({required this.hallazgo, super.key});

  final Hallazgo hallazgo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estilo = EstiloSeveridad.de(context, hallazgo.severidad);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(estilo.icono, color: estilo.color, size: 20),
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
                        style: tema.textTheme.titleSmall,
                      ),
                    ),
                    Etiqueta(
                      texto: estilo.etiqueta,
                      color: estilo.color,
                      fondo: estilo.fondo,
                    ),
                  ],
                ),
                if (hallazgo.mensaje.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    hallazgo.mensaje,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        icono: Icons.error,
        etiqueta: 'Alta',
      ),
      Severidad.media => EstiloSeveridad(
        color: estado.advertencia,
        fondo: estado.advertenciaFondo,
        icono: Icons.warning,
        etiqueta: 'Media',
      ),
      Severidad.baja => EstiloSeveridad(
        color: estado.info,
        fondo: estado.infoFondo,
        icono: Icons.info,
        etiqueta: 'Baja',
      ),
    };
  }

  final Color color;
  final Color fondo;
  final IconData icono;
  final String etiqueta;
}
