import 'package:flutter/material.dart';

import '../../app/tema.dart';

class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {this.accion, super.key});

  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto.toUpperCase(),
              style: tema.textTheme.labelMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ?accion,
        ],
      ),
    );
  }
}

class GrupoSeccion extends StatelessWidget {
  const GrupoSeccion({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

class BarraAccionInferior extends StatelessWidget {
  const BarraAccionInferior({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surface,
        border: Border(top: BorderSide(color: colores.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}

class Etiqueta extends StatelessWidget {
  const Etiqueta({
    required this.texto,
    required this.color,
    required this.fondo,
    super.key,
  });

  final String texto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class TextoSecundario extends StatelessWidget {
  const TextoSecundario(this.texto, {this.alineacion, super.key});

  final String texto;
  final TextAlign? alineacion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Text(
      texto,
      textAlign: alineacion,
      style: tema.textTheme.bodyMedium?.copyWith(
        color: tema.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}

BorderRadius get radioTarjeta => BorderRadius.circular(TemaApp.radioTarjeta);
