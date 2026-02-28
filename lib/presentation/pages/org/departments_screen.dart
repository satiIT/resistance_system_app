import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/modern_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/org_service.dart';
import '../../../core/models/organization.dart';
import 'dept_detail_screen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  List<Department> _departments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final depts = await OrgService.getDepartments();
      setState(() {
        _departments = depts;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الأقسام: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'أقسام الوحدة الفنية',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDepartments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _departments.length,
                itemBuilder: (context, index) {
                  final dept = _departments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ModernSectionCard(
                      title: dept.name,
                      icon: Icons.account_tree_rounded,
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('حكمدار القسم'),
                            subtitle: Text(dept.governorName ?? 'غير معين'),
                            trailing: const Icon(
                              Icons.person_pin_circle_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: ModernGradientButton(
                              text: 'عرض المجموعات والتفاصيل',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DeptDetailScreen(department: dept),
                                  ),
                                ).then((_) => _loadDepartments());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
