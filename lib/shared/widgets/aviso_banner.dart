import 'package:flutter/material.dart';

import '../../app/tema.dart';

class AvisoBanner extends StatelessWidget {
  const AvisoBanner({
    required this.mensaje,
    this.esError = true,
    this.alReintentar,
    super.key,
  });

  final String mensaje;
  final bool esError;

  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    final estado = ColoresEstado.de(context);
    final acento = esError ? estado.peligro : estado.info;
    final fondo = esError ? estado.peligroFondo : estado.infoFondo;

    return Semantics(
      liveRegion: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TemaApp.radio),
        child: Container(
          decoration: BoxDecoration(
            color: fondo,
            border: Border(left: BorderSide(color: acento, width: 4)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Icon(
                esError
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: acento,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensaje,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
              if (alReintentar != null)
                TextButton(
                  onPressed: alReintentar,
                  style: TextButton.styleFrom(foregroundColor: acento),
                  child: const Text('Reintentar'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
