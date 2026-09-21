import 'package:flutter/material.dart';

import '../../../app/tema.dart';
import '../asistente_controller.dart';

class BotonMicrofono extends StatefulWidget {
  const BotonMicrofono({
    required this.estado,
    required this.nivelSonido,
    required this.habilitado,
    required this.alPresionar,
    super.key,
  });

  static const tamano = 64.0;

  final EstadoAsistente estado;
  final double nivelSonido;
  final bool habilitado;
  final VoidCallback alPresionar;

  @override
  State<BotonMicrofono> createState() => _BotonMicrofonoState();
}

class _BotonMicrofonoState extends State<BotonMicrofono>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _actualizarPulso();
  }

  @override
  void didUpdateWidget(BotonMicrofono anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.estado != widget.estado) {
      _actualizarPulso();
    }
  }

  void _actualizarPulso() {
    if (widget.estado == EstadoAsistente.escuchando ||
        widget.estado == EstadoAsistente.respondiendo) {
      _pulso.repeat();
    } else {
      _pulso
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final estadoColores = ColoresEstado.de(context);
    final escuchando = widget.estado == EstadoAsistente.escuchando;
    final procesando = widget.estado == EstadoAsistente.procesando;
    final respondiendo = widget.estado == EstadoAsistente.respondiendo;

    final Color color;
    if (!widget.habilitado && !escuchando) {
      color = colores.outline;
    } else if (escuchando) {
      color = estadoColores.peligro;
    } else {
      color = colores.primary;
    }

    final icono = switch (widget.estado) {
      EstadoAsistente.escuchando => Icons.stop,
      EstadoAsistente.respondiendo => Icons.graphic_eq,
      _ => Icons.mic,
    };

    final etiqueta = switch (widget.estado) {
      EstadoAsistente.inactivo => 'Hablar con el asistente',
      EstadoAsistente.escuchando => 'Dejar de escuchar y enviar',
      EstadoAsistente.procesando => 'Procesando la pregunta',
      EstadoAsistente.respondiendo => 'Hacer otra pregunta',
    };

    return Semantics(
      button: true,
      enabled: widget.habilitado || escuchando,
      label: etiqueta,
      child: SizedBox.square(
        dimension: BotonMicrofono.tamano * 1.6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulso,
              builder: (context, _) => CustomPaint(
                size: Size.square(BotonMicrofono.tamano * 1.6),
                painter: _Ondas(
                  progreso: _pulso.value,
                  color: color,
                  intensidad: escuchando ? 0.35 + widget.nivelSonido : 0.5,
                  visible: escuchando || respondiendo,
                ),
              ),
            ),
            if (procesando)
              SizedBox.square(
                dimension: BotonMicrofono.tamano + 14,
                child: CircularProgressIndicator(strokeWidth: 3, color: color),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: BotonMicrofono.tamano,
              height: BotonMicrofono.tamano,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: (widget.habilitado || escuchando) && !procesando
                      ? widget.alPresionar
                      : null,
                  child: Icon(icono, color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ondas extends CustomPainter {
  const _Ondas({
    required this.progreso,
    required this.color,
    required this.intensidad,
    required this.visible,
  });

  final double progreso;
  final Color color;
  final double intensidad;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) {
      return;
    }
    final centro = size.center(Offset.zero);
    final radioBase = BotonMicrofono.tamano / 2;
    final alcance = (size.width / 2 - radioBase) * intensidad.clamp(0.3, 1);
    for (var i = 0; i < 3; i++) {
      final fase = (progreso + i / 3) % 1;
      final pintura = Paint()
        ..color = color.withValues(alpha: (1 - fase) * 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centro, radioBase + alcance * fase, pintura);
    }
  }

  @override
  bool shouldRepaint(_Ondas anterior) =>
      anterior.progreso != progreso ||
      anterior.intensidad != intensidad ||
      anterior.color != color ||
      anterior.visible != visible;
}
