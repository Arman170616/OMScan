import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand
  static const Color primary   = Color(0xFF60A5FA); // blue-400
  static const Color secondary = Color(0xFF34D399); // emerald-400
  static const Color accent    = Color(0xFFF87171); // red-400
  static const Color warning   = Color(0xFFFBBF24); // amber-400

  // Dark glass backgrounds
  static const Color bgDark1   = Color(0xFF0A1628);
  static const Color bgDark2   = Color(0xFF0F2340);
  static const Color bgPage    = bgDark1;
  static const Color bgCard    = Color(0x14FFFFFF); // white 8%
  static const Color bgInput   = Color(0x0DFFFFFF); // white 5%

  // Text
  static const Color textPrimary   = Color(0xFFF1F5F9); // slate-100
  static const Color textSecondary = Color(0xFF94A3B8);  // slate-400
  static const Color textMuted     = Color(0xFF475569);  // slate-600

  // Border
  static const Color border  = Color(0x26FFFFFF); // white 15%
  static const Color divider = Color(0x14FFFFFF); // white 8%

  // Page gradient
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF0D2040), Color(0xFF0A1628)],
    stops: [0.0, 0.5, 1.0],
  );

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        error: accent,
        surface: const Color(0xFF0F2340),
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bgPage,
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: textPrimary,   fontWeight: FontWeight.w800),
          headlineLarge: TextStyle(color: textPrimary,   fontWeight: FontWeight.w700),
          headlineMedium:TextStyle(color: textPrimary,   fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(color: textPrimary,   fontWeight: FontWeight.w600),
          titleLarge:    TextStyle(color: textPrimary,   fontWeight: FontWeight.w600),
          titleMedium:   TextStyle(color: textPrimary,   fontWeight: FontWeight.w600),
          titleSmall:    TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
          bodyLarge:     TextStyle(color: textPrimary),
          bodyMedium:    TextStyle(color: textSecondary),
          bodySmall:     TextStyle(color: textMuted),
          labelLarge:    TextStyle(color: textPrimary,   fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(const Color(0xFF0F2340)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF0F2340),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        textStyle: const TextStyle(color: textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0F2340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
            color: textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
        contentTextStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
          color: divider, space: 1, thickness: 0.5),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
    );
  }

  // Kept for backward compat (currently unused)
  static ThemeData get light => dark;
}

List<BoxShadow> get glowShadow => [
      BoxShadow(
        color: AppTheme.primary.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ];
