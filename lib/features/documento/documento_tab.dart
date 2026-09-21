import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/documento_repository.dart';
import '../../shared/formatos.dart';
import '../../shared/widgets/aviso_banner.dart';
import '../../shared/widgets/marca.dart';
import '../../shared/widgets/permiso_denegado.dart';
import 'camara_documentos.dart';
import 'documento_controller.dart';
import 'resultado_revision_view.dart';

/// Pestaña "Documento": revisar el formato de un documento con la cámara.
class DocumentoTab extends StatelessWidget {
  const DocumentoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controlador = DocumentoController(
          repositorio: context.read<DocumentoRepository>(),
          camara: context.read<CamaraDocumentos>(),
        );
        unawaited(controlador.recuperarFotoPendiente());
        return controlador;
      },
      child: const _ContenidoDocumento(),
    );
  }
}

class _ContenidoDocumento extends StatelessWidget {
  const _ContenidoDocumento();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<DocumentoController>();
    final resultado = controlador.resultado;

    final Widget contenido = switch (controlador.paso) {
      PasoDocumento.inicio => const _Inicio(),
      PasoDocumento.permisoDenegado => PermisoDenegado(
        icono: Icons.no_photography_outlined,
        titulo: 'Necesitamos acceso a la cámara',
        explicacion:
            'La cámara se usa solo para fotografiar el documento que quieres '
            'revisar. La foto se envía al servidor para analizar su formato '
            'y no se guarda en tu teléfono.',
        permanente: controlador.permisoPermanente,
        alReintentar: controlador.tomarFoto,
        alAbrirAjustes: controlador.abrirAjustes,
        alVolver: controlador.reiniciar,
      ),
      PasoDocumento.vistaPrevia ||
      PasoDocumento.analizando => const _VistaPrevia(),
      PasoDocumento.resultado when resultado != null => ResultadoRevisionView(
        resultado: resultado,
        alRevisarOtro: controlador.reiniciar,
      ),
      PasoDocumento.resultado => const _Inicio(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(controlador.paso), child: contenido),
    );
  }
}

class _Inicio extends StatelessWidget {
  const _Inicio();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controlador = context.watch<DocumentoController>();
    final aviso = controlador.aviso;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FondoMarca(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LogoMarca(tamano: 52),
                  const SizedBox(height: 16),
                  Text(
                    'Revisión de formato',
                    style: tema.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toma una foto del documento y verificaremos si cumple '
                    'el formato esperado por la organización.',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Consejo(
                  icono: Icons.wb_sunny_outlined,
                  texto: 'Usa buena luz y evita reflejos o sombras.',
                ),
                _Consejo(
                  icono: Icons.crop_free_rounded,
                  texto: 'Encuadra la página completa, sin cortar bordes.',
                ),
                _Consejo(
                  icono: Icons.straighten_rounded,
                  texto: 'Mantén el teléfono paralelo al documento.',
                ),
              ],
            ),
          ),
        ),
        if (aviso != null) ...[
          const SizedBox(height: 16),
          AvisoBanner(mensaje: aviso),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: controlador.abriendoCamara ? null : controlador.tomarFoto,
          icon: controlador.abriendoCamara
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_camera_outlined),
          label: const Text('Tomar foto del documento'),
        ),
      ],
    );
  }
}

class _Consejo extends StatelessWidget {
  const _Consejo({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colores.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 20, color: colores.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}

class _VistaPrevia extends StatelessWidget {
  const _VistaPrevia();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<DocumentoController>();
    final foto = controlador.foto;
    final analizando = controlador.paso == PasoDocumento.analizando;
    final aviso = controlador.aviso;
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: const Color(0xFF0B1220),
                    child: foto == null
                        ? const SizedBox.shrink()
                        : LayoutBuilder(
                            builder: (context, restricciones) => Image.memory(
                              foto,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                              cacheWidth:
                                  (restricciones.maxWidth *
                                          MediaQuery.devicePixelRatioOf(
                                            context,
                                          ))
                                      .round(),
                              semanticLabel: 'Foto del documento',
                            ),
                          ),
                  ),
                  if (analizando) const _Analizando(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (foto != null && !analizando)
            Text(
              'Foto lista · ${Formatos.tamano(foto.length)} · JPEG',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          if (aviso != null) ...[
            const SizedBox(height: 12),
            AvisoBanner(
              mensaje: aviso,
              alReintentar: controlador.avisoReintentable
                  ? controlador.enviar
                  : null,
            ),
          ],
          if (!analizando) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controlador.abriendoCamara
                        ? null
                        : controlador.tomarFoto,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Tomar otra'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controlador.puedeEnviar
                        ? controlador.enviar
                        : null,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Analizando extends StatelessWidget {
  const _Analizando();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 56,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Analizando el formato...',
              style: tema.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Puede tardar hasta un minuto.',
              style: tema.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
