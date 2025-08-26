import 'package:flutter/material.dart';

class GlobalTheme {
  // ---------- Palette (copy/paste friendly) ----------
  // 60% - fondo blanco roto
  static const Color kBackground = Color(0xFFF6F5F9);
  // 30% - morado suave (brand)
  static const Color kPurpleBase = Color(0xFF6B5B95);
  // 10% - acento cálido / CTA
  static const Color kPeachAccent = Color(0xFFFFB86B);

  // Soporte / neutrales
  static const Color kTextDark = Color(0xFF22222A);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kBorderGray = Color(0xFFD9D7E8);
  // color lavanda claro (útil para contenedores/variantes)
  static const Color kLavender = Color(0xFFCFC0EA);

  // Dark helpers
  static const Color kDarkBackground = Color(0xFF121212);
  static const Color kDarkSurface = Color(0xFF1E1E1E);
  // morado más oscuro para contenedores en dark
  static const Color kPurpleDark = Color(0xFF4F3E71);

  // focus colors
  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  //######### COLORES MODE LIGHT ############
  static const ColorScheme _lightColorScheme = ColorScheme(
    primary: kPurpleBase,            // morado (componentes principales)
    onPrimary: kWhite,               // texto sobre morado
    secondary: kPeachAccent,         // acento / CTA
    onSecondary: kTextDark,          // texto sobre acento
    tertiary: kLavender,             // variación lavanda
    onTertiary: kTextDark,           // texto sobre lavanda

    // contenedores y fondos
    primaryContainer: kLavender,     // contenedores morado claro
    secondaryContainer: kPeachAccent,// estados activos / hover (acento)
    tertiaryContainer: kBackground,  // acentos especiales

    // errores
    error: Color(0xFFFF6B6B),        // coral para errores
    onError: kWhite,

    // superficies y fondos generales
    surface: kWhite,                 // superficies (cards, inputs)
    onSurface: kTextDark,
    background: kBackground,         // fondo general (60% blanco roto)
    onBackground: kTextDark,

    brightness: Brightness.light,
  );

  //######### COLORES MODE DARK ############
  static const ColorScheme _darkColorScheme = ColorScheme(
    primary: kPurpleBase,            // seguimos usando el morado como acento
    onPrimary: kWhite,               // texto sobre morado
    secondary: kPeachAccent,         // acento
    onSecondary: kDarkBackground,    // texto sobre acento en dark (oscuro)
    tertiary: kLavender,             // lavanda usada con cuidado en dark
    onTertiary: kDarkBackground,

    // contenedores y fondos
    primaryContainer: kPurpleDark,   // contenedores morados oscuros
    secondaryContainer: kPeachAccent,// acento (resalta)
    tertiaryContainer: kDarkSurface, // acentos especiales

    // errores
    error: Color(0xFFFF6B6B),
    onError: kDarkBackground,

    // superficies y fondos generales
    surface: kDarkSurface,           // cards / superficies oscuras
    onSurface: kWhite,
    background: kDarkBackground,     // fondo general oscuro
    onBackground: kWhite,

    brightness: Brightness.dark,
  );

  static ThemeData lightThemeData =
      _themeData(_lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData =
      _themeData(_darkColorScheme, _darkFocusColor);

  static ThemeData _themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      iconTheme: _iconTheme(colorScheme),
      textTheme: _textTheme(colorScheme),
      appBarTheme: _appBarTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.primary,
      iconTheme: _iconTheme(colorScheme),
      titleTextStyle: TextStyle(
        color: colorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSecondary,
        backgroundColor: colorScheme.secondary,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onSecondary == kWhite ? kTextDark : colorScheme.onSecondary,
        backgroundColor: colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        fixedSize: const Size.fromHeight(56),
      ),
    );
  }

  static IconThemeData _iconTheme(ColorScheme colorScheme) {
    return IconThemeData(color: colorScheme.onPrimary, size: 25);
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 34.0, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
      displayMedium: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      fillColor: colorScheme.onPrimary.withOpacity(0.04),
      filled: true,
      hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.6)),
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: colorScheme.onPrimary.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(22.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: colorScheme.secondary.withOpacity(0.25), width: 1),
        borderRadius: BorderRadius.circular(22.5),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
    );
  }
}
