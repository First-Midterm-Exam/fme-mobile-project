import 'package:flutter/material.dart';

import '../appraisals/selector_appraisal.dart';
import '../asistente/asistente_tab.dart';
import '../documento/documento_tab.dart';
import '../sesion/menu_usuario.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _pestana = 0;

  static const _titulos = ['Asistente', 'Revisión de documentos'];

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_pestana]),
        actions: const [MenuUsuario(), SizedBox(width: 8)],
        bottom: const BarraContextoAppraisal(),
      ),
      body: IndexedStack(
        index: _pestana,
        children: const [AsistenteTab(), DocumentoTab()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colores.outlineVariant)),
        ),
        child: NavigationBar(
          selectedIndex: _pestana,
          onDestinationSelected: (indice) => setState(() => _pestana = indice),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.mic_none),
              selectedIcon: Icon(Icons.mic),
              label: 'Asistente',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Documento',
            ),
          ],
        ),
      ),
    );
  }
}
