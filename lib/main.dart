// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/pages/splash_screen.dart';
import 'package:universal_platform/universal_platform.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // إعدادات خاصة بالويب
  if (UniversalPlatform.isWeb) {
    // تحسين الأداء على الويب
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: 'المقاومة الشعبية - نظام الإدارة',
        primaryColor: 0xFF764ba2,
      ),
    );
  }
  
  runApp(ResistanceSystemApp());
}

class ResistanceSystemApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المقاومة الشعبية',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      
      // إعدادات التصميم للويب
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // تحسين النص على الويب
              textScaleFactor: UniversalPlatform.isWeb 
                  ? MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2)
                  : MediaQuery.of(context).textScaleFactor,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}