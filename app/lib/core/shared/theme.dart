import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // Convert HSL definitions to Color once for reuse
    final primary = HSLColor.fromAHSL(1.0, 15, 0.6, 0.65).toColor(); // Warm Terracotta/Peach
    final secondary = HSLColor.fromAHSL(1.0, 45, 0.5, 0.9).toColor();
    final card = HSLColor.fromAHSL(1.0, 35, 0.3, 0.98).toColor();
    final background = HSLColor.fromAHSL(1.0, 35, 0.4, 0.96).toColor();
    final onPrimary = Colors.white;
    final onSecondary = HSLColor.fromAHSL(1.0, 25, 0.4, 0.3).toColor();
    final onSurface = HSLColor.fromAHSL(1.0, 25, 0.2, 0.25).toColor();
    final onBackground = HSLColor.fromAHSL(1.0, 25, 0.2, 0.25).toColor();
    final error = HSLColor.fromAHSL(1.0, 0, 0.84, 0.6).toColor();
    final borderColor = HSLColor.fromAHSL(1.0, 35, 0.2, 0.88).toColor();

    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: card,
        background: background,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onSurface: onSurface,
        onBackground: onBackground,
        error: error,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // radius-md
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        displayMedium: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        displaySmall: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        headlineLarge: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        headlineMedium: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        headlineSmall: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        titleLarge: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: 'Inter'),
        bodyMedium: TextStyle(fontFamily: 'Inter'),
        bodySmall: TextStyle(fontFamily: 'Inter'),
        labelLarge: TextStyle(fontFamily: 'Inter'),
        labelMedium: TextStyle(fontFamily: 'Inter'),
        labelSmall: TextStyle(fontFamily: 'Inter'),
      ),
    );
  }
}