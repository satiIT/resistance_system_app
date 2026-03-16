import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'reports/archive_screen.dart';
import 'reports/personnel_classifications.dart';
import '../org/reports_screen.dart';
import '../../../core/services/auth_service.dart';

class IntelligenceDashboard extends StatelessWidget {
  const IntelligenceDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(
        title: Text(
          'استخبارات سابقات',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('التقارير الإستخباراتية'),
            const SizedBox(height: 16),
            _buildGrid(context, [
              _ReportItem(
                title: 'تقارير محددة',
                icon: Icons.person_search_rounded,
                color: Colors.blue,
                onTap: () async {
                  final auth = AuthService();
                  final user = await auth.getCurrentUser();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrgReportsScreen(
                          userId: user?['id'] ?? 0,
                          role: user?['role'] ?? 'admin',
                          personnelId: user?['personnel_id'],
                          reportScope: 'personnel',
                        ),
                      ),
                    );
                  }
                },
              ),
              _ReportItem(
                title: 'معلومة استباقية',
                icon: Icons.notification_important_rounded,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IntelligenceArchiveScreen(
                        title: 'معلومة استباقية',
                        type: 'proactive',
                        icon: Icons.notification_important_rounded,
                      ),
                    ),
                  );
                },
              ),
              _ReportItem(
                title: 'تقسيمات الأفراد',
                icon: Icons.groups_rounded,
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonnelClassificationsScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('الأرشيف الميداني'),
            const SizedBox(height: 12),
            _buildGrid(context, [
              _ReportItem(
                title: 'أرشيف السلاح',
                icon: Icons.security_rounded,
                color: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IntelligenceArchiveScreen(
                        title: 'أرشيف السلاح',
                        type: 'weapons',
                        icon: Icons.security_rounded,
                      ),
                    ),
                  );
                },
              ),
              _ReportItem(
                title: 'أرشيف الإفادات',
                icon: Icons.assignment_rounded,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IntelligenceArchiveScreen(
                        title: 'أرشيف الإفادات',
                        type: 'statements',
                        icon: Icons.assignment_rounded,
                      ),
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<_ReportItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCard(items[index]),
    );
  }

  Widget _buildCard(_ReportItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 24),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ReportItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
