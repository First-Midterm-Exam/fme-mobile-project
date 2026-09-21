import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/documento_repository.dart';
import '../../shared/formatos.dart';
import '../../shared/widgets/aviso_banner.dart';
import '../../shared/widgets/estructura.dart';
import '../../shared/widgets/permiso_denegado.dart';
import 'camara_documentos.dart';
import 'documento_controller.dart';
import 'resultado_revision_view.dart';

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
        titulo: 'Se necesita acceso a la cámara',
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
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey(controlador.paso), child: contenido),
    );
  }
}

class _Inicio extends StatelessWidget {
  const _Inicio();

  static const _recomendaciones = [
    'Usa buena luz y evita reflejos o sombras.',
    'Encuadra la página completa, sin cortar los bordes.',
    'Mantén el teléfono paralelo al documento.',
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controlador = context.watch<DocumentoController>();
    final aviso = controlador.aviso;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              const TituloSeccion('Revisión de formato'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verifica si un documento cumple el formato',
                        style: tema.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      const TextoSecundario(
                        'Toma una foto del documento. El servidor analizará su '
                        'estructura y te indicará los hallazgos ordenados por '
                        'severidad.',
                      ),
                    ],
                  ),
                ),
              ),
              const TituloSeccion('Recomendaciones'),
              GrupoSeccion(
                children: [
                  for (var i = 0; i < _recomendaciones.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${i + 1}.',
                              style: tema.textTheme.bodyMedium?.copyWith(
                                color: tema.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _recomendaciones[i],
                              style: tema.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (aviso != null) ...[
                const SizedBox(height: 16),
                AvisoBanner(mensaje: aviso),
              ],
            ],
          ),
        ),
        BarraAccionInferior(
          child: FilledButton.icon(
            onPressed: controlador.abriendoCamara
                ? null
                : controlador.tomarFoto,
            icon: controlador.abriendoCamara
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.photo_camera_outlined, size: 20),
            label: const Text('Tomar foto del documento'),
          ),
        ),
      ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: TituloSeccion(
            'Vista previa',
            accion: foto == null || analizando
                ? null
                : Text(
                    '${Formatos.tamano(foto.length)} · JPEG',
                    style: tema.textTheme.labelMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: radioTarjeta,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: const Color(0xFF1A2230),
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
        ),
        if (aviso != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AvisoBanner(
              mensaje: aviso,
              alReintentar: controlador.avisoReintentable
                  ? controlador.enviar
                  : null,
            ),
          ),
        const SizedBox(height: 12),
        if (!analizando)
          BarraAccionInferior(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controlador.abriendoCamara
                        ? null
                        : controlador.tomarFoto,
                    child: const Text('Tomar otra'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: controlador.puedeEnviar
                        ? controlador.enviar
                        : null,
                    child: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Analizando extends StatelessWidget {
  const _Analizando();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Analizando el formato...',
              style: tema.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
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
