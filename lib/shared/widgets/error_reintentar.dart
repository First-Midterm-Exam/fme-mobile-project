import 'package:flutter/material.dart';

class ErrorReintentar extends StatelessWidget {
  const ErrorReintentar({
    required this.mensaje,
    this.alReintentar,
    this.textoSecundario,
    this.alAccionSecundaria,
    super.key,
  });

  final String mensaje;
  final VoidCallback? alReintentar;
  final String? textoSecundario;
  final VoidCallback? alAccionSecundaria;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 36,
              color: tema.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
            if (alReintentar != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: alReintentar,
                child: const Text('Reintentar'),
              ),
            ],
            if (textoSecundario != null && alAccionSecundaria != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: alAccionSecundaria,
                child: Text(textoSecundario!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
