import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta de marca: azul marino corporativo con acento turquesa.
abstract final class ColoresMarca {
  static const marinoProfundo = Color(0xFF0A1F3C);
  static const marino = Color(0xFF123A6B);
  static const azulReal = Color(0xFF1D4ED8);
  static const turquesa = Color(0xFF0EA5B7);
  static const ambar = Color(0xFFF59E0B);

  static const fondoClaro = Color(0xFFF4F6FB);
  static const campoClaro = Color(0xFFEEF2F7);
  static const bordeClaro = Color(0xFFDCE3ED);
  static const textoClaro = Color(0xFF0F172A);

  static const fondoOscuro = Color(0xFF0B1220);
  static const superficieOscura = Color(0xFF121B2E);
  static const campoOscuro = Color(0xFF1A2540);
  static const bordeOscuro = Color(0xFF26324D);

  /// Degradado de los encabezados de marca.
  static const degradado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [marinoProfundo, marino, azulReal],
    stops: [0, 0.55, 1],
  );
}

/// Colores semánticos (éxito, advertencia, peligro, información).
@immutable
class ColoresEstado extends ThemeExtension<ColoresEstado> {
  const ColoresEstado({
    required this.exito,
    required this.exitoFondo,
    required this.advertencia,
    required this.advertenciaFondo,
    required this.peligro,
    required this.peligroFondo,
    required this.info,
    required this.infoFondo,
  });

  static const claro = ColoresEstado(
    exito: Color(0xFF0F8A5F),
    exitoFondo: Color(0xFFE3F6EE),
    advertencia: Color(0xFFB45309),
    advertenciaFondo: Color(0xFFFEF3E2),
    peligro: Color(0xFFC62828),
    peligroFondo: Color(0xFFFDECEC),
    info: Color(0xFF1D4ED8),
    infoFondo: Color(0xFFE8EFFD),
  );

  static const oscuro = ColoresEstado(
    exito: Color(0xFF4ADE9B),
    exitoFondo: Color(0xFF0F2E24),
    advertencia: Color(0xFFFBBF4B),
    advertenciaFondo: Color(0xFF33260F),
    peligro: Color(0xFFFF8A8A),
    peligroFondo: Color(0xFF3A1719),
    info: Color(0xFF8AB4FF),
    infoFondo: Color(0xFF16254A),
  );

  final Color exito;
  final Color exitoFondo;
  final Color advertencia;
  final Color advertenciaFondo;
  final Color peligro;
  final Color peligroFondo;
  final Color info;
  final Color infoFondo;

  static ColoresEstado de(BuildContext context) =>
      Theme.of(context).extension<ColoresEstado>() ?? claro;

  @override
  ColoresEstado copyWith({
    Color? exito,
    Color? exitoFondo,
    Color? advertencia,
    Color? advertenciaFondo,
    Color? peligro,
    Color? peligroFondo,
    Color? info,
    Color? infoFondo,
  }) {
    return ColoresEstado(
      exito: exito ?? this.exito,
      exitoFondo: exitoFondo ?? this.exitoFondo,
      advertencia: advertencia ?? this.advertencia,
      advertenciaFondo: advertenciaFondo ?? this.advertenciaFondo,
      peligro: peligro ?? this.peligro,
      peligroFondo: peligroFondo ?? this.peligroFondo,
      info: info ?? this.info,
      infoFondo: infoFondo ?? this.infoFondo,
    );
  }

  @override
  ColoresEstado lerp(ColoresEstado? other, double t) {
    if (other == null) {
      return this;
    }
    return ColoresEstado(
      exito: Color.lerp(exito, other.exito, t)!,
      exitoFondo: Color.lerp(exitoFondo, other.exitoFondo, t)!,
      advertencia: Color.lerp(advertencia, other.advertencia, t)!,
      advertenciaFondo: Color.lerp(
        advertenciaFondo,
        other.advertenciaFondo,
        t,
      )!,
      peligro: Color.lerp(peligro, other.peligro, t)!,
      peligroFondo: Color.lerp(peligroFondo, other.peligroFondo, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoFondo: Color.lerp(infoFondo, other.infoFondo, t)!,
    );
  }
}

/// Tema de la app en modo claro y oscuro.
abstract final class TemaApp {
  static const radio = 14.0;

  static ThemeData claro() => _construir(
    esquema: ColorScheme.fromSeed(seedColor: ColoresMarca.marino).copyWith(
      primary: ColoresMarca.marino,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDCE7F7),
      onPrimaryContainer: ColoresMarca.marinoProfundo,
      secondary: ColoresMarca.turquesa,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD5F3F6),
      onSecondaryContainer: const Color(0xFF053B42),
      tertiary: ColoresMarca.ambar,
      surface: Colors.white,
      onSurface: ColoresMarca.textoClaro,
      onSurfaceVariant: const Color(0xFF52607A),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: ColoresMarca.fondoClaro,
      surfaceContainer: ColoresMarca.fondoClaro,
      surfaceContainerHighest: ColoresMarca.campoClaro,
      outline: const Color(0xFF94A3B8),
      outlineVariant: ColoresMarca.bordeClaro,
      error: ColoresEstado.claro.peligro,
      errorContainer: ColoresEstado.claro.peligroFondo,
      onErrorContainer: const Color(0xFF7F1D1D),
    ),
    fondo: ColoresMarca.fondoClaro,
    campo: ColoresMarca.campoClaro,
    borde: ColoresMarca.bordeClaro,
    estado: ColoresEstado.claro,
  );

  static ThemeData oscuro() => _construir(
    esquema:
        ColorScheme.fromSeed(
          seedColor: ColoresMarca.marino,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF8AB4FF),
          onPrimary: ColoresMarca.marinoProfundo,
          primaryContainer: const Color(0xFF1B3A6B),
          onPrimaryContainer: const Color(0xFFDCE7F7),
          secondary: const Color(0xFF5FD6E3),
          onSecondary: const Color(0xFF053B42),
          secondaryContainer: const Color(0xFF0D4A52),
          onSecondaryContainer: const Color(0xFFD5F3F6),
          tertiary: const Color(0xFFFBBF4B),
          surface: ColoresMarca.superficieOscura,
          onSurface: const Color(0xFFE6EBF5),
          onSurfaceVariant: const Color(0xFFA3B0C8),
          surfaceContainerLowest: ColoresMarca.fondoOscuro,
          surfaceContainerLow: ColoresMarca.fondoOscuro,
          surfaceContainer: ColoresMarca.superficieOscura,
          surfaceContainerHighest: ColoresMarca.campoOscuro,
          outlineVariant: ColoresMarca.bordeOscuro,
          error: ColoresEstado.oscuro.peligro,
          errorContainer: ColoresEstado.oscuro.peligroFondo,
          onErrorContainer: const Color(0xFFFFD6D6),
        ),
    fondo: ColoresMarca.fondoOscuro,
    campo: ColoresMarca.campoOscuro,
    borde: ColoresMarca.bordeOscuro,
    estado: ColoresEstado.oscuro,
  );

  static ThemeData _construir({
    required ColorScheme esquema,
    required Color fondo,
    required Color campo,
    required Color borde,
    required ColoresEstado estado,
  }) {
    final base = ThemeData(colorScheme: esquema, useMaterial3: true);
    final textos = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radio),
    );
    // Borde inferior con esquinas redondeadas: la etiqueta flotante queda
    // dentro del campo relleno en lugar de cortar el contorno.
    UnderlineInputBorder bordeCampo(Color? color, [double ancho = 2]) =>
        UnderlineInputBorder(
          borderRadius: BorderRadius.circular(radio),
          borderSide: color == null
              ? BorderSide.none
              : BorderSide(color: color, width: ancho),
        );

    return base.copyWith(
      scaffoldBackgroundColor: fondo,
      textTheme: textos,
      extensions: [estado],
      appBarTheme: AppBarTheme(
        backgroundColor: ColoresMarca.marinoProfundo,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textos.titleLarge?.copyWith(color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: forma,
          textStyle: textos.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: forma,
          side: BorderSide(color: borde),
          textStyle: textos.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: forma),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: campo,
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        border: bordeCampo(null),
        enabledBorder: bordeCampo(null),
        disabledBorder: bordeCampo(null),
        focusedBorder: bordeCampo(esquema.primary),
        errorBorder: bordeCampo(esquema.error, 1),
        focusedErrorBorder: bordeCampo(esquema.error),
        prefixIconColor: esquema.onSurfaceVariant,
        suffixIconColor: esquema.onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        color: esquema.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borde),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: esquema.primaryContainer,
        indicatorShape: forma,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => textos.labelMedium?.copyWith(
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: esquema.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borde),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: forma,
      ),
      dividerTheme: DividerThemeData(color: borde, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: esquema.secondary,
      ),
    );
  }
}
