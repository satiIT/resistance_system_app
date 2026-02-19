// lib/presentation/pages/intelligence/intelligence_login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../main_dashboard.dart';

class IntelligenceLoginScreen extends StatefulWidget {
  const IntelligenceLoginScreen({Key? key}) : super(key: key);

  @override
  State<IntelligenceLoginScreen> createState() =>
      _IntelligenceLoginScreenState();
}

class _IntelligenceLoginScreenState extends State<IntelligenceLoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF450a0a), Color(0xFF7f1d1d)], // Very dark red
          ),
        ),
        child: Stack(
          children: [
            // Security patterns or icons in background
            Opacity(
              opacity: 0.05,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemBuilder: (context, index) =>
                    const Icon(Icons.security, size: 50, color: Colors.white),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: GlassContainer(
                    blur: 20,
                    opacity: 0.1,
                    color: Colors.red.shade900,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 48,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.gpp_maybe_rounded,
                              size: 64,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'نظام الاستخبارات العسكرية',
                            style: GoogleFonts.tajawal(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'منطقة عالية السرية',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: Colors.red.shade200,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          _buildPasswordField(),
                          const SizedBox(height: 32),

                          ModernGradientButton(
                            text: 'تصريح بالدخول',
                            icon: Icons.vpn_key_rounded,
                            gradientColors: const [
                              Color(0xFFef4444),
                              Color(0xFFb91c1c),
                            ],
                            onPressed: () => _authenticate(context),
                          ),
                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'العودة للشاشة الرئيسية',
                              style: GoogleFonts.tajawal(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور الخاصة',
          style: GoogleFonts.tajawal(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white, letterSpacing: 4),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_person_rounded,
                color: Colors.red,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.5),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _authenticate(BuildContext context) {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يجب إدخال كلمة المرور', style: GoogleFonts.tajawal()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainDashboard()),
    );
  }
}
