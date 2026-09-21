import 'package:flutter/material.dart';

import '../../app/tema.dart';

/// Logotipo de la app: insignia translúcida sobre fondos de marca.
class LogoMarca extends StatelessWidget {
  const LogoMarca({this.tamano = 56, super.key});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(tamano * 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Icon(
        Icons.fact_check_rounded,
        color: Colors.white,
        size: tamano * 0.54,
      ),
    );
  }
}

/// Fondo con el degradado de marca y formas decorativas sutiles.
class FondoMarca extends StatelessWidget {
  const FondoMarca({required this.child, this.radioInferior = 0, super.key});

  final Widget child;
  final double radioInferior;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(radioInferior),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: ColoresMarca.degradado),
        child: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -60,
              child: _Circulo(diametro: 240, opacidad: 0.08),
            ),
            const Positioned(
              bottom: -110,
              left: -70,
              child: _Circulo(diametro: 220, opacidad: 0.06),
            ),
            Positioned(
              top: 40,
              right: 36,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: ColoresMarca.turquesa,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  const _Circulo({required this.diametro, required this.opacidad});

  final double diametro;
  final double opacidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacidad * 2),
          width: 28,
        ),
      ),
    );
  }
}
