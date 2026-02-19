// lib/presentation/pages/personnel/personnel_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/core/services/personnel_service.dart';
import 'package:resistance_system_app/core/utils/data_parser.dart';

class PersonnelFormScreen extends StatefulWidget {
  final String? personnelId;
  final Map<String, dynamic>? initialData;

  const PersonnelFormScreen({super.key, this.personnelId, this.initialData});

  @override
  _PersonnelFormScreenState createState() => _PersonnelFormScreenState();
}

class _PersonnelFormScreenState extends State<PersonnelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditing = false;

  // Form data
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.personnelId != null;

    // Initialize form with default values
    final defaultData = {
      'first_name': '',
      'second_name': '',
      'third_name': '',
      'fourth_name': '',
      'national_id': '',
      'birth_date': '',
      'gender': 'ذكر',
      'marital_status': 'أعزب',
      'military_id': '',
      'rank': '',
      'unit': '',
      'status': 'نشط',
      'enlistment_date': '',
      'phone_number': '',
      'email': '',
      'address': '',
      'emergency_contact_phone': '',
      'mother_full_name': '',
      'mother_phone': '',
      'next_of_kin': '',
      'next_of_kin_phone': '',
      'wives_count': '0',
      'children_count': '0',
      'dependents_count': '0',
      'state': '',
      'locality': '',
      'administrative_unit': '',
      'city_village': '',
      'current_residence': '',
      'prewar_residence': '',
      'place_of_origin': '',
      'military_background': '',
      'basic_training': '',
      'weapon_type': '',
      'last_training_date': '',
      'education_level': '',
      'occupation': '',
      'skills': '',
      'health_status': '',
      'blood_type': '',
      'chronic_conditions': '',
      'allergies': '',
      'medical_notes': '',
    };

    _formData = Map<String, dynamic>.from(defaultData);

    // If editing, load existing data robustly
    if (widget.initialData != null) {
      defaultData.keys.forEach((key) {
        final value = DataParser.smartGetString(
          widget.initialData!,
          key,
          defaultValue: '',
        );
        if (value.isNotEmpty) {
          _formData[key] = value;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    // First, validate the form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء ملء الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save form data
    _formKey.currentState!.save();

    // Parse numeric fields to ensure they are numbers if the backend expects them
    final Map<String, dynamic> submissionData = Map<String, dynamic>.from(
      _formData,
    );
    final numericFields = ['wives_count', 'children_count', 'dependents_count'];
    for (var field in numericFields) {
      if (submissionData[field] != null) {
        submissionData[field] =
            int.tryParse(submissionData[field].toString()) ?? 0;
      }
    }

    print('🚀 Form Data validated: $submissionData');

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing && widget.personnelId != null) {
        await PersonnelService.updatePersonnel(
          widget.personnelId!,
          submissionData,
        );
        _showSuccessSnackbar('تم تحديث بيانات المستنفر بنجاح');
      } else {
        await PersonnelService.createPersonnel(submissionData);
        _showSuccessSnackbar('تم إضافة المستنفر بنجاح');
      }

      // Navigate back after successful submission
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Form submission error: $e');
      _showErrorSnackbar('خطأ: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.primary : AppColors.slate900,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    String fieldName, {
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? AppColors.slate400 : AppColors.slate700,
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.slate800 : Colors.grey[300]!,
            ),
          ),
          suffixIcon: isRequired
              ? const Icon(Icons.star, color: Colors.red, size: 12)
              : null,
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        initialValue: _formData[fieldName]?.toString() ?? '',
        style: TextStyle(color: isDark ? Colors.white : AppColors.slate900),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
        onChanged: (value) {
          _formData[fieldName] = value.trim();
        },
        onSaved: (value) {
          _formData[fieldName] = value?.trim() ?? '';
        },
      ),
    );
  }

  Widget _buildDropdownFormField(
    String label,
    String fieldName,
    List<Map<String, String>> options, {
    bool isRequired = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String currentValue = _formData[fieldName]?.toString() ?? '';

    // If current value is empty and options exist, use first option's value
    if (currentValue.isEmpty && options.isNotEmpty) {
      currentValue = options.first['value']!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? AppColors.slate400 : AppColors.slate700,
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.slate800 : Colors.grey[300]!,
            ),
          ),
          suffixIcon: isRequired
              ? const Icon(Icons.star, color: Colors.red, size: 12)
              : null,
        ),
        value: currentValue.isNotEmpty ? currentValue : null,
        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : AppColors.slate900),
        items: options.map((opt) {
          return DropdownMenuItem<String>(
            value: opt['value'],
            child: Text(opt['label']!),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _formData[fieldName] = value;
          });
        },
        onSaved: (value) {
          _formData[fieldName] = value;
        },
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'هذا الحقل مطلوب';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'تحديث بيانات المستنفر' : 'إضافة مستنفر جديد'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _submitForm,
              tooltip: 'حفظ',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Basic Information
                    Card(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.slate800
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('المعلومات الأساسية'),
                            _buildTextFormField(
                              'الاسم الأول',
                              'first_name',
                              isRequired: true,
                            ),
                            _buildTextFormField(
                              'اسم الأب',
                              'second_name',
                              isRequired: true,
                            ),
                            _buildTextFormField('اسم الجد', 'third_name'),
                            _buildTextFormField('اسم العائلة', 'fourth_name'),
                            _buildTextFormField(
                              'الرقم القومي',
                              'national_id',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              maxLength: 14,
                            ),
                            _buildDatePicker(
                              'تاريخ الميلاد',
                              'birth_date',
                              isRequired: true,
                            ),
                            _buildDropdownFormField('الجنس', 'gender', [
                              {'label': 'ذكر', 'value': 'ذكر'},
                              {'label': 'أنثى', 'value': 'أنثى'},
                            ]),
                            _buildDropdownFormField(
                              'الحالة الاجتماعية',
                              'marital_status',
                              [
                                {'label': 'أعزب', 'value': 'أعزب'},
                                {'label': 'متزوج', 'value': 'متزوج'},
                                {'label': 'مطلق', 'value': 'مطلق'},
                                {'label': 'أرمل', 'value': 'أرمل'},
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Family Information
                    Card(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.slate800
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('المعلومات الأسرية'),
                            _buildTextFormField(
                              'اسم الوالدة بالكامل',
                              'mother_full_name',
                            ),
                            _buildTextFormField(
                              'رقم هاتف الوالدة',
                              'mother_phone',
                              keyboardType: TextInputType.phone,
                            ),
                            _buildTextFormField('أقرب الأقربين', 'next_of_kin'),
                            _buildTextFormField(
                              'رقم هاتف الأقربين',
                              'next_of_kin_phone',
                              keyboardType: TextInputType.phone,
                            ),
                            _buildTextFormField(
                              'عدد الزوجات',
                              'wives_count',
                              keyboardType: TextInputType.number,
                            ),
                            _buildTextFormField(
                              'عدد الأبناء',
                              'children_count',
                              keyboardType: TextInputType.number,
                            ),
                            _buildTextFormField(
                              'عدد المعالين',
                              'dependents_count',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Military Information
                    Card(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.slate800
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('المعلومات العسكرية'),
                            _buildTextFormField('الرقم العسكري', 'military_id'),
                            _buildTextFormField('الرتبة', 'rank'),
                            _buildTextFormField('الوحدة', 'unit'),
                            _buildDropdownFormField('الحالة', 'status', [
                              {'label': 'نشط', 'value': 'نشط'},
                              {'label': 'غير نشط', 'value': 'غير نشط'},
                              {'label': 'متقاعد', 'value': 'متقاعد'},
                              {'label': 'شهيد', 'value': 'شهيد'},
                              {'label': 'جريح', 'value': 'جريح'},
                            ]),
                            _buildDatePicker(
                              'تاريخ الالتحاق',
                              'enlistment_date',
                            ),
                            _buildTextFormField(
                              'الخلفية العسكرية',
                              'military_background',
                            ),
                            _buildTextFormField(
                              'التدريب الأساسي',
                              'basic_training',
                            ),
                            _buildTextFormField('نوع السلاح', 'weapon_type'),
                            _buildDatePicker(
                              'تاريخ آخر تدريب',
                              'last_training_date',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact Information
                    Card(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.slate800
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('معلومات الاتصال'),
                            _buildTextFormField(
                              'رقم الهاتف',
                              'phone_number',
                              keyboardType: TextInputType.phone,
                              maxLength: 15,
                            ),
                            _buildTextFormField(
                              'البريد الإلكتروني',
                              'email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _buildTextFormField('العنوان', 'address'),
                            _buildTextFormField(
                              'هاتف الطوارئ',
                              'emergency_contact_phone',
                              keyboardType: TextInputType.phone,
                              maxLength: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Geographical Information
                    Card(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.slate800
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('التصنيف الجغرافي'),
                            _buildTextFormField('الولاية', 'state'),
                            _buildTextFormField('المحلية', 'locality'),
                            _buildTextFormField(
                              'الوحدة الإدارية',
                              'administrative_unit',
                            ),
                            _buildTextFormField(
                              'المدينة/القرية',
                              'city_village',
                            ),
                            _buildTextFormField(
                              'السكن الحالي',
                              'current_residence',
                            ),
                            _buildTextFormField(
                              'السكن قبل الحرب',
                              'prewar_residence',
                            ),
                            _buildTextFormField(
                              'الموطن الأصلي',
                              'place_of_origin',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Education and Skills
                    Card(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.slate800
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('التعليم والمهارات'),
                            _buildTextFormField(
                              'المستوى التعليمي',
                              'education_level',
                            ),
                            _buildTextFormField('المهنة', 'occupation'),
                            _buildTextFormField('المهارات', 'skills'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medical Information
                    Card(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.slate800
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('المعلومات الطبية'),
                            _buildTextFormField(
                              'الحالة الصحية',
                              'health_status',
                            ),
                            _buildDropdownFormField(
                              'فصيلة الدم',
                              'blood_type',
                              [
                                {'label': 'A+', 'value': 'A+'},
                                {'label': 'A-', 'value': 'A-'},
                                {'label': 'B+', 'value': 'B+'},
                                {'label': 'B-', 'value': 'B-'},
                                {'label': 'O+', 'value': 'O+'},
                                {'label': 'O-', 'value': 'O-'},
                                {'label': 'AB+', 'value': 'AB+'},
                                {'label': 'AB-', 'value': 'AB-'},
                              ],
                            ),
                            _buildTextFormField(
                              'الأمراض المزمنة',
                              'chronic_conditions',
                            ),
                            _buildTextFormField('الحساسيات', 'allergies'),
                            _buildTextFormField(
                              'الملاحظات الطبية',
                              'medical_notes',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isDark
                            ? AppColors.primary
                            : Colors.blue,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditing ? 'تحديث المستنفر' : 'حفظ المستنفر',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatePicker(
    String label,
    String fieldName, {
    bool isRequired = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentValue = _formData[fieldName]?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          DateTime? initialDate;
          if (currentValue.isNotEmpty) {
            try {
              initialDate = DateTime.parse(currentValue);
            } catch (e) {
              initialDate = DateTime.now();
            }
          } else {
            initialDate = DateTime.now();
          }

          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: isDark
                    ? ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: AppColors.darkSurface,
                          onSurface: Colors.white,
                        ),
                        dialogBackgroundColor: AppColors.darkSurface,
                      )
                    : ThemeData.light(),
                child: child!,
              );
            },
          );

          if (picked != null) {
            setState(() {
              _formData[fieldName] = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isDark ? AppColors.slate400 : AppColors.slate700,
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : Colors.grey[50],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? AppColors.slate800 : Colors.grey[300]!,
              ),
            ),
            suffixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRequired)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.star, color: Colors.red, size: 10),
                    ),
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          child: Text(
            currentValue.isEmpty ? 'اختر التاريخ' : currentValue,
            style: TextStyle(
              color: currentValue.isEmpty
                  ? (isDark ? AppColors.slate400 : AppColors.slate600)
                  : (isDark ? Colors.white : AppColors.slate900),
            ),
          ),
        ),
      ),
    );
  }
}
