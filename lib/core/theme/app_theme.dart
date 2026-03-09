import 'package:flutter/material.dart';

class AppColors {
  // Flowy Inspired Deep Palette
  static const Color primary = Color(0xFFFF4D6D); // Vibrant Flowy Pink/Rose
  static const Color secondary = Color(0xFF7209B7); // Deep Purple
  static const Color accent = Color(0xFF4CC9F0); // Bright Blue
  
  static const Color darkBg = Color(0xFF0B0114); // Deep Midnight
  static const Color cardDark = Color(0xFF1A1A2E); // Dark Slate Blue
  
  // Gradient Palettes for Flowy-style Cards
  static const List<Color> rockGradient = [Color(0xFFFF5F6D), Color(0xFFFFC371)];
  static const List<Color> popGradient = [Color(0xFF8E2DE2), Color(0xFF4A00E0)];
  static const List<Color> jazzGradient = [Color(0xFF2193B0), Color(0xFF6dd5ed)];
  static const List<Color> lofiGradient = [Color(0xFFee9ca7), Color(0xFFffdde1)];
}

class AppTheme {
  static const double cardRadius = 32.0;

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        background: AppColors.darkBg,
        surface: AppColors.cardDark,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
        color: AppColors.cardDark,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),
      ),
    );
  }

  static ThemeData lightTheme() {
    // Keeping light theme simple but consistent
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      ),
    );
  }
}
