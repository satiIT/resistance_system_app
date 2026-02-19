// lib/presentation/pages/training/training_form_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import './../../../core/models/training_record.dart';
import '../../../core/models/training_course.dart';
import '../../../core/services/training_api.dart';

class TrainingFormScreen extends StatefulWidget {
  final TrainingRecord? existingRecord;

  TrainingFormScreen({this.existingRecord});

  @override
  _TrainingFormScreenState createState() => _TrainingFormScreenState();
}

class _TrainingFormScreenState extends State<TrainingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TrainingRecord _trainingRecord;
  bool isLoading = false;
  bool isInitialized = false;

  List<Map<String, dynamic>> _personnelList = [];
  List<TrainingCourse> _coursesList = [];
  final List<String> _trainingTypes = [
    'مفتوح',
    'أولي',
    'متقدم',
    'دورة سلاح معاون',
  ];
  final List<String> _attendanceStatuses = ['حاضر', 'غائب', 'متأخر', 'منقطع'];
  final List<String> _specializedCourses = [
    'سواقة عربات',
    'دورة أمنية',
    'دورة قيادة ميدان',
    'دورة استخبارات',
    'دورة اتصالات',
    'دورة إسعافات أولية',
  ];

  List<Map<String, dynamic>> _selectedPersonnel = [];

  @override
  void initState() {
    super.initState();
    _trainingRecord =
        widget.existingRecord ?? TrainingRecord(personnelId: 0, courseId: 0);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final results = await Future.wait([
        TrainingApi.getPersonnelList(),
        TrainingApi.getTrainingCourses(),
      ]);

      setState(() {
        _personnelList = (results[0] as List).cast<Map<String, dynamic>>();
        _coursesList = (results[1] as List).cast<TrainingCourse>();

        if (widget.existingRecord != null &&
            widget.existingRecord!.personnelId != 0) {
          var existingPerson = _personnelList.firstWhere(
            (person) => person['id'] == widget.existingRecord!.personnelId,
            orElse: () => {},
          );
          if (existingPerson.isNotEmpty) {
            _selectedPersonnel.add(existingPerson);
          }
        }
        isInitialized = true;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
      setState(() => isInitialized = true);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ModernPageScaffold(
      title: widget.existingRecord == null ? 'تسجيل تدريب جديد' : 'تعديل السجل',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              const ModernScreenHeader(
                title: 'استمارة التدريب',
                subtitle:
                    'قم بتعبئة بيانات التدريب بدقة للمستنفرين المحددين لضمان صحة السجلات.',
              ),
              const SizedBox(height: 32),

              ModernSectionCard(
                title: 'المستنفرين',
                icon: Icons.group_add_rounded,
                child: _buildPersonnelContent(),
              ),

              ModernSectionCard(
                title: 'بيانات الدورة',
                icon: Icons.school_rounded,
                child: Column(
                  children: [
                    ModernDropdownField<int>(
                      label: 'الدورة التدريبية',
                      value: _trainingRecord.courseId != 0
                          ? _trainingRecord.courseId
                          : null,
                      items: _coursesList
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.courseName),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _trainingRecord.courseId = val ?? 0),
                      prefixIcon: Icons.auto_stories_rounded,
                      validator: (v) =>
                          (v == null || v == 0) ? 'يرجى اختيار الدورة' : null,
                    ),
                    ModernDropdownField<String>(
                      label: 'نوع التدريب السابق',
                      value: _trainingRecord.priorTrainingType,
                      items: _trainingTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (val) => setState(
                        () => _trainingRecord.priorTrainingType = val,
                      ),
                      prefixIcon: Icons.military_tech_rounded,
                    ),
                  ],
                ),
              ),

              ModernSectionCard(
                title: 'تفاصيل الموقع والعتاد',
                icon: Icons.location_on_rounded,
                child: Column(
                  children: [
                    ModernTextField(
                      label: 'معسكر التدريب',
                      initialValue: _trainingRecord.trainingCampName,
                      onChanged: (v) => _trainingRecord.trainingCampName = v,
                      prefixIcon: Icons.fort_rounded,
                    ),
                    ModernTextField(
                      label: 'موقع الرماية',
                      initialValue: _trainingRecord.firingLocation,
                      onChanged: (v) => _trainingRecord.firingLocation = v,
                      prefixIcon: Icons.gps_fixed_rounded,
                    ),
                    ModernTextField(
                      label: 'نوع السلاح',
                      initialValue: _trainingRecord.weaponType,
                      onChanged: (v) => _trainingRecord.weaponType = v,
                      prefixIcon: Icons.security_rounded,
                    ),
                  ],
                ),
              ),

              ModernSectionCard(
                title: 'التدريب المتخصص',
                icon: Icons.engineering_rounded,
                child: Column(
                  children: [
                    ModernDropdownField<String>(
                      label: 'الدورة المتخصصة',
                      value: _trainingRecord.specializedCourseType,
                      items: _specializedCourses
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) => setState(
                        () => _trainingRecord.specializedCourseType = val,
                      ),
                      prefixIcon: Icons.star_border_rounded,
                    ),
                    ModernTextField(
                      label: 'تدريب السلاح الخاص',
                      initialValue: _trainingRecord.weaponTrainingType,
                      onChanged: (v) => _trainingRecord.weaponTrainingType = v,
                      prefixIcon: Icons.flash_on_rounded,
                    ),
                  ],
                ),
              ),

              ModernSectionCard(
                title: 'التقييم والنتائج',
                icon: Icons.assessment_rounded,
                child: Column(
                  children: [
                    ModernDropdownField<String>(
                      label: 'حالة الحضور',
                      value: _trainingRecord.attendanceStatus,
                      items: _attendanceStatuses
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) => setState(
                        () => _trainingRecord.attendanceStatus = val,
                      ),
                      prefixIcon: Icons.check_circle_outline_rounded,
                    ),
                    ModernTextField(
                      label: 'درجة التقييم (0 - 100)',
                      keyboardType: TextInputType.number,
                      initialValue: _trainingRecord.evaluationScore?.toString(),
                      onChanged: (v) =>
                          _trainingRecord.evaluationScore = int.tryParse(v),
                      prefixIcon: Icons.grade_rounded,
                    ),
                    _buildCertificateToggle(),
                    const SizedBox(height: 12),
                    ModernTextField(
                      label: 'ملاحظات إضافية',
                      maxLines: 3,
                      initialValue: _trainingRecord.notes,
                      onChanged: (v) => _trainingRecord.notes = v,
                      prefixIcon: Icons.note_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ModernGradientButton(
                text: isLoading ? 'جاري الحفظ...' : 'حفظ البيانات',
                onPressed: isLoading ? () {} : _saveTrainingRecord,
                icon: Icons.save_rounded,
                isLoading: isLoading,
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

  Widget _buildPersonnelContent() {
    return Column(
      children: [
        if (_selectedPersonnel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: _selectedPersonnel
                  .map((person) => _buildPersonItem(person))
                  .toList(),
            ),
          ),
        if (widget.existingRecord == null)
          ModernDropdownField<Map<String, dynamic>>(
            label: 'إضافة مستنفر',
            hint: 'اختر المستنفر للإضافة',
            value: null,
            items: _personnelList
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(
                      '${p['name']} - ${p['military_number']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                if (!_selectedPersonnel.any((p) => p['id'] == val['id'])) {
                  setState(() => _selectedPersonnel.add(val));
                } else {
                  _showErrorSnackBar('هذا المستنفر مضاف مسبقاً');
                }
              }
            },
            prefixIcon: Icons.person_add_rounded,
          ),
      ],
    );
  }

  Widget _buildPersonItem(Map<String, dynamic> person) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person['name'] ?? '',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  person['military_number'] ?? '',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          if (widget.existingRecord == null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedPersonnel.remove(person)),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCertificateToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : AppColors.slate200).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _trainingRecord.certificateReceived ?? false,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (v) => setState(
              () => _trainingRecord.certificateReceived = v ?? false,
            ),
          ),
          Text(
            'تم استلام الشهادة',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrainingRecord() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPersonnel.isEmpty) {
        _showErrorSnackBar('يرجى إضافة مستنفر واحد على الأقل');
        return;
      }

      setState(() => isLoading = true);
      try {
        if (widget.existingRecord == null) {
          for (var person in _selectedPersonnel) {
            var record = TrainingRecord(
              personnelId: person['id'],
              courseId: _trainingRecord.courseId,
              priorTrainingType: _trainingRecord.priorTrainingType,
              trainingCampName: _trainingRecord.trainingCampName,
              firingLocation: _trainingRecord.firingLocation,
              weaponType: _trainingRecord.weaponType,
              specializedCourseType: _trainingRecord.specializedCourseType,
              weaponTrainingType: _trainingRecord.weaponTrainingType,
              attendanceStatus: _trainingRecord.attendanceStatus,
              evaluationScore: _trainingRecord.evaluationScore,
              certificateReceived: _trainingRecord.certificateReceived,
              notes: _trainingRecord.notes,
            );
            await TrainingApi.createTrainingRecord(record);
          }
          _showSuccessSnackBar('تم حفظ سجلات التدريب بنجاح');
        } else {
          await TrainingApi.updateTrainingRecord(_trainingRecord);
          _showSuccessSnackBar('تم تحديث السجل بنجاح');
        }
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar('حدث خطأ أثناء الحفظ: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }
}
