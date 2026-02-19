// lib/presentation/pages/training/personnel_training_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import 'package:resistance_system_app/presentation/pages/training/instructors_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/training_courses_screen.dart';
import './../../../core/models/training_record.dart';
import './../../../core/services/training_api.dart';
import 'training_form_screen.dart';
import 'training_detail_screen.dart';

class PersonnelTrainingScreen extends StatefulWidget {
  @override
  _PersonnelTrainingScreenState createState() =>
      _PersonnelTrainingScreenState();
}

class _PersonnelTrainingScreenState extends State<PersonnelTrainingScreen> {
  List<TrainingRecord> trainingRecords = [];
  bool isLoading = true;
  String searchQuery = '';
  int _selectedFilter = 0;
  bool _isGridView = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });
    _loadTrainingData();
  }

  Future<void> _loadTrainingData() async {
    try {
      setState(() {
        isLoading = true;
        _errorMessage = null;
      });
      final response = await TrainingApi.getTrainingRecords();
      setState(() {
        trainingRecords = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = _getUserFriendlyError(e);
      });
      _showErrorSnackBar(_getUserFriendlyError(e));
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('Failed host lookup')) {
      return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.';
    } else if (errorString.contains('Connection refused')) {
      return 'الخادم غير متاح حالياً. يرجى المحاولة لاحقاً.';
    } else {
      return 'حدث خطأ غير متوقع: $errorString';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  List<TrainingRecord> get filteredRecords {
    var filtered = trainingRecords;
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
        final q = searchQuery.toLowerCase();
        return (record.personnelName?.toLowerCase().contains(q) ?? false) ||
            (record.militaryNumber?.toLowerCase().contains(q) ?? false) ||
            (record.courseName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (_selectedFilter == 1) {
      filtered = filtered
          .where((record) => record.attendanceStatus == 'حاضر')
          .toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered
          .where((record) => record.attendanceStatus == 'غائب')
          .toList();
    }
    return filtered;
  }

  String _getDisplayText(String? value, String defaultValue) {
    if (value == null || value.isEmpty || value.toLowerCase() == 'null')
      return defaultValue;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: 'التدريب والتسليح',
      actions: [
        IconButton(
          icon: Icon(
            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        _buildActionMenu(),
      ],
      children: [
        const ModernScreenHeader(
          title: 'سجلات التدريب',
          subtitle:
              'إدارة ومتابعة الدورات التدريبية المتقدمة والمتخصصة للمستنفرين.',
        ),
        const SizedBox(height: 24),

        ModernSearchField(
          hint: 'ابحث بالاسم، الرقم العسكري، أو الدورة...',
          controller: _searchController,
          onChanged: (v) => setState(() => searchQuery = v),
        ),
        const SizedBox(height: 16),

        _buildQuickActions(),
        const SizedBox(height: 16),

        if (!isLoading && _errorMessage == null) _buildFilterChips(),

        const SizedBox(height: 8),
        _buildContent(),
      ],
      floatingActionButton: _errorMessage == null
          ? Container(
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
                onPressed: _addNewTrainingRecord,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'سجل تدريب جديد',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            )
          : null,
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildQuickActionButton(
          label: 'إدارة الدورات',
          icon: Icons.school_rounded,
          color: AppColors.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => TrainingCoursesScreen()),
          ).then((_) => _refreshData()),
        ),
        const SizedBox(width: 12),
        _buildQuickActionButton(
          label: 'المدربين',
          icon: Icons.person_pin_rounded,
          color: AppColors.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => InstructorsScreen()),
          ).then((_) => _refreshData()),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.slate700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('تحديث البيانات', style: GoogleFonts.tajawal()),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'refresh') _refreshData();
      },
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('الكل', 0),
          const SizedBox(width: 10),
          _buildFilterChip('حاضر', 1),
          const SizedBox(width: 10),
          _buildFilterChip('غائب', 2),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.slate200.withOpacity(0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            color: isSelected ? Colors.white : AppColors.slate600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading)
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: CircularProgressIndicator()),
      );
    if (_errorMessage != null) return _buildErrorWidget();
    if (filteredRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.slate300,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد نتائج مطابقة',
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

    if (_isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemCount: filteredRecords.length,
        itemBuilder: (context, index) => _buildGridItem(filteredRecords[index]),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) =>
          _buildTrainingCard(filteredRecords[index]),
    );
  }

  Widget _buildTrainingCard(TrainingRecord record) {
    final name = _getDisplayText(record.personnelName, 'غير معروف');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ModernGlassCard(
        onTap: () => _viewTrainingDetails(record),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(record.personnelName),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: AppColors.slate500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDisplayText(record.militaryNumber, '---'),
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(record.attendanceStatus),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.slate100),
            ),
            Row(
              children: [
                _buildInfoIconText(
                  Icons.school_rounded,
                  record.courseName ?? 'دورة غير محددة',
                  AppColors.secondary,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.blue,
                    size: 22,
                  ),
                  onPressed: () => _editTrainingRecord(record),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                  onPressed: () => _showDeleteDialog(record),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
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
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildInfoIconText(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.slate700,
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(TrainingRecord record) {
    return ModernGlassCard(
      onTap: () => _viewTrainingDetails(record),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(record.personnelName),
          const SizedBox(height: 12),
          Text(
            _getDisplayText(record.personnelName, 'غير معروف'),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            record.courseName ?? '---',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.slate500),
          ),
          const SizedBox(height: 10),
          _buildStatusBadge(record.attendanceStatus),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final isPresent = status == 'حاضر';
    final color = isPresent ? Colors.green : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status ?? 'غير محدد',
        style: GoogleFonts.tajawal(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ModernGradientButton(
              text: 'إعادة المحاولة',
              onPressed: _refreshData,
              icon: Icons.refresh_rounded,
              width: 220,
            ),
          ],
        ),
      ),
    );
  }

  void _addNewTrainingRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => TrainingFormScreen()),
    ).then((v) {
      if (v == true) _refreshData();
    });
  }

  void _editTrainingRecord(TrainingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => TrainingFormScreen(existingRecord: record),
      ),
    ).then((v) {
      if (v == true) _refreshData();
    });
  }

  void _viewTrainingDetails(TrainingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => TrainingDetailScreen(record: record)),
    );
  }

  Future<void> _showDeleteDialog(TrainingRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا السجل؟ لن تتمكن من استعادته لاحقاً.',
          style: GoogleFonts.tajawal(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: AppColors.slate500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
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
    if (confirm == true) {
      try {
        await TrainingApi.deleteTrainingRecord(record.id!);
        _refreshData();
      } catch (e) {
        _showErrorSnackBar('خطأ في الحذف: $e');
      }
    }
  }
}
