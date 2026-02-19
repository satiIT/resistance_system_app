import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/models/training_course.dart';
import '../../../core/services/training_api.dart';
import 'training_course_form_screen.dart';

class TrainingCoursesScreen extends StatefulWidget {
  @override
  _TrainingCoursesScreenState createState() => _TrainingCoursesScreenState();
}

class _TrainingCoursesScreenState extends State<TrainingCoursesScreen> {
  List<TrainingCourse> _courses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() => _isLoading = true);
      final courses = await TrainingApi.getTrainingCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      _showError('خطأ في تحميل الدورات: $e');
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

  List<TrainingCourse> get _filteredCourses {
    if (_searchQuery.isEmpty) return _courses;
    final q = _searchQuery.toLowerCase();
    return _courses.where((course) {
      return course.courseName.toLowerCase().contains(q) ||
          (course.courseType?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: 'برامج الدورات',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _loadCourses,
        ),
      ],
      children: [
        const ModernScreenHeader(
          title: 'إدارة الدورات',
          subtitle:
              'تخطيط ومتابعة البرامج التدريبية المعتمدة وتعيين المدربين المسئولين.',
        ),
        const SizedBox(height: 24),

        ModernSearchField(
          hint: 'ابحث عن دورة أو نوع تدريب...',
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 16),

        _buildContent(),
      ],
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _addNewCourse,
          icon: const Icon(Icons.add_task_rounded, color: Colors.white),
          label: Text(
            'دورة جديدة',
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
    final filtered = _filteredCourses;
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history_edu_rounded,
                size: 64,
                color: AppColors.slate300,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد دورات مسجلة',
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
      itemBuilder: (context, index) => _buildCourseCard(filtered[index]),
    );
  }

  Widget _buildCourseCard(TrainingCourse course) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ModernGlassCard(
        onTap: () => _editCourse(course),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.courseName,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        course.courseType ?? '---',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(course.courseStatus),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.slate100),
            ),
            Row(
              children: [
                _buildInfoIcon(
                  Icons.location_on_rounded,
                  course.location ?? '---',
                ),
                const SizedBox(width: 16),
                _buildInfoIcon(
                  Icons.people_alt_rounded,
                  '${course.maxParticipants ?? 0} مقعد',
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: AppColors.slate300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final isCompleted = status == 'مكتمل';
    final color = isCompleted ? Colors.green : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status ?? 'مخطط',
        style: GoogleFonts.tajawal(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white60),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  void _addNewCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => TrainingCourseFormScreen()),
    ).then((v) {
      if (v == true) _loadCourses();
    });
  }

  void _editCourse(TrainingCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => TrainingCourseFormScreen(existingCourse: course),
      ),
    ).then((v) {
      if (v == true) _loadCourses();
    });
  }
}
