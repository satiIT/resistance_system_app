// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class AppTheme {
  static bool get isWeb => UniversalPlatform.isWeb;
  static bool get isMobile => UniversalPlatform.isAndroid || UniversalPlatform.isIOS;
  static bool get isDesktop => UniversalPlatform.isWindows || UniversalPlatform.isMacOS || UniversalPlatform.isLinux;

  static ThemeData get lightTheme {
    final ThemeData base = ThemeData.light();
    
    return base.copyWith(
      // الألوان الأساسية
      colorScheme: ColorScheme.light(
        primary: Color(0xFF764ba2),
        primaryContainer: Color(0xFF5a397c),
        secondary: Color(0xFF667eea),
        secondaryContainer: Color(0xFF556cd8),
        surface: Colors.white,
        background: Color(0xFFf8f9fa),
        error: Colors.red,
      ),
      
      // استخدام TextTheme الحديث
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      cardTheme: _buildCardTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    // أحجام خطوط متجاوبة حسب المنصة
    double scaleFactor = isWeb ? 1.2 : 1.0;
    
    return base.copyWith(
      // Flutter 3.x استخدام الأسماء الجديدة
      displayLarge: TextStyle(
        fontSize: (24 * scaleFactor).clamp(24, 32).toDouble(),
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      displayMedium: TextStyle(
        fontSize: (20 * scaleFactor).clamp(20, 28).toDouble(),
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      displaySmall: TextStyle(
        fontSize: (18 * scaleFactor).clamp(18, 24).toDouble(),
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      bodyLarge: TextStyle(
        fontSize: (16 * scaleFactor).clamp(16, 18).toDouble(),
        fontWeight: FontWeight.normal,
        color: Colors.black87,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      bodyMedium: TextStyle(
        fontSize: (14 * scaleFactor).clamp(14, 16).toDouble(),
        fontWeight: FontWeight.normal,
        color: Colors.black54,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      bodySmall: TextStyle(
        fontSize: (12 * scaleFactor).clamp(12, 14).toDouble(),
        fontWeight: FontWeight.normal,
        color: Colors.black45,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      titleLarge: TextStyle(
        fontSize: (18 * scaleFactor).clamp(18, 22).toDouble(),
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      titleMedium: TextStyle(
        fontSize: (16 * scaleFactor).clamp(16, 20).toDouble(),
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
      titleSmall: TextStyle(
        fontSize: (14 * scaleFactor).clamp(14, 16).toDouble(),
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: Color(0xFF764ba2),
      foregroundColor: Colors.white,
      elevation: isWeb ? 2 : 4,
      centerTitle: true,
      toolbarHeight: isWeb ? 70 : 56,
      titleTextStyle: TextStyle(
        fontSize: isWeb ? 20 : 18,
        fontWeight: FontWeight.bold,
        fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF764ba2),
        padding: isWeb 
            ? EdgeInsets.symmetric(horizontal: 24, vertical: 16)
            : EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(
          fontSize: isWeb ? 16 : 14,
          fontWeight: FontWeight.w600,
          fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
        ),
      ),
    );
  }

  // ✅ التصحيح: استخدام CardThemeData بدلاً من CardTheme
  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: isWeb ? 2 : 4,
      margin: isWeb ? EdgeInsets.all(16) : EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF764ba2), width: 2),
      ),
      contentPadding: isWeb 
          ? EdgeInsets.symmetric(vertical: 16, horizontal: 12)
          : EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }
}

// دالة مساعدة للوصول السهل للنصوص
class AppTextStyles {
  static TextStyle get displayLarge => TextStyle(
    fontSize: AppTheme.isWeb ? 32 : 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: AppTheme.isWeb ? 28 : 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get displaySmall => TextStyle(
    fontSize: AppTheme.isWeb ? 24 : 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: AppTheme.isWeb ? 18 : 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: AppTheme.isWeb ? 16 : 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  static TextStyle get titleLarge => TextStyle(
    fontSize: AppTheme.isWeb ? 22 : 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: AppTheme.isWeb ? 20 : 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}