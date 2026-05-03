import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Crimson Palette (Pure Red on White)
  static const Color primary = Color(0xFFEF233C); // Vibrant Red
  static const Color secondary = Color(0xFFD90429); // Deep Red (Pure)
  static const Color accent = Color(0xFFFF5D6E); // Light Vibrant Red
  
  static const Color lightBg = Color(0xFFFFFAFA); // Barely reddish white
  static const Color cardLight = Colors.white; 
  
  // Crimson Light Theme Gradients (Saturated Reds)
  static const List<Color> sunriseGradient = [Color(0xFFEF233C), Color(0xFFFF4D6D)];
  static const List<Color> oceanGradient = [Color(0xFFD90429), Color(0xFFEF233C)];
  static const List<Color> royalGradient = [Color(0xFFFFE5E5), Color(0xFFFFCCCC)]; 
  static const List<Color> morningGradient = [Color(0xFFEF233C), Color(0xFFFF7171)];
  
  static const List<Color> rockGradient = sunriseGradient;
  static const List<Color> popGradient = [Color(0xFFEF233C), Color(0xFFD90429)];
  static const List<Color> jazzGradient = oceanGradient;
  static const List<Color> lofiGradient = morningGradient;

  static const Color darkBg = lightBg; 
  static const Color cardDark = cardLight;



  
  // Semantic Colors
  static const Color textDark = Color(0xFF1B1B1E); // Neutral dark grey/black
  static const Color textRed = Color(0xFFB11623); // Clear Blood Red (not maroon)

  // Surface and Shadows for Relief Effect
  static const Color surface = Colors.white;
  static const Color darkShadow = Color(0xFFD1D9E6);
  static const Color lightSource = Colors.white;
  
  static Gradient reliefGradient = LinearGradient(
    colors: [Color(0xFFF0F2F5), Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> reliefShadows({double offset = 8, double blur = 16}) {
    return [
      BoxShadow(
        color: darkShadow.withOpacity(0.7),
        offset: Offset(offset, offset),
        blurRadius: blur,
      ),
      BoxShadow(
        color: lightSource.withOpacity(0.9),
        offset: Offset(-offset, -offset),
        blurRadius: blur,
      ),
    ];
  }
}

class AppTheme {
  static const double cardRadius = 32.0;

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.cardLight,
        onSurface: AppColors.textDark,
        background: AppColors.lightBg,
        onBackground: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        elevation: 10,
        shadowColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
        color: AppColors.cardLight,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w900, 
          color: AppColors.textDark, 
          letterSpacing: -1.5,
          fontSize: 32,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w800, 
          color: AppColors.textDark, 
          letterSpacing: -1.0,
          fontSize: 22,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w800, 
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w500, 
          color: Color(0xFF4A4E69), // Slate grey for long text
          fontSize: 16,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Color(0xFF8D99AE),
          fontSize: 10,
        ),
      ),
    );
  }

  static ThemeData darkTheme() => lightTheme(); 
}
