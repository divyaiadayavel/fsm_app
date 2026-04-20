import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    useMaterial3: true,
    fontFamily: 'Arial',

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4F46E5),
      secondary: Color(0xFF6366F1),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF3F4F6),
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    cardColor: Colors.white,
    dividerColor: Color(0xFFE5E7EB),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black),
      displayMedium: TextStyle(color: Colors.black),
      displaySmall: TextStyle(color: Colors.black),

      headlineLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(color: Colors.black),

      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.black),
      titleSmall: TextStyle(color: Colors.black),

      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),

      labelLarge: TextStyle(color: Colors.black),
      labelMedium: TextStyle(color: Colors.black87),
      labelSmall: TextStyle(color: Colors.black54),
    ),

    iconTheme: const IconThemeData(color: Colors.black87),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  static ThemeData lightTheme = darkTheme;
}
