import 'package:flutter/material.dart';

import '../../app/tema.dart';

class LogoMarca extends StatelessWidget {
  const LogoMarca({this.tamano = 44, super.key});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(tamano * 0.18),
      ),
      alignment: Alignment.center,
      child: Text(
        'AR',
        style: TextStyle(
          color: ColoresMarca.marinoProfundo,
          fontSize: tamano * 0.38,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
