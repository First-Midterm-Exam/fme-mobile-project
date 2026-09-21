import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../data/simulacion/datos_simulados.dart';
import '../../shared/widgets/error_reintentar.dart';
import 'sesion_controller.dart';

/// Pantalla 1: inicio de sesión.
///
/// Etapa 1: versión provisional con un botón que entra con el usuario demo.
/// El formulario completo se construye en la etapa 2.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _enviando = false;

  Future<void> _ingresarDemo() async {
    final sesion = context.read<SesionController>();
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _enviando = true);
    try {
      await sesion.iniciarSesion(email: emailDemo, password: passwordDemo);
    } on ApiException catch (error) {
      mensajero.showSnackBar(SnackBar(content: Text(error.mensaje)));
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionController>();
    final error = sesion.errorVerificacion;

    final Widget contenido;
    if (sesion.estado == EstadoSesion.verificando && error != null) {
      contenido = ErrorReintentar(
        mensaje: error.mensaje,
        alReintentar: sesion.verificarSesionGuardada,
      );
    } else if (sesion.estado == EstadoSesion.verificando) {
      contenido = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando sesión...'),
          ],
        ),
      );
    } else {
      contenido = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Asistente Readiness',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (sesion.aviso != null) ...[
              const SizedBox(height: 16),
              Text(sesion.aviso!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _enviando ? null : _ingresarDemo,
              child: const Text('Ingresar con usuario demo (provisional)'),
            ),
          ],
        ),
      );
    }

    return Scaffold(body: SafeArea(child: contenido));
  }
}
