import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/tema.dart';
import '../../data/models/appraisal.dart';
import '../../data/repositories/asistente_repository.dart';
import '../../shared/widgets/estructura.dart';
import '../appraisals/appraisal_controller.dart';
import 'asistente_controller.dart';
import 'servicios/archivos_reporte.dart';
import 'servicios/lector_voz.dart';
import 'servicios/reconocedor_voz.dart';
import 'widgets/boton_microfono.dart';
import 'widgets/burbujas.dart';

class AsistenteTab extends StatelessWidget {
  const AsistenteTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appraisals = context.read<AppraisalController>();
        return AsistenteController(
          repositorio: context.read<AsistenteRepository>(),
          reconocedor: context.read<ReconocedorVoz>(),
          lector: context.read<LectorVoz>(),
          archivos: context.read<ArchivosReporte>(),
          appraisalActivo: () => appraisals.seleccionado,
        );
      },
      child: const _ContenidoAsistente(),
    );
  }
}

class _ContenidoAsistente extends StatefulWidget {
  const _ContenidoAsistente();

  @override
  State<_ContenidoAsistente> createState() => _ContenidoAsistenteState();
}

class _ContenidoAsistenteState extends State<_ContenidoAsistente> {
  final _desplazamiento = ScrollController();
  int _elementosPrevios = 0;

  @override
  void dispose() {
    _desplazamiento.dispose();
    super.dispose();
  }

  void _bajarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_desplazamiento.hasClients) {
        _desplazamiento.animateTo(
          _desplazamiento.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AsistenteController>();
    context.select<AppraisalController, Appraisal?>((c) => c.seleccionado);
    final intercambios = controlador.intercambios;
    final elementos =
        intercambios.length * 2 + intercambios.where((i) => !i.enCurso).length;
    if (elementos != _elementosPrevios) {
      _elementosPrevios = elementos;
      _bajarAlFinal();
    }

    return Column(
      children: [
        Expanded(
          child: intercambios.isEmpty
              ? const _Inicio()
              : ListView.separated(
                  controller: _desplazamiento,
                  padding: const EdgeInsets.all(16),
                  itemCount: intercambios.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (context, indice) {
                    final intercambio = intercambios[indice];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BurbujaPregunta(texto: intercambio.pregunta),
                        const SizedBox(height: 8),
                        TarjetaRespuesta(
                          intercambio: intercambio,
                          puedeReintentar: controlador.puedePreguntar,
                          alReintentar: () =>
                              controlador.reintentar(intercambio),
                          alCompartir: () =>
                              controlador.compartirReporte(intercambio),
                          alAbrirArchivo: () =>
                              controlador.abrirArchivo(intercambio),
                          alCompartirArchivo: () =>
                              controlador.compartirArchivo(intercambio),
                        ),
                      ],
                    );
                  },
                ),
        ),
        const _PanelVoz(),
      ],
    );
  }
}

class _Inicio extends StatelessWidget {
  const _Inicio();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controlador = context.watch<AsistenteController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        const TituloSeccion('Asistente de preparación'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consulta el estado del appraisal',
                  style: tema.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const TextoSecundario(
                  'Haz tu pregunta con el micrófono o elige una consulta '
                  'frecuente. También puedes pedir un reporte en PDF o Excel '
                  'con los datos actuales.',
                ),
              ],
            ),
          ),
        ),
        const TituloSeccion('Consultas frecuentes'),
        GrupoSeccion(
          children: [
            for (final pregunta in AsistenteController.preguntasSugeridas)
              ListTile(
                title: Text(pregunta),
                trailing: const Icon(Icons.chevron_right),
                enabled: controlador.puedePreguntar,
                onTap: () => controlador.preguntar(pregunta),
              ),
          ],
        ),
      ],
    );
  }
}

class _PanelVoz extends StatelessWidget {
  const _PanelVoz();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final controlador = context.watch<AsistenteController>();
    final hayConversacion = controlador.intercambios.isNotEmpty;
    final escuchandoConTexto =
        controlador.estado == EstadoAsistente.escuchando &&
        controlador.transcripcion.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surface,
        border: Border(top: BorderSide(color: colores.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AvisoPanel(),
            if (hayConversacion) ...[
              const _SugerenciasCompactas(),
              const SizedBox(height: 6),
            ],
            Text(
              _textoEstado(controlador),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: escuchandoConTexto
                  ? tema.textTheme.titleSmall
                  : tema.textTheme.bodySmall?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
            ),
            Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                BotonMicrofono(
                  estado: controlador.estado,
                  nivelSonido: controlador.nivelSonido,
                  habilitado: controlador.microfonoHabilitado,
                  alPresionar: controlador.alternarMicrofono,
                ),
                Expanded(
                  child: controlador.estado == EstadoAsistente.respondiendo
                      ? Center(
                          child: OutlinedButton(
                            onPressed: controlador.detenerLectura,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            child: const Text('Detener'),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _textoEstado(AsistenteController controlador) {
    return switch (controlador.estado) {
      EstadoAsistente.escuchando =>
        controlador.transcripcion.isEmpty
            ? 'Escuchando...'
            : controlador.transcripcion,
      EstadoAsistente.procesando => 'Procesando la consulta...',
      EstadoAsistente.respondiendo => 'Leyendo el resumen',
      EstadoAsistente.inactivo => 'Toca el micrófono para preguntar',
    };
  }
}

class _SugerenciasCompactas extends StatelessWidget {
  const _SugerenciasCompactas();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AsistenteController>();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AsistenteController.preguntasSugeridas.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, indice) {
          final pregunta = AsistenteController.preguntasSugeridas[indice];
          return ActionChip(
            label: Text(pregunta),
            onPressed: controlador.puedePreguntar
                ? () => controlador.preguntar(pregunta)
                : null,
          );
        },
      ),
    );
  }
}

class _AvisoPanel extends StatelessWidget {
  const _AvisoPanel();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AsistenteController>();
    final estado = ColoresEstado.de(context);

    final String? mensaje;
    Widget? accion;
    var esError = false;

    if (!controlador.hayAppraisal) {
      mensaje = 'Selecciona un appraisal para usar el asistente.';
      esError = true;
    } else if (controlador.estaBloqueado) {
      mensaje =
          'Hiciste demasiadas consultas. Podrás preguntar de nuevo en '
          '${controlador.segundosDeEspera} s.';
      esError = true;
    } else {
      switch (controlador.microfono) {
        case AccesoMicrofono.denegado:
          mensaje =
              'Sin acceso al micrófono. Se usa solo para escuchar tu '
              'pregunta; también puedes usar las consultas frecuentes.';
          accion = TextButton(
            onPressed: controlador.alternarMicrofono,
            child: const Text('Dar permiso'),
          );
        case AccesoMicrofono.bloqueado:
          mensaje =
              'El micrófono está desactivado para esta aplicación. Actívalo '
              'en Ajustes o usa las consultas frecuentes.';
          accion = TextButton(
            onPressed: controlador.abrirAjustes,
            child: const Text('Ajustes'),
          );
        case AccesoMicrofono.noDisponible:
          mensaje =
              'El reconocimiento de voz no está disponible en este teléfono. '
              'Usa las consultas frecuentes.';
        case AccesoMicrofono.sinSolicitar || AccesoMicrofono.concedido:
          mensaje = controlador.aviso;
      }
    }

    if (mensaje == null) {
      return const SizedBox.shrink();
    }
    final acento = esError ? estado.peligro : estado.advertencia;
    final fondo = esError ? estado.peligroFondo : estado.advertenciaFondo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(TemaApp.radio),
          border: Border.all(color: acento.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                mensaje,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ?accion,
          ],
        ),
      ),
    );
  }
}
