import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/core/services/org_service.dart';

class PersonnelClassificationsScreen extends StatefulWidget {
  const PersonnelClassificationsScreen({Key? key}) : super(key: key);

  @override
  State<PersonnelClassificationsScreen> createState() =>
      _PersonnelClassificationsScreenState();
}

class _PersonnelClassificationsScreenState
    extends State<PersonnelClassificationsScreen> {
  bool _isLoading = true;
  List<dynamic> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await OrgService.getDepartments();
      setState(() {
        _departments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(
        title: Text('تقسيمات الأفراد', style: GoogleFonts.tajawal()),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _departments.length,
              itemBuilder: (context, index) {
                final dept = _departments[index];
                return _buildDeptCard(dept);
              },
            ),
    );
  }

  Widget _buildDeptCard(dynamic dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dept.name,
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'نشط',
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow('إجمالي القوة', 'في انتظار البيانات'),
          _buildStatRow('التواجد الميداني', '75%'),
          _buildStatRow('الجهوزية القتالية', 'مرتفعة'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
