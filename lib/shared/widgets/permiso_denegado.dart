import 'package:flutter/material.dart';

/// Explica para qué se necesita un permiso denegado y ofrece cómo darlo.
class PermisoDenegado extends StatelessWidget {
  const PermisoDenegado({
    required this.icono,
    required this.titulo,
    required this.explicacion,
    required this.permanente,
    required this.alReintentar,
    required this.alAbrirAjustes,
    this.alVolver,
    super.key,
  });

  final IconData icono;
  final String titulo;
  final String explicacion;

  /// Si es `true`, Android ya no muestra el diálogo y hay que ir a ajustes.
  final bool permanente;
  final VoidCallback alReintentar;
  final VoidCallback alAbrirAjustes;
  final VoidCallback? alVolver;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colores.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 40, color: colores.error),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              explicacion,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: colores.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (permanente) ...[
              const SizedBox(height: 12),
              Text(
                'Actívalo en Ajustes > Permisos y luego vuelve a la app.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: permanente
                  ? FilledButton.icon(
                      onPressed: alAbrirAjustes,
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Abrir ajustes'),
                    )
                  : FilledButton(
                      onPressed: alReintentar,
                      child: const Text('Dar permiso'),
                    ),
            ),
            const SizedBox(height: 8),
            if (permanente)
              TextButton(
                onPressed: alReintentar,
                child: const Text('Ya lo activé, intentar de nuevo'),
              ),
            if (alVolver != null)
              TextButton(onPressed: alVolver, child: const Text('Volver')),
          ],
        ),
      ),
    );
  }
}
