// lib/app/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  
  static const Color primaryOrange = Color(0xFFFF8C42); 
  static const Color darkGray = Color(0xFF2D2D2D);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  
  static final ThemeData mainTheme = ThemeData(
   
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryOrange, 
      primary: primaryOrange,
      brightness: Brightness.light, 
    ),

    
    scaffoldBackgroundColor: lightGray,

   
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: white, 
      elevation: 0,
    ),

  
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange, 
        foregroundColor: white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
    ),

    // Define o tema dos textos
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkGray, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: darkGray, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: darkGray),
      bodyMedium: TextStyle(color: darkGray),
    ),
  );
}