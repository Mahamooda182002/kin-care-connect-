import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Instagram Dark Mode aesthetic (OLED Black, pure whites, subtle greys)
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color primary = Color(0xFFFFFFFF); // White text/icons on black
  static const Color secondary = Color(0xFF262626); // Divider / border color
  static const Color textLight = Color(0xFFFFFFFF); // High contrast pure white
  static const Color textMedium = Color(0xFFF5F5F5); // Slightly softer reading text
  static const Color textMuted = Color(0xFFA8A8A8);
  static const Color error = Color(0xFFED4956); // Instagram error red
  static const Color success = Color(0xFF58C322); // Vibrant green for SAFE states
  static const Color accentBlue = Color(0xFF0095F6); // Instagram blue for links/actions

  // Soft Shadows for components (though in dark mode, shadows are usually subtle or achieved via border/surface lightness)
  static final List<BoxShadow> softShadows = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      spreadRadius: 2,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(color: textLight, fontSize: 32, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.inter(color: textLight, fontSize: 24, fontWeight: FontWeight.w700),
      bodyLarge: GoogleFonts.inter(color: textMedium, fontSize: 18, fontWeight: FontWeight.w500), // Increased for senior readability
      bodyMedium: GoogleFonts.inter(color: textMedium, fontSize: 16),
    ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textMuted, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
