// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444);

  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Slate scale for neutrals
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}

class AppTheme {
  static bool get isWeb => UniversalPlatform.isWeb;
  static bool get isMobile =>
      UniversalPlatform.isAndroid || UniversalPlatform.isIOS;
  static bool get isDesktop =>
      UniversalPlatform.isWindows ||
      UniversalPlatform.isMacOS ||
      UniversalPlatform.isLinux;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _buildAppBarTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      cardTheme: _buildCardTheme(Brightness.light),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.darkPrimary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      cardTheme: _buildCardTheme(Brightness.dark),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      iconTheme: const IconThemeData(color: AppColors.darkPrimary, size: 24),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? Colors.black
        : Colors.white;

    return GoogleFonts.tajawalTextTheme().copyWith(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      displayMedium: GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        color: textColor.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return AppBarTheme(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      foregroundColor: isLight ? AppColors.slate900 : Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isLight ? AppColors.slate900 : Colors.white,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static CardThemeData _buildCardTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLight ? AppColors.slate200 : AppColors.slate700,
          width: 1,
        ),
      ),
      color: isLight ? Colors.white : AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    Brightness brightness,
  ) {
    final isLight = brightness == Brightness.light;
    return InputDecorationTheme(
      filled: true,
      fillColor: isLight ? Colors.white : AppColors.slate800.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), // More rounded
        borderSide: BorderSide(
          color: isLight ? AppColors.slate200 : Colors.white12,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isLight ? AppColors.slate200 : Colors.white12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      labelStyle: TextStyle(
        color: isLight ? AppColors.slate600 : AppColors.slate300,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: isLight ? AppColors.slate400 : AppColors.slate500,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
