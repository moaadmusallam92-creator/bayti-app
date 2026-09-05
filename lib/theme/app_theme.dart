import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const navy = Color(0xFF0A1E3D);
  static const navyDeep = Color(0xFF000000);
  static const blue = Color(0xFF1C63C4);
  static const blueLight = Color(0xFFE5F0FD);
  static const bluePale = Color(0xFFC7DCF5);
  static const orange = Color(0xFFF2793A);
  static const orangeDark = Color(0xFFD45F22);
  static const ink = Color(0xFF0F1E2E);
  static const paper = Color(0xFFF6F9FD);
  static const muted = Color(0xFF63758A);
  static const danger = Color(0xFFC6392F);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final displayFont = GoogleFonts.tajawalTextTheme(base.textTheme);
    final bodyFont = GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.orange,
        secondary: AppColors.blue,
        surface: Colors.white,
        error: AppColors.danger,
      ),
      textTheme: bodyFont.copyWith(
        displayLarge: displayFont.displayLarge,
        displayMedium: displayFont.displayMedium,
        titleLarge: displayFont.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        titleMedium: displayFont.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.bluePale),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.bluePale),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.bluePale.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}
