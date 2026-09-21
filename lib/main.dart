import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/dependencias.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.cargar();
  final dependencias = await Dependencias.crear(config);
  runApp(AsistenteReadinessApp(dependencias: dependencias));
}
