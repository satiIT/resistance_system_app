// lib/presentation/pages/casualties/casualty_form_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/models/casualty.dart';
import '../../../core/services/casualty_api.dart';

class CasualtyFormScreen extends StatefulWidget {
  final Casualty? existingCasualty;

  CasualtyFormScreen({this.existingCasualty});

  @override
  _CasualtyFormScreenState createState() => _CasualtyFormScreenState();
}

class _CasualtyFormScreenState extends State<CasualtyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Casualty _casualty;
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _showCompensationFields = false;
  bool _isInitialized = false;
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _personnelList = [];
  Map<int, Map<String, dynamic>> _personnelCache = {};

  final List<String> _caseTypes = ['شهيد', 'جريح'];
  final List<String> _injurySeverities = [
    'خطيرة',
    'محدودة',
    'بسيطة',
    'بسيطة جدا',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode =
        widget.existingCasualty != null && widget.existingCasualty!.id != null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final personnel = await CasualtyApi.getPersonnelList();
      setState(() {
        _personnelList = personnel;
        if (widget.existingCasualty != null) {
          _casualty = widget.existingCasualty!;
          _showCompensationFields = _casualty.isMartyr;
          // جلب بيانات المستنفر إذا كان المعرف موجوداً (حتى في وضع الإضافة)
          if (_casualty.personnelId != null && _casualty.personnelId != 0) {
            _loadPersonnelData(_casualty.personnelId!);
          }
        } else {
          _casualty = Casualty(
            personnelId: 0,
            caseType: 'جريح',
            incidentDate: DateTime.now(),
            incidentLocation: '',
            signalNumber: '',
            injurySeverity: 'بسيطة',
          );
        }
        _dateController.text =
            '${_casualty.incidentDate!.year}-${_casualty.incidentDate!.month.toString().padLeft(2, '0')}-${_casualty.incidentDate!.day.toString().padLeft(2, '0')}';
        _isInitialized = true;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
      setState(() => _isInitialized = true);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadPersonnelData(int personnelId) async {
    if (_personnelCache.containsKey(personnelId)) {
      final person = _personnelCache[personnelId]!;
      setState(() {
        _casualty.militaryNumber = person['military_number'];
        _casualty.fullName = person['full_name'];
      });
      return;
    }
    try {
      final person = await CasualtyApi.getPersonnelById(personnelId);
      setState(() {
        _casualty.militaryNumber = person['military_id']?.toString() ?? '';
        _casualty.fullName =
            '${person['first_name']} ${person['second_name']} ${person['third_name']} ${person['fourth_name']}';
        _personnelCache[personnelId] = {
          'military_number': _casualty.militaryNumber,
          'full_name': _casualty.fullName,
        };
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل بيانات المستنفر: $e');
    }
  }

  Future<void> _saveCasualty() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_casualty.personnelId == 0) {
        _showErrorSnackBar('يرجى اختيار مستنفر من القائمة');
        return;
      }
      setState(() => _isLoading = true);
      try {
        final bool isUpdate =
            _isEditMode && _casualty.id != null && _casualty.id != 0;

        if (isUpdate) {
          await CasualtyApi.updateCasualty(_casualty);
          _showSuccessSnackBar('تم تحديث البيانات بنجاح');
        } else {
          await CasualtyApi.createCasualty(_casualty);
          _showSuccessSnackBar('تم حفظ البيانات بنجاح');
        }
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar('خطأ في حفظ البيانات: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const ModernPageScaffold(
        title: 'جاري التحميل...',
        children: [
          Center(child: CircularProgressIndicator(color: AppColors.error)),
        ],
      );
    }

    return ModernPageScaffold(
      title: _isEditMode ? 'تعديل السجل' : 'إضافة سجل تضحية',
      children: [
        const ModernScreenHeader(
          title: 'بيانات الاستمارة',
          subtitle:
              'يرجى إكمال جميع الحقول المطلوبة لتوثيق الحالة بدقة في استمارة رقم (4).',
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPersonnelSection(),
              _buildCaseTypeSection(),
              _buildIncidentSection(),
              _buildContactSection(),
              if (_showCompensationFields) _buildCompensationSection(),
              const SizedBox(height: 24),
              ModernGradientButton(
                text: _isEditMode ? 'تحديث السجل' : 'حفظ البيانات',
                isLoading: _isLoading,
                onPressed: _saveCasualty,
                gradientColors: [AppColors.error, const Color(0xFFD32F2F)],
                icon: Icons.save_rounded,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.tajawal(color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonnelSection() {
    return ModernSectionCard(
      title: 'المستنفر المعني',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          ModernDropdownField<int>(
            label: 'اختر المستنفر',
            value: _casualty.personnelId != 0 ? _casualty.personnelId : null,
            items: _personnelList.map((person) {
              return DropdownMenuItem<int>(
                value: person['id'],
                child: Text(person['full_name'] ?? 'بدون اسم'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _casualty.personnelId = val);
                _loadPersonnelData(val);
              }
            },
            validator: (val) => val == null ? 'يرجى اختيار المستنفر' : null,
            prefixIcon: Icons.search_rounded,
          ),
          if (_casualty.personnelId != 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: ModernStatusBadge(
                text: 'الرقم العسكري: ${_casualty.militaryNumber ?? "-"}',
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaseTypeSection() {
    return ModernSectionCard(
      title: 'نوع الحالة',
      icon: Icons.assignment_rounded,
      child: ModernDropdownField<String>(
        label: 'نوع الاستمارة',
        value: _casualty.caseType,
        items: _caseTypes
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (val) {
          setState(() {
            _casualty.caseType = val!;
            _showCompensationFields = val == 'شهيد';
          });
        },
        prefixIcon: Icons.category_rounded,
      ),
    );
  }

  Widget _buildIncidentSection() {
    return ModernSectionCard(
      title: 'بيانات الحادث',
      icon: Icons.event_note_rounded,
      child: Column(
        children: [
          ModernTextField(
            label: 'تاريخ الواقعة',
            prefixIcon: Icons.calendar_today_rounded,
            readOnly: true,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _casualty.incidentDate!,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) {
                setState(() {
                  _casualty.incidentDate = d;
                  _dateController.text =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                });
              }
            },
            controller: _dateController,
          ),
          ModernTextField(
            label: 'موقع الحادث',
            initialValue: _casualty.incidentLocation,
            onSaved: (v) => _casualty.incidentLocation = v!,
            prefixIcon: Icons.location_on_rounded,
            validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
          ),
          ModernTextField(
            label: 'رقم الإشارة',
            initialValue: _casualty.signalNumber,
            onSaved: (v) => _casualty.signalNumber = v!,
            prefixIcon: Icons.tag_rounded,
          ),
          if (_casualty.isInjured)
            ModernDropdownField<String>(
              label: 'حالة الإصابة',
              value: _casualty.injurySeverity,
              items: _injurySeverities
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _casualty.injurySeverity = v!),
              prefixIcon: Icons.health_and_safety_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return ModernSectionCard(
      title: 'بيانات التواصل ذوي القربى',
      icon: Icons.contacts_rounded,
      child: Column(
        children: [
          ModernTextField(
            label: 'اسم القريب',
            initialValue: _casualty.nextOfKinName,
            onSaved: (v) => _casualty.nextOfKinName = v,
            prefixIcon: Icons.person_outline_rounded,
          ),
          ModernTextField(
            label: 'رقم الهاتف',
            initialValue: _casualty.nextOfKinPhone,
            onSaved: (v) => _casualty.nextOfKinPhone = v,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildCompensationSection() {
    return ModernSectionCard(
      title: 'بيانات الخلافة والتعويض',
      icon: Icons.monetization_on_rounded,
      child: Column(
        children: [
          ModernTextField(
            label: 'المبلغ المستحق',
            initialValue: _casualty.compensationAmount?.toString(),
            onSaved: (v) =>
                _casualty.compensationAmount = double.tryParse(v ?? '0'),
            keyboardType: TextInputType.number,
            prefixIcon: Icons.money_rounded,
          ),
          ModernTextField(
            label: 'الجهة الدافعة',
            initialValue: _casualty.payingEntity,
            onSaved: (v) => _casualty.payingEntity = v,
            prefixIcon: Icons.business_rounded,
          ),
          ModernTextField(
            label: 'المستلم',
            initialValue: _casualty.compensationRecipient,
            onSaved: (v) => _casualty.compensationRecipient = v,
            prefixIcon: Icons.person_add_rounded,
          ),
        ],
      ),
    );
  }
}
