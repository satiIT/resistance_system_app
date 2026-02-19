import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/services/training_api.dart';
import 'instructor_form_screen.dart';

class InstructorsScreen extends StatefulWidget {
  @override
  _InstructorsScreenState createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  List<dynamic> _instructors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructors() async {
    try {
      setState(() => _isLoading = true);
      final response = await TrainingApi.getInstructors();
      setState(() {
        _instructors = response;
        _isLoading = false;
      });
    } catch (e) {
      _showError('خطأ في تحميل المدربين: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<dynamic> get _filteredInstructors {
    if (_searchQuery.isEmpty) return _instructors;
    final q = _searchQuery.toLowerCase();
    return _instructors.where((instructor) {
      final name = (instructor['name'] ?? instructor['full_name'] ?? '')
          .toString()
          .toLowerCase();
      final specialization =
          (instructor['specialization'] ?? instructor['specialty'] ?? '')
              .toString()
              .toLowerCase();
      final rank = (instructor['rank'] ?? instructor['military_rank'] ?? '')
          .toString()
          .toLowerCase();

      return name.contains(q) || specialization.contains(q) || rank.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: 'إدارة المدربين',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _loadInstructors,
        ),
      ],
      children: [
        const ModernScreenHeader(
          title: 'سجل المدربين',
          subtitle:
              'إدارة وتوجيه الكفاءات والخبرات التدريبية المتاحة لتنفيذ الدورات.',
        ),
        const SizedBox(height: 24),

        ModernSearchField(
          hint: 'ابحث بالاسم، التخصص، أو الرتبة...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 24),

        _buildContent(),
      ],
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _addNewInstructor,
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: Text(
            'مدرب جديد',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading)
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: CircularProgressIndicator()),
      );
    final filtered = _filteredInstructors;
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.person_off_rounded,
                size: 64,
                color: AppColors.slate300,
              ),
              const SizedBox(height: 16),
              Text(
                'لا يوجد مدربين مطابقين',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildInstructorCard(filtered[index]),
    );
  }

  Widget _buildInstructorCard(Map<String, dynamic> instructor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ModernGlassCard(
        onTap: () => _showInstructorDetails(instructor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(instructor['name'] ?? instructor['full_name']),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        instructor['name'] ??
                            instructor['full_name'] ??
                            'غير معروف',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.military_tech_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            instructor['rank'] ?? '--',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionMenu(instructor),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.slate100),
            ),
            Row(
              children: [
                _buildInfoBadge(
                  Icons.work_rounded,
                  instructor['specialization'] ??
                      instructor['specialty'] ??
                      'عام',
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildInfoBadge(
                  Icons.location_on_rounded,
                  instructor['residence'] ?? '--',
                  AppColors.slate500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? name) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.person_pin_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(Map<String, dynamic> instructor) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.slate400, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_rounded, color: Colors.blue, size: 18),
              const SizedBox(width: 12),
              Text('تعديل البيانات', style: GoogleFonts.tajawal()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text('حذف المدرب', style: GoogleFonts.tajawal()),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'edit') _editInstructor(instructor);
        if (val == 'delete') _deleteInstructor(instructor);
      },
    );
  }

  void _showInstructorDetails(Map<String, dynamic> instructor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        borderRadius: 32,
        blur: 25,
        opacity: 0.2, // Stronger glass effect for bottom sheet
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate400.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildAvatar(instructor['name'] ?? instructor['full_name']),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        instructor['name'] ??
                            instructor['full_name'] ??
                            'غير معروف',
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        instructor['rank'] ?? 'غير معرف',
                        style: GoogleFonts.tajawal(color: AppColors.slate500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildDetailCard(
                      Icons.work_rounded,
                      'التخصص المهني',
                      instructor['specialization'] ?? instructor['specialty'],
                    ),
                    _buildDetailCard(
                      Icons.corporate_fare_rounded,
                      'الوحدة العسكرية',
                      instructor['unit'],
                    ),
                    _buildDetailCard(
                      Icons.location_on_rounded,
                      'مكان الإقامة',
                      instructor['residence'] ??
                          instructor['current_residence'],
                    ),
                    _buildDetailCard(
                      Icons.phone_rounded,
                      'رقم التواصل',
                      instructor['phone_number'],
                    ),
                    _buildDetailCard(
                      Icons.history_rounded,
                      'سنوات الخبرة',
                      '${instructor['experience_years'] ?? 0} سنة',
                    ),
                    _buildDetailCard(
                      Icons.school_rounded,
                      'المؤهلات العلمية',
                      instructor['qualifications'],
                    ),
                    if (instructor['notes']?.toString().isNotEmpty ?? false)
                      _buildDetailCard(
                        Icons.note_rounded,
                        'ملاحظات إضافية',
                        instructor['notes'],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ModernGradientButton(
                text: 'إغلاق',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
                Text(
                  value ?? 'غير معرف',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editInstructor(Map<String, dynamic> instructor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            InstructorFormScreen(existingInstructor: instructor),
      ),
    ).then((_) => _loadInstructors());
  }

  void _deleteInstructor(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من حذف المدرب ${instructor['name']}؟ لن تتمكن من استعادته لاحقاً.',
          style: GoogleFonts.tajawal(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: AppColors.slate500),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(instructor['id']);
            },
            child: Text(
              'حذف',
              style: GoogleFonts.tajawal(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(dynamic id) async {
    try {
      await TrainingApi.deleteInstructor(int.parse(id.toString()));
      _loadInstructors();
      _showSuccess('تم حذف المدرب بنجاح');
    } catch (e) {
      _showError('خطأ في الحذف: $e');
    }
  }

  void _addNewInstructor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InstructorFormScreen()),
    ).then((_) => _loadInstructors());
  }
}
