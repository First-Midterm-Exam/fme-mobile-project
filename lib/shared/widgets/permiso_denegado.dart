import 'package:flutter/material.dart';

import 'estructura.dart';

class PermisoDenegado extends StatelessWidget {
  const PermisoDenegado({
    required this.titulo,
    required this.explicacion,
    required this.permanente,
    required this.alReintentar,
    required this.alAbrirAjustes,
    this.alVolver,
    super.key,
  });

  final String titulo;
  final String explicacion;
  final bool permanente;
  final VoidCallback alReintentar;
  final VoidCallback alAbrirAjustes;
  final VoidCallback? alVolver;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              const TituloSeccion('Permiso requerido'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: tema.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextoSecundario(explicacion),
                      if (permanente) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        const TextoSecundario(
                          'El permiso está desactivado. Actívalo en Ajustes > '
                          'Permisos y luego vuelve a la aplicación.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        BarraAccionInferior(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (permanente)
                FilledButton(
                  onPressed: alAbrirAjustes,
                  child: const Text('Abrir ajustes'),
                )
              else
                FilledButton(
                  onPressed: alReintentar,
                  child: const Text('Dar permiso'),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (alVolver != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: alVolver,
                        child: const Text('Volver'),
                      ),
                    ),
                  if (alVolver != null && permanente) const SizedBox(width: 12),
                  if (permanente)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: alReintentar,
                        child: const Text('Intentar de nuevo'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
