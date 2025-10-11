// lib/presentation/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/pages/login_screen.dart';
import 'package:universal_platform/universal_platform.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // وقت تحميل مختلف حسب المنصة
    final duration = UniversalPlatform.isWeb 
        ? Duration(seconds: 1)  // أسرع على الويب
        : Duration(seconds: 2); // عادي على الموبايل
    
    await Future.delayed(duration);
    
    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة متجاوبة
            Icon(
              Icons.security, 
              size: isWeb ? 100 : 80, 
              color: Colors.white
            ),
            SizedBox(height: isWeb ? 30 : 20),
            
            // النص الرئيسي
            Text(
              'المقاومة الشعبية',
              style: TextStyle(
                fontSize: isWeb ? 36 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
              ),
            ),
            
            // النص الثانوي
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 100 : 40,
                vertical: 10,
              ),
              child: Text(
                'لجنة الإسناد خريجي جامعة الخرطوم الثمانينات',
                style: TextStyle(
                  fontSize: isWeb ? 18 : 16,
                  color: Colors.white70,
                  fontFamily: isWeb ? 'Tajawal, Arial, sans-serif' : 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // مؤشر التحميل (يظهر فقط على الموبايل)
            if (!isWeb) ...[
              SizedBox(height: 30),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
