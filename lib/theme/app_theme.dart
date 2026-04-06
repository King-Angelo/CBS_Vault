import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CBS Vault — dark-first, teal accent, corporate-educational tone.
abstract final class AppTheme {
  static const Color accentTeal = Color(0xFF2DD4BF);
  static const Color surface = Color(0xFF12141A);
  static const Color surfaceVariant = Color(0xFF1A1D26);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accentTeal,
        onPrimary: Color(0xFF0A0C10),
        secondary: Color(0xFF94A3B8),
        onSecondary: Color(0xFF0A0C10),
        surface: surface,
        onSurface: Color(0xFFE8EAEF),
        surfaceContainerHighest: surfaceVariant,
        error: Color(0xFFF87171),
        onError: Color(0xFF0A0C10),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFE8EAEF),
        displayColor: const Color(0xFFE8EAEF),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: surfaceVariant,
        foregroundColor: const Color(0xFFE8EAEF),
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE8EAEF),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentTeal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentTeal,
        foregroundColor: Color(0xFF0A0C10),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceVariant,
        contentTextStyle: GoogleFonts.inter(color: const Color(0xFFE8EAEF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
