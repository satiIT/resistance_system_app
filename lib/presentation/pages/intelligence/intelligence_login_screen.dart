// lib/presentation/pages/intelligence/intelligence_login_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:resistance_system_app/core/responsive/responsive_layout.dart';
import '../main_dashboard.dart';

class IntelligenceLoginScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نظام الاستخبارات',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[800],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isWeb ? _buildWebBackground() : null,
        child: isWeb ? _buildWebLayout(context, isMobile) : _buildMobileLayout(context, isMobile),
      ),
    );
  }

  BoxDecoration _buildWebBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.red[800]!,
          Colors.red[600]!,
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, bool isMobile) {
    return Center(
      child: Container(
        width: isMobile ? 350 : 400,
        margin: EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            child: _buildLoginForm(context, isWeb: true, isMobile: isMobile),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: _buildLoginForm(context, isWeb: false, isMobile: isMobile),
    );
  }

  Widget _buildLoginForm(BuildContext context, {required bool isWeb, required bool isMobile}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // شعار الاستخبارات
        Icon(Icons.security, 
          size: isMobile ? 60 : 80, 
          color: isWeb ? Colors.white : Colors.red[800],
        ),
        SizedBox(height: isMobile ? 15 : 20),
        
        // العنوان
        Text(
          'الدخول إلى نظام الاستخبارات العسكرية',
          style: TextStyle(
            fontSize: isMobile ? 18 : (isWeb ? 24 : 20),
            fontWeight: FontWeight.bold,
            color: isWeb ? Colors.white : Colors.red[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 10 : 15),
        Text(
          'مطلوب كلمة مرور خاصة للوصول',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: isWeb ? Colors.white70 : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 20 : 30),

        // حقل كلمة مرور الاستخبارات
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'كلمة مرور الاستخبارات',
            prefixIcon: Icon(Icons.password),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: isWeb 
                ? EdgeInsets.symmetric(vertical: isMobile ? 14 : 16, horizontal: 12)
                : EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),

        // زر المصادقة
        SizedBox(
          width: isWeb ? double.infinity : null,
          child: ElevatedButton(
            onPressed: () => _authenticate(context),
            child: Text(
              'الدخول إلى النظام الاستخباراتي',
              style: TextStyle(fontSize: isMobile ? 14 : (isWeb ? 18 : 16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              padding: isWeb 
                  ? EdgeInsets.symmetric(vertical: isMobile ? 14 : 16)
                  : EdgeInsets.symmetric(vertical: isMobile ? 12 : 14, horizontal: 24),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // زر العودة
        SizedBox(
          width: isWeb ? double.infinity : null,
          child: OutlinedButton(
            onPressed: () => _goBack(context),
            child: Text(
              'العودة للشاشة الرئيسية',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isWeb ? Colors.white : Colors.red[800],
              side: BorderSide(color: isWeb ? Colors.white : Colors.red[800]!),
              padding: isWeb 
                  ? EdgeInsets.symmetric(vertical: isMobile ? 14 : 16)
                  : EdgeInsets.symmetric(vertical: isMobile ? 10 : 12, horizontal: 20),
            ),
          ),
        ),

        // معلومات إضافية للويب
        if (isWeb) ...[
          SizedBox(height: isMobile ? 20 : 30),
          Divider(color: Colors.white70),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'الوصول مقصور على ضباط الاستخبارات المصرح لهم',
            style: TextStyle(
              color: Colors.white70, 
              fontSize: isMobile ? 12 : 14
            ),
          ),
        ],

        // معلومات إضافية للجوال
        if (!isWeb) ...[
          SizedBox(height: isMobile ? 20 : 30),
          Divider(),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'نظام الاستخبارات العسكرية',
            style: TextStyle(
              color: Colors.grey, 
              fontSize: isMobile ? 12 : 14
            ),
          ),
          Text(
            'الوصول مقصور على ضباط الاستخبارات المصرح لهم',
            style: TextStyle(
              color: Colors.grey, 
              fontSize: isMobile ? 10 : 12
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  void _authenticate(BuildContext context) {
    String password = _passwordController.text.trim();
    
    if (password.isEmpty) {
      _showErrorDialog(context, 'يجب إدخال كلمة المرور');
      return;
    }
    
    // مؤقتاً - قبول أي كلمة مرور للاختبار
    // في التطبيق الحقيقي، سيتم الاتصال بـ API المصادقة
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => MainDashboard())
    );
  }

  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'خطأ في المصادقة',
          style: TextStyle(fontSize: 18),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }
}