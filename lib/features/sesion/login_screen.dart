import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../shared/widgets/aviso_banner.dart';
import '../../shared/widgets/error_reintentar.dart';
import '../../shared/widgets/marca.dart';
import 'sesion_controller.dart';
import 'validadores.dart';

/// Pantalla 1: inicio de sesión.
///
/// Mientras se valida un token guardado muestra un indicador de carga; si la
/// validación falla por la red, ofrece reintentar o usar otra cuenta.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionController>();
    final error = sesion.errorVerificacion;

    final Widget contenido;
    if (sesion.estado != EstadoSesion.verificando) {
      contenido = const FormularioLogin();
    } else if (error != null) {
      contenido = ErrorReintentar(
        mensaje: error.mensaje,
        alReintentar: sesion.verificarSesionGuardada,
        textoSecundario: 'Usar otra cuenta',
        alAccionSecundaria: sesion.descartarSesionGuardada,
      );
    } else {
      contenido = const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando sesión...'),
          ],
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(body: _DisenoLogin(child: contenido)),
    );
  }
}

/// Encabezado de marca con degradado y una tarjeta flotante para el contenido.
class _DisenoLogin extends StatelessWidget {
  const _DisenoLogin({required this.child});

  static const _altoEncabezado = 300.0;
  static const _inicioTarjeta = 224.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final superiorSeguro = MediaQuery.paddingOf(context).top;

    return SingleChildScrollView(
      child: Stack(
        children: [
          SizedBox(
            height: _altoEncabezado + superiorSeguro,
            width: double.infinity,
            child: FondoMarca(
              radioInferior: 36,
              child: Padding(
                padding: EdgeInsets.fromLTRB(28, superiorSeguro + 32, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LogoMarca(),
                    const SizedBox(height: 20),
                    Text(
                      'Asistente Readiness',
                      style: tema.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CMMI Appraisal Readiness Platform',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              _inicioTarjeta + superiorSeguro,
              20,
              24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tema.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formulario de correo y contraseña.
class FormularioLogin extends StatefulWidget {
  const FormularioLogin({super.key});

  static const claveCorreo = Key('login-correo');
  static const claveContrasena = Key('login-contrasena');
  static const claveIngresar = Key('login-ingresar');

  @override
  State<FormularioLogin> createState() => _FormularioLoginState();
}

class _FormularioLoginState extends State<FormularioLogin> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  bool _enviando = false;
  bool _ocultarContrasena = true;
  bool _validarAlEscribir = false;
  ApiException? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (_enviando) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) {
      setState(() => _validarAlEscribir = true);
      return;
    }

    final sesion = context.read<SesionController>()..descartarAviso();
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await sesion.iniciarSesion(
        email: _correo.text.trim(),
        password: _contrasena.text,
      );
      TextInput.finishAutofillContext();
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final aviso = context.select<SesionController, String?>((s) => s.aviso);
    final error = _error;

    return Form(
      key: _formulario,
      autovalidateMode: _validarAlEscribir
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Iniciar sesión', style: tema.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Usa las mismas credenciales de la plataforma web.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (aviso != null) ...[
              AvisoBanner(mensaje: aviso, esError: false),
              const SizedBox(height: 16),
            ],
            if (error != null) ...[
              AvisoBanner(
                mensaje: error.mensaje,
                alReintentar: error.esReintentable ? _ingresar : null,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              key: FormularioLogin.claveCorreo,
              controller: _correo,
              enabled: !_enviando,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.username,
              ],
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: Validadores.correo,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: FormularioLogin.claveContrasena,
              controller: _contrasena,
              enabled: !_enviando,
              obscureText: _ocultarContrasena,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _ingresar(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _ocultarContrasena
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  icon: Icon(
                    _ocultarContrasena
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _ocultarContrasena = !_ocultarContrasena),
                ),
              ),
              validator: Validadores.contrasena,
            ),
            const SizedBox(height: 28),
            FilledButton(
              key: FormularioLogin.claveIngresar,
              onPressed: _enviando ? null : _ingresar,
              child: _enviando
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Ingresando...'),
                      ],
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Ingresar'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
