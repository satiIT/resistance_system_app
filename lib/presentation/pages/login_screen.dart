// lib/presentation/pages/login_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../core/responsive/responsive_layout.dart';
import 'main_dashboard.dart';
import 'intelligence/intelligence_login_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: isWeb ? null : _buildAppBar(isMobile),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isWeb ? _buildWebBackground() : null,
        child: isWeb ? _buildWebLayout(context, isMobile) : _buildMobileLayout(context, isMobile),
      ),
    );
  }

  AppBar _buildAppBar(bool isMobile) {
    return AppBar(
      title: Text(
        'تسجيل الدخول',
        style: TextStyle(
          fontSize: isMobile ? 18 : 20,
        ),
      ),
      centerTitle: true,
    );
  }

  BoxDecoration _buildWebBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF764ba2),
          Color(0xFF667eea),
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
        // الشعار
        if (isWeb) ...[
          Icon(Icons.security, 
            size: isMobile ? 60 : 80, 
            color: isWeb ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: isMobile ? 15 : 20),
        ],
        
        // العنوان
        Text(
          'نظام إدارة موارد المقاومة الشعبية',
          style: TextStyle(
            fontSize: isMobile ? 18 : (isWeb ? 24 : 20),
            fontWeight: FontWeight.bold,
            color: isWeb ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 20 : 30),

        // حقل اسم المستخدم
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'اسم المستخدم',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: isWeb 
                ? EdgeInsets.symmetric(vertical: isMobile ? 14 : 16, horizontal: 12)
                : EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // حقل كلمة المرور
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: isWeb 
                ? EdgeInsets.symmetric(vertical: isMobile ? 14 : 16, horizontal: 12)
                : EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),

        // زر تسجيل الدخول
        SizedBox(
          width: isWeb ? double.infinity : null,
          child: ElevatedButton(
            onPressed: () => _login(context),
            child: Text(
              'تسجيل الدخول',
              style: TextStyle(fontSize: isMobile ? 14 : (isWeb ? 18 : 16)),
            ),
            style: ElevatedButton.styleFrom(
              padding: isWeb 
                  ? EdgeInsets.symmetric(vertical: isMobile ? 14 : 16)
                  : EdgeInsets.symmetric(vertical: isMobile ? 12 : 14, horizontal: 24),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),

        // زر الدخول للاستخبارات
        SizedBox(
          width: isWeb ? double.infinity : null,
          child: OutlinedButton(
            onPressed: () => _navigateToIntelligence(context),
            child: Text(
              'الدخول إلى نظام الاستخبارات',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isWeb ? Colors.white : Theme.of(context).colorScheme.primary,
              side: BorderSide(color: isWeb ? Colors.white : Theme.of(context).colorScheme.primary),
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
            'يدعم جميع المتصفحات الحديثة',
            style: TextStyle(
              color: Colors.white70, 
              fontSize: isMobile ? 12 : 14
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'لجنة الإسناد خريجي جامعة الخرطوم الثمانينات',
            style: TextStyle(
              color: Colors.white70, 
              fontSize: isMobile ? 10 : 12
            ),
            textAlign: TextAlign.center,
          ),
        ],

        // معلومات إضافية للجوال
        if (!isWeb) ...[
          SizedBox(height: isMobile ? 20 : 30),
          Divider(),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'المقاومة الشعبية',
            style: TextStyle(
              color: Colors.grey, 
              fontSize: isMobile ? 12 : 14
            ),
          ),
          Text(
            'لجنة الإسناد خريجي جامعة الخرطوم الثمانينات',
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

  void _login(BuildContext context) {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // تحقق بسيط من البيانات
    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'يرجى ملء جميع الحقول');
      return;
    }

    // مؤقتاً للانتقال للشاشة الرئيسية (سيتم استبدالها بالمصادقة الحقيقية)
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => MainDashboard())
    );
  }

  void _navigateToIntelligence(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => IntelligenceLoginScreen())
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'خطأ',
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