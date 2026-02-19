import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/services/training_api.dart';

class InstructorFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingInstructor;

  InstructorFormScreen({this.existingInstructor});

  @override
  _InstructorFormScreenState createState() => _InstructorFormScreenState();
}

class _InstructorFormScreenState extends State<InstructorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _instructor;
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _ranks = [
    'مساعد',
    'مساعد أول',
    'ملازم',
    'ملازم أول',
    'نقيب',
    'رائد',
    'مقدم',
    'عقيد',
    'عميد',
    'لواء',
    'فريق',
    'فريق أول',
  ];
  final List<String> _specialties = [
    'أسلحة خفيفة',
    'أسلحة ثقيلة',
    'تكتيك',
    'استخبارات',
    'إشارة/اتصالات',
    'طبابة',
    'سواقة/آليات',
    'تدريب مشاة',
  ];

  late TextEditingController _nameController;
  late TextEditingController _militaryNoController;
  late TextEditingController _unitController;
  late TextEditingController _phoneController;
  late TextEditingController _residenceController;
  late TextEditingController _experienceController;
  late TextEditingController _qualificationsController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingInstructor != null;
    _instructor = widget.existingInstructor != null
        ? Map.from(widget.existingInstructor!)
        : {};

    // Aligning with API keys: name, rank, specialization, residence, etc.
    _nameController = TextEditingController(
      text: _instructor['name'] ?? _instructor['full_name'],
    );
    _militaryNoController = TextEditingController(
      text: _instructor['military_number'],
    );
    _unitController = TextEditingController(text: _instructor['unit']);
    _phoneController = TextEditingController(text: _instructor['phone_number']);
    _residenceController = TextEditingController(
      text: _instructor['residence'] ?? _instructor['current_residence'],
    );
    _experienceController = TextEditingController(
      text: _instructor['experience_years']?.toString(),
    );
    _qualificationsController = TextEditingController(
      text: _instructor['qualifications'],
    );
    _notesController = TextEditingController(text: _instructor['notes']);

    // Ensure initial values for dropdowns match API keys if present
    if (_instructor['rank'] == null && _instructor['military_rank'] != null) {
      _instructor['rank'] = _instructor['military_rank'];
    }
    if (_instructor['specialization'] == null &&
        _instructor['specialty'] != null) {
      _instructor['specialization'] = _instructor['specialty'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _militaryNoController.dispose();
    _unitController.dispose();
    _phoneController.dispose();
    _residenceController.dispose();
    _experienceController.dispose();
    _qualificationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: _isEditMode ? 'تعديل البيانات' : 'إضافة مدرب جديد',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              const ModernScreenHeader(
                title: 'بيانات المدرب',
                subtitle:
                    'يرجى تزويدنا بكافة المعلومات المهنية والعسكرية لتوثيق الكفاءات التدريبية بمصداقية.',
              ),
              const SizedBox(height: 32),

              ModernSectionCard(
                title: 'المعلومات العسكرية',
                icon: Icons.military_tech_rounded,
                child: Column(
                  children: [
                    ModernTextField(
                      label: 'الاسم الرباعي',
                      controller: _nameController,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'مطلوب' : null,
                      prefixIcon: Icons.person_rounded,
                    ),
                    ModernDropdownField<String>(
                      label: 'الرتبة العسكرية',
                      value: _instructor['rank'],
                      items: _ranks
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _instructor['rank'] = v),
                      prefixIcon: Icons.workspace_premium_rounded,
                    ),
                    ModernTextField(
                      label: 'الرقم العسكري',
                      controller: _militaryNoController,
                      prefixIcon: Icons.badge_rounded,
                    ),
                    ModernTextField(
                      label: 'الوحدة / التابعية',
                      controller: _unitController,
                      prefixIcon: Icons.corporate_fare_rounded,
                    ),
                  ],
                ),
              ),

              ModernSectionCard(
                title: 'الكفاءة المهنية',
                icon: Icons.workspace_premium_rounded,
                child: Column(
                  children: [
                    ModernDropdownField<String>(
                      label: 'التخصص التدريبي',
                      value: _instructor['specialization'],
                      items: _specialties
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _instructor['specialization'] = v),
                      prefixIcon: Icons.stars_rounded,
                    ),
                    ModernTextField(
                      label: 'سنوات الخبرة',
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.history_rounded,
                    ),
                    ModernTextField(
                      label: 'المؤهلات والدورات الحاصل عليها',
                      controller: _qualificationsController,
                      maxLines: 2,
                      prefixIcon: Icons.school_rounded,
                    ),
                  ],
                ),
              ),

              ModernSectionCard(
                title: 'معلومات التواصل والإقامة',
                icon: Icons.contact_page_rounded,
                child: Column(
                  children: [
                    ModernTextField(
                      label: 'رقم الهاتف',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_rounded,
                    ),
                    ModernTextField(
                      label: 'مكان الإقامة الحالي',
                      controller: _residenceController,
                      prefixIcon: Icons.location_on_rounded,
                    ),
                    ModernTextField(
                      label: 'ملاحظات إضافية',
                      controller: _notesController,
                      maxLines: 3,
                      prefixIcon: Icons.note_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ModernGradientButton(
                text: _isLoading ? 'جاري الحفظ...' : 'حفظ البيانات',
                onPressed: _isLoading ? () {} : _saveInstructor,
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

  Future<void> _saveInstructor() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          ..._instructor,
          'name': _nameController.text,
          'military_number': _militaryNoController
              .text, // Keep as is if API supports it or ignore
          'unit': _unitController.text,
          'phone_number': _phoneController.text,
          'residence': _residenceController.text,
          'experience_years': int.tryParse(_experienceController.text) ?? 0,
          'qualifications': _qualificationsController.text,
          'notes': _notesController.text,
        };

        if (_isEditMode) {
          await TrainingApi.updateInstructor(data['id'], data);
        } else {
          await TrainingApi.createInstructor(data);
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
