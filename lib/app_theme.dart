import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00D4FF),
        secondary: Color(0xFF7B68EE),
        tertiary: Color(0xFFFF6B6B),
        surface: Color(0xFF1A1A1A),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 2,
        shadowColor: Colors.black26,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D4FF),
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: const Color(0xFF00D4FF).withAlpha(76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2A2A2A),
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF00D4FF),
        inactiveTrackColor: Colors.grey[700],
        thumbColor: const Color(0xFF00D4FF),
        overlayColor: const Color(0xFF00D4FF).withAlpha(51),
      ),
    );
  }
}
