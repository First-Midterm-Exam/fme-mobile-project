import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class ColoresMarca {
  static const marinoProfundo = Color(0xFF0B2240);
  static const marino = Color(0xFF123B6D);
  static const acento = Color(0xFF1F6FB2);

  static const fondoClaro = Color(0xFFECEFF4);
  static const superficieClara = Colors.white;
  static const bordeClaro = Color(0xFFD5DBE5);
  static const textoClaro = Color(0xFF14202E);
  static const textoSecundarioClaro = Color(0xFF5B6778);

  static const fondoOscuro = Color(0xFF0D131C);
  static const superficieOscura = Color(0xFF161E2A);
  static const bordeOscuro = Color(0xFF2A3445);
}

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
    exito: Color(0xFF1B7A4B),
    exitoFondo: Color(0xFFE6F3EC),
    advertencia: Color(0xFFA15C07),
    advertenciaFondo: Color(0xFFFBF1E3),
    peligro: Color(0xFFB42318),
    peligroFondo: Color(0xFFFBEAE9),
    info: Color(0xFF1F5FA8),
    infoFondo: Color(0xFFE8F0F9),
  );

  static const oscuro = ColoresEstado(
    exito: Color(0xFF5CC98D),
    exitoFondo: Color(0xFF12291D),
    advertencia: Color(0xFFE9B05A),
    advertenciaFondo: Color(0xFF2E2413),
    peligro: Color(0xFFF08A82),
    peligroFondo: Color(0xFF331816),
    info: Color(0xFF86B4E8),
    infoFondo: Color(0xFF15253A),
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

abstract final class TemaApp {
  static const radio = 10.0;
  static const radioTarjeta = 12.0;

  static ThemeData claro() => _construir(
    esquema: ColorScheme.fromSeed(seedColor: ColoresMarca.marino).copyWith(
      primary: ColoresMarca.marino,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE3EAF3),
      onPrimaryContainer: ColoresMarca.marinoProfundo,
      secondary: ColoresMarca.acento,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFEEF2F7),
      onSecondaryContainer: ColoresMarca.textoClaro,
      surface: ColoresMarca.superficieClara,
      onSurface: ColoresMarca.textoClaro,
      onSurfaceVariant: ColoresMarca.textoSecundarioClaro,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF6F8FB),
      surfaceContainer: const Color(0xFFF2F4F8),
      surfaceContainerHigh: const Color(0xFFEDF0F5),
      surfaceContainerHighest: const Color(0xFFE6EAF0),
      outline: const Color(0xFF8B96A6),
      outlineVariant: ColoresMarca.bordeClaro,
      error: ColoresEstado.claro.peligro,
      errorContainer: ColoresEstado.claro.peligroFondo,
      onErrorContainer: const Color(0xFF7A1A12),
    ),
    fondo: ColoresMarca.fondoClaro,
    borde: ColoresMarca.bordeClaro,
    estado: ColoresEstado.claro,
  );

  static ThemeData oscuro() => _construir(
    esquema:
        ColorScheme.fromSeed(
          seedColor: ColoresMarca.marino,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF8DB6E6),
          onPrimary: ColoresMarca.marinoProfundo,
          primaryContainer: const Color(0xFF1C3354),
          onPrimaryContainer: const Color(0xFFE3EAF3),
          secondary: const Color(0xFF8DB6E6),
          onSecondary: ColoresMarca.marinoProfundo,
          secondaryContainer: const Color(0xFF1E2837),
          onSecondaryContainer: const Color(0xFFE3E8EF),
          surface: ColoresMarca.superficieOscura,
          onSurface: const Color(0xFFE3E8EF),
          onSurfaceVariant: const Color(0xFF9AA6B8),
          surfaceContainerLowest: ColoresMarca.fondoOscuro,
          surfaceContainerLow: const Color(0xFF131A25),
          surfaceContainer: const Color(0xFF1A2230),
          surfaceContainerHigh: const Color(0xFF1E2837),
          surfaceContainerHighest: const Color(0xFF232E3F),
          outlineVariant: ColoresMarca.bordeOscuro,
          error: ColoresEstado.oscuro.peligro,
          errorContainer: ColoresEstado.oscuro.peligroFondo,
          onErrorContainer: const Color(0xFFFFD9D6),
        ),
    fondo: ColoresMarca.fondoOscuro,
    borde: ColoresMarca.bordeOscuro,
    estado: ColoresEstado.oscuro,
  );

  static ThemeData _construir({
    required ColorScheme esquema,
    required Color fondo,
    required Color borde,
    required ColoresEstado estado,
  }) {
    final base = ThemeData(colorScheme: esquema, useMaterial3: true);
    final textos = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radio),
    );
    OutlineInputBorder bordeCampo(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radio),
          borderSide: BorderSide(color: color, width: ancho),
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
        toolbarHeight: 56,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textos.titleMedium?.copyWith(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: forma,
          textStyle: textos.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: forma,
          side: BorderSide(color: esquema.outline),
          foregroundColor: esquema.primary,
          textStyle: textos.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: forma),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: bordeCampo(esquema.outline),
        enabledBorder: bordeCampo(borde),
        disabledBorder: bordeCampo(borde),
        focusedBorder: bordeCampo(esquema.primary, 1.6),
        errorBorder: bordeCampo(esquema.error),
        focusedErrorBorder: bordeCampo(esquema.error, 1.6),
        prefixIconColor: esquema.onSurfaceVariant,
        suffixIconColor: esquema.onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        color: esquema.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radioTarjeta),
          side: BorderSide(color: borde),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        visualDensity: VisualDensity.compact,
        titleTextStyle: textos.bodyLarge?.copyWith(
          color: esquema.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textos.bodyMedium?.copyWith(
          color: esquema.onSurfaceVariant,
        ),
        iconColor: esquema.onSurfaceVariant,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: esquema.surface,
        side: BorderSide(color: borde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: textos.labelLarge?.copyWith(
          color: esquema.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: esquema.primaryContainer,
        indicatorShape: forma,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => textos.labelMedium?.copyWith(
            color: estados.contains(WidgetState.selected)
                ? esquema.primary
                : esquema.onSurfaceVariant,
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? esquema.primary
                : esquema.onSurfaceVariant,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: esquema.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radioTarjeta),
          side: BorderSide(color: borde),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: fondo,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: esquema.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: forma,
      ),
      dividerTheme: DividerThemeData(color: borde, space: 1, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: esquema.primary,
      ),
    );
  }
}
