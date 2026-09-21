import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../app/tema.dart';
import '../../../data/models/respuesta_asistente.dart';
import '../../../shared/formatos.dart';
import '../../../shared/widgets/estructura.dart';
import '../asistente_controller.dart';

class BurbujaPregunta extends StatelessWidget {
  const BurbujaPregunta({required this.texto, super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colores.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(2),
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(color: colores.onPrimary, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class TarjetaRespuesta extends StatelessWidget {
  const TarjetaRespuesta({
    required this.intercambio,
    required this.puedeReintentar,
    required this.alReintentar,
    required this.alCompartir,
    required this.alAbrirArchivo,
    required this.alCompartirArchivo,
    super.key,
  });

  final Intercambio intercambio;
  final bool puedeReintentar;
  final VoidCallback alReintentar;
  final VoidCallback alCompartir;
  final VoidCallback alAbrirArchivo;
  final VoidCallback alCompartirArchivo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final respuesta = intercambio.respuesta;
    final error = intercambio.error;

    final Widget cuerpo;
    if (respuesta != null) {
      cuerpo = _Reporte(
        respuesta: respuesta,
        intercambio: intercambio,
        alAbrirArchivo: alAbrirArchivo,
        alCompartirArchivo: alCompartirArchivo,
      );
    } else if (error != null) {
      cuerpo = _Error(mensaje: error.mensaje);
    } else {
      cuerpo = const _Generando();
    }

    final Widget? pie = switch ((respuesta, error)) {
      (RespuestaAsistente(), _) => TextButton(
        onPressed: alCompartir,
        child: const Text('Compartir'),
      ),
      (_, final errorActual?)
          when errorActual.esReintentable && puedeReintentar =>
        TextButton(onPressed: alReintentar, child: const Text('Reintentar')),
      _ => null,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                Text(
                  'RESPUESTA',
                  style: tema.textTheme.labelSmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    intercambio.appraisal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.labelSmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  Formatos.hora(intercambio.fecha),
                  style: tema.textTheme.labelSmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: cuerpo),
          if (pie != null) ...[
            const Divider(height: 1),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: pie,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Generando extends StatelessWidget {
  const _Generando();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Expanded(
          child: TextoSecundario(
            'Generando la respuesta con los datos actuales...',
          ),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final estado = ColoresEstado.de(context);
    return Text(
      mensaje,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: estado.peligro, height: 1.4),
    );
  }
}

class _Reporte extends StatelessWidget {
  const _Reporte({
    required this.respuesta,
    required this.intercambio,
    required this.alAbrirArchivo,
    required this.alCompartirArchivo,
  });

  final RespuestaAsistente respuesta;
  final Intercambio intercambio;
  final VoidCallback alAbrirArchivo;
  final VoidCallback alCompartirArchivo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final archivo = respuesta.archivo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (respuesta.resumenVoz.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: colores.surfaceContainer,
              border: Border(
                left: BorderSide(color: colores.primary, width: 3),
              ),
            ),
            child: Text(
              respuesta.resumenVoz,
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        if (respuesta.reporteMarkdown.isNotEmpty) ...[
          const SizedBox(height: 8),
          MarkdownBody(
            data: respuesta.reporteMarkdown,
            styleSheet: _estiloMarkdown(tema),
          ),
        ],
        if (archivo != null) ...[
          const SizedBox(height: 16),
          TarjetaArchivo(
            archivo: archivo,
            intercambio: intercambio,
            alAbrir: alAbrirArchivo,
            alCompartir: alCompartirArchivo,
          ),
        ],
      ],
    );
  }

  static MarkdownStyleSheet _estiloMarkdown(ThemeData tema) {
    final colores = tema.colorScheme;
    return MarkdownStyleSheet.fromTheme(tema).copyWith(
      h2: tema.textTheme.titleMedium,
      h2Padding: const EdgeInsets.only(top: 8, bottom: 4),
      h3: tema.textTheme.titleSmall,
      h3Padding: const EdgeInsets.only(top: 8),
      p: tema.textTheme.bodyMedium?.copyWith(height: 1.4),
      listBullet: tema.textTheme.bodyMedium,
      tableHead: tema.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      tableBody: tema.textTheme.bodySmall,
      tableHeadAlign: TextAlign.left,
      tableBorder: TableBorder.all(color: colores.outlineVariant),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.all(6),
      tableCellsDecoration: BoxDecoration(color: colores.surfaceContainerLow),
    );
  }
}

class TarjetaArchivo extends StatelessWidget {
  const TarjetaArchivo({
    required this.archivo,
    required this.intercambio,
    required this.alAbrir,
    required this.alCompartir,
    super.key,
  });

  final ArchivoReporte archivo;
  final Intercambio intercambio;
  final VoidCallback alAbrir;
  final VoidCallback alCompartir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final estado = ColoresEstado.de(context);
    final esPdf = archivo.formato == FormatoArchivo.pdf;
    final acento = esPdf ? estado.peligro : estado.exito;
    final descargando = intercambio.estadoArchivo == EstadoArchivo.descargando;
    final aviso = intercambio.avisoArchivo;
    final tamano = archivo.tamanoBytes;

    return Container(
      decoration: BoxDecoration(
        color: colores.surfaceContainerLow,
        borderRadius: BorderRadius.circular(TemaApp.radio),
        border: Border.all(color: colores.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: acento,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    esPdf ? 'PDF' : 'XLSX',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        archivo.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          'Reporte ${archivo.formato.etiqueta}',
                          if (tamano != null) Formatos.tamano(tamano),
                          if (intercambio.estadoArchivo == EstadoArchivo.listo)
                            'Descargado',
                        ].join('  ·  '),
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (descargando) const LinearProgressIndicator(minHeight: 2),
          if (aviso != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                aviso,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: estado.peligro,
                ),
              ),
            ),
          const Divider(height: 1),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: descargando ? null : alAbrir,
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      minimumSize: const Size(0, 46),
                    ),
                    child: const Text('Abrir'),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextButton(
                    onPressed: descargando ? null : alCompartir,
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      minimumSize: const Size(0, 46),
                    ),
                    child: const Text('Guardar'),
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
