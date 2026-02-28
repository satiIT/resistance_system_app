import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/org_service.dart';
import '../../../core/models/organization.dart';
import '../../../core/services/personnel_service.dart';
import '../../../core/services/auth_service.dart';

class OrgReportsScreen extends StatefulWidget {
  final int userId;
  final String role;
  final int? personnelId;

  const OrgReportsScreen({
    Key? key,
    required this.userId,
    required this.role,
    this.personnelId,
  }) : super(key: key);

  @override
  State<OrgReportsScreen> createState() => _OrgReportsScreenState();
}

class _OrgReportsScreenState extends State<OrgReportsScreen> {
  List<OrgReport> _reports = [];
  bool _isLoading = true;

  // Cached data for dropdowns
  List<Department> _departments = [];
  List<OrgGroup> _groups = [];
  List<dynamic> _personnel = [];
  List<dynamic> _users = [];
  bool _targetsLoaded = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await OrgService.getReports(
        widget.userId,
        widget.role,
        widget.personnelId,
      );
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل التقارير: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTargets() async {
    if (_targetsLoaded) return;
    try {
      final depts = await OrgService.getDepartments();
      final groups = await OrgService.getAllGroups();
      final personnel = await PersonnelService.getAllPersonnel();
      final users = await _authService.getUsers();
      setState(() {
        _departments = depts;
        _groups = groups;
        _personnel = personnel;
        _users = users;
        _targetsLoaded = true;
      });
    } catch (e) {
      print('Error loading targets: $e');
    }
  }

  Future<void> _showAddReportDialog() async {
    // Show loading indicator while fetching targets
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _loadTargets();
    if (!mounted) return;
    Navigator.pop(context); // Close loading indicator

    final _noteController = TextEditingController();
    String _selectedType = 'personnel';
    int? _selectedTargetId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Dropdown items depend on selected report type
            List<DropdownMenuItem<int>> targetItems = [];
            if (_selectedType == 'personnel') {
              targetItems = _personnel.map<DropdownMenuItem<int>>((p) {
                final firstName = p['first_name']?.toString() ?? '';
                final secondName = p['second_name']?.toString() ?? '';
                final thirdName = p['third_name']?.toString() ?? '';
                final fourthName = p['fourth_name']?.toString() ?? '';
                final fullName = [
                  firstName,
                  secondName,
                  thirdName,
                  fourthName,
                ].where((n) => n.isNotEmpty).join(' ');

                return DropdownMenuItem<int>(
                  value: p['id'] as int,
                  child: Text(fullName.isEmpty ? 'بدون اسم' : fullName),
                );
              }).toList();
            } else if (_selectedType == 'group') {
              targetItems = _groups
                  .map(
                    (g) =>
                        DropdownMenuItem<int>(value: g.id, child: Text(g.name)),
                  )
                  .toList();
            } else if (_selectedType == 'department') {
              targetItems = _departments
                  .map(
                    (d) =>
                        DropdownMenuItem<int>(value: d.id, child: Text(d.name)),
                  )
                  .toList();
            } else if (_selectedType == 'user') {
              targetItems = _users
                  .map<DropdownMenuItem<int>>(
                    (u) => DropdownMenuItem<int>(
                      value: u['id'] as int,
                      child: Text(u['email']?.toString() ?? 'بدون بريد'),
                    ),
                  )
                  .toList();
            }

            return AlertDialog(
              title: const Text('إضافة تقرير جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع التقرير',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'personnel',
                          child: Text('فرد'),
                        ),
                        DropdownMenuItem(value: 'group', child: Text('مجموعة')),
                        DropdownMenuItem(
                          value: 'department',
                          child: Text('قسم'),
                        ),
                        DropdownMenuItem(value: 'user', child: Text('مستخدم')),
                      ],
                      onChanged: (val) => setDialogState(() {
                        _selectedType = val!;
                        _selectedTargetId =
                            null; // Reset selection on type change
                      }),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedTargetId,
                      decoration: const InputDecoration(
                        labelText: 'اختر الهدف',
                        border: OutlineInputBorder(),
                      ),
                      items: targetItems,
                      onChanged: (val) =>
                          setDialogState(() => _selectedTargetId = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات / نص التقرير',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_noteController.text.isEmpty ||
                        _selectedTargetId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('برجاء إدخال كافة البيانات'),
                        ),
                      );
                      return;
                    }
                    try {
                      await OrgService.createReport(
                        _selectedType,
                        _selectedTargetId!,
                        _noteController.text,
                        widget.userId,
                      );
                      if (mounted) Navigator.pop(context);
                      _loadReports();
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تقارير النظام',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReportDialog,
        label: const Text('إضافة تقرير'),
        icon: const Icon(Icons.note_add_rounded),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? const Center(child: Text('لا توجد تقارير حالياً'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                final String labelType = report.reportType == 'personnel'
                    ? 'تقرير فرد'
                    : report.reportType == 'group'
                    ? 'تقرير مجموعة'
                    : report.reportType == 'department'
                    ? 'تقرير قسم'
                    : 'تقرير مستخدم';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(
                                labelType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: AppColors.secondary.withOpacity(
                                0.2,
                              ),
                            ),
                            Text(
                              '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'بخصوص: ${report.targetName}',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.note ?? '',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const Divider(height: 32),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'بواسطة: ${report.creatorEmail ?? "غير معروف"}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
