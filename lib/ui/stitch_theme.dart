import 'package:flutter/material.dart';

class StitchColors {
  static const background = Color(0xFF0A0510);
  static const surface = Color(0xFF1F0E13);
  static const surfaceContainer = Color(0xFF2D1A1F);
  static const surfaceContainerHigh = Color(0xFF382529);
  static const outline = Color(0xFFAC878F);
  static const primary = Color(0xFFFFB1C3);
  static const primaryContainer = Color(0xFFFF4B89);
  static const secondary = Color(0xFFDFB7FF);
  static const secondaryContainer = Color(0xFF9D05FF);
  static const tertiary = Color(0xFF2AE500);
  static const onSurface = Color(0xFFFBDAE0);
  static const onSurfaceVariant = Color(0xFFE5BCC4);
  static const onPrimary = Color(0xFF66002C);
  static const onSecondary = Color(0xFF4B007E);
  static const onTertiary = Color(0xFF053900);
}

ThemeData buildStitchTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  const colorScheme = ColorScheme.dark(
    primary: StitchColors.primary,
    onPrimary: StitchColors.onPrimary,
    secondary: StitchColors.secondary,
    onSecondary: StitchColors.onSecondary,
    tertiary: StitchColors.tertiary,
    onTertiary: StitchColors.onTertiary,
    surface: StitchColors.surface,
    onSurface: StitchColors.onSurface,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: StitchColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: StitchColors.surface,
      foregroundColor: StitchColors.primary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: StitchColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: StitchColors.outline, width: 2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black,
      hintStyle: const TextStyle(color: StitchColors.onSurfaceVariant),
      labelStyle: const TextStyle(color: StitchColors.onSurfaceVariant),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: StitchColors.outline, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: StitchColors.primary, width: 2),
      ),
    ),
  );
}
