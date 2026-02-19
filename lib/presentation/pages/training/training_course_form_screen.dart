import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/models/training_course.dart';
import '../../../core/services/training_api.dart';

class TrainingCourseFormScreen extends StatefulWidget {
  final TrainingCourse? existingCourse;

  TrainingCourseFormScreen({this.existingCourse});

  @override
  _TrainingCourseFormScreenState createState() =>
      _TrainingCourseFormScreenState();
}

class _TrainingCourseFormScreenState extends State<TrainingCourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TrainingCourse _course;
  bool _isLoading = false;
  bool _isEditMode = false;

  List<Map<String, dynamic>> _instructors = [];
  String? _selectedInstructorId;

  final List<String> _courseTypes = [
    'تدريب أساسي',
    'تدريب متقدم',
    'تدريب متخصص',
    'دورة سلاح',
    'دورة قيادة',
    'دورة طبية',
    'دورة اتصالات',
  ];
  final List<String> _courseStatuses = ['مخطط', 'قيد التنفيذ', 'مكتمل', 'ملغى'];

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _targetGroupController;
  late TextEditingController _durationController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _notesController;
  late TextEditingController _startDateController;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingCourse != null;
    _course =
        widget.existingCourse ??
        TrainingCourse(
          courseName: '',
          courseType: 'تدريب متخصص',
          courseStatus: 'مخطط',
        );

    _nameController = TextEditingController(text: _course.courseName);
    _locationController = TextEditingController(text: _course.location);
    _targetGroupController = TextEditingController(text: _course.targetGroup);
    _durationController = TextEditingController(
      text: _course.durationDays?.toString() ?? '',
    );
    _maxParticipantsController = TextEditingController(
      text: _course.maxParticipants?.toString() ?? '',
    );
    _notesController = TextEditingController(text: _course.notes);
    _startDateController = TextEditingController(
      text: _course.startDate != null
          ? '${_course.startDate?.year}-${_course.startDate?.month}-${_course.startDate?.day}'
          : '',
    );

    _loadInstructors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _targetGroupController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    _notesController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructors() async {
    try {
      final instructors = await TrainingApi.getInstructors();
      setState(() {
        _instructors = instructors.cast<Map<String, dynamic>>();
        if (_isEditMode && _course.instructorName != null) {
          final inst = _instructors.firstWhere(
            (i) => i['name'] == _course.instructorName,
            orElse: () => {},
          );
          if (inst.isNotEmpty) _selectedInstructorId = inst['id'].toString();
        }
      });
    } catch (e) {
      _showError('خطأ في تحميل المدربين');
    }
  }

  void _showError(String m) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: _isEditMode ? 'تعديل الدورة' : 'إضافة دورة جديدة',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              const ModernScreenHeader(
                title: 'بيانات الدورة التدريبية',
                subtitle:
                    'قم بتحديد تفاصيل البرنامج التدريبي والجدول الزمني المخطط لضمان سير العملية التدريبية بنجاح.',
              ),
              const SizedBox(height: 32),

              ModernSectionCard(
                title: 'المعلومات الأساسية',
                icon: Icons.info_rounded,
                child: Column(
                  children: [
                    ModernTextField(
                      label: 'اسم الدورة',
                      controller: _nameController,
                      onSaved: (v) => _course.courseName = v!,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'يرجى إدخال اسم الدورة'
                          : null,
                      prefixIcon: Icons.auto_stories_rounded,
                    ),
                    ModernDropdownField<String>(
                      label: 'نوع الدورة',
                      value: _course.courseType,
                      items: _courseTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _course.courseType = v),
                      prefixIcon: Icons.category_rounded,
                    ),
                  ],
                ),
              ),

              ModernSectionCard(
                title: 'المكان والزمان',
                icon: Icons.map_rounded,
                child: Column(
                  children: [
                    ModernTextField(
                      label: 'مكان التدريب',
                      controller: _locationController,
                      onSaved: (v) => _course.location = v,
                      prefixIcon: Icons.location_on_rounded,
                    ),
                    ModernTextField(
                      label: 'تاريخ البدء',
                      controller: _startDateController,
                      readOnly: true,
                      prefixIcon: Icons.calendar_today_rounded,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) {
                          setState(() {
                            _course.startDate = d;
                            _startDateController.text =
                                '${d.year}-${d.month}-${d.day}';
                          });
                        }
                      },
                    ),
                    ModernTextField(
                      label: 'مدة الدورة (أيام)',
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      onSaved: (v) =>
                          _course.durationDays = int.tryParse(v ?? ''),
                      prefixIcon: Icons.timer_rounded,
                    ),
                  ],
                ),
              ),

              ModernSectionCard(
                title: 'المدرب المسؤول',
                icon: Icons.person_search_rounded,
                child: ModernDropdownField<String>(
                  label: 'المدرب',
                  hint: 'اختر مدرباً للدورة من القائمة',
                  value: _selectedInstructorId,
                  items: _instructors
                      .map(
                        (i) => DropdownMenuItem(
                          value: i['id'].toString(),
                          child: Text(
                            '${i['rank'] ?? i['military_rank'] ?? ''} ${i['name'] ?? i['full_name'] ?? ''}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedInstructorId = v;
                      final inst = _instructors.firstWhere(
                        (i) => i['id'].toString() == v,
                      );
                      _course.instructorName = inst['name'];
                      _course.instructorRank = inst['rank'];
                    });
                  },
                  prefixIcon: Icons.supervisor_account_rounded,
                ),
              ),

              ModernSectionCard(
                title: 'السعة والحالة',
                icon: Icons.settings_rounded,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ModernTextField(
                            label: 'السعة القصوى',
                            controller: _maxParticipantsController,
                            keyboardType: TextInputType.number,
                            onSaved: (v) =>
                                _course.maxParticipants = int.tryParse(v ?? ''),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ModernDropdownField<String>(
                            label: 'حالة الدورة',
                            value: _course.courseStatus,
                            items: _courseStatuses
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _course.courseStatus = v),
                          ),
                        ),
                      ],
                    ),
                    ModernTextField(
                      label: 'ملاحظات',
                      controller: _notesController,
                      maxLines: 3,
                      onSaved: (v) => _course.notes = v,
                      prefixIcon: Icons.note_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ModernGradientButton(
                text: _isLoading ? 'جاري الحفظ...' : 'حفظ الدورة',
                onPressed: _isLoading ? () {} : _saveCourse,
                icon: Icons.save_rounded,
                isLoading: _isLoading,
                height: 60,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.tajawal(
                    color: AppColors.slate500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        if (_isEditMode) {
          await TrainingApi.updateTrainingCourse(_course);
        } else {
          await TrainingApi.createTrainingCourse(_course);
        }
        Navigator.pop(context, true);
      } catch (e) {
        _showError('خطأ أثناء الحفظ');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
