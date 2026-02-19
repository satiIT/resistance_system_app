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
    _isEditMode = widget.existingCasualty != null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final personnel = await CasualtyApi.getPersonnelList();
      setState(() {
        _personnelList = personnel;
        if (_isEditMode) {
          _casualty = widget.existingCasualty!;
          _showCompensationFields = _casualty.isMartyr;
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
            '${_casualty.incidentDate!.year}-${_casualty.incidentDate!.month}-${_casualty.incidentDate!.day}';
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
        if (_isEditMode) {
          await CasualtyApi.updateCasualty(_casualty);
        } else {
          await CasualtyApi.createCasualty(_casualty);
        }
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar('خطأ حفظ البيانات: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'تعديل السجل' : 'إضافة سجل تضحية',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const ModernScreenHeader(
              title: 'بيانات الاستمارة',
              subtitle: 'يرجى إكمال جميع الحقول المطلوبة لتوثيق الحالة بدقة.',
            ),
            const SizedBox(height: 24),

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
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(
                  color: isDark ? Colors.white24 : AppColors.slate300,
                ),
                foregroundColor: isDark ? Colors.white : AppColors.slate700,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernSectionTitle(
          title: 'المستنفر المعني',
          icon: Icons.person_rounded,
        ),
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
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الرقم العسكري: ${_casualty.militaryNumber ?? "-"}',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _casualty.fullName ?? '',
                        style: GoogleFonts.tajawal(
                          color: AppColors.slate500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCaseTypeSection() {
    return Column(
      children: [
        const ModernSectionTitle(
          title: 'نوع الحالة',
          icon: Icons.assignment_rounded,
        ),
        ModernDropdownField<String>(
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
      ],
    );
  }

  Widget _buildIncidentSection() {
    return Column(
      children: [
        const ModernSectionTitle(
          title: 'بيانات الحادث',
          icon: Icons.event_note_rounded,
        ),
        ModernTextField(
          label: 'تاريخ الواقعة',
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
                _dateController.text = '${d.year}-${d.month}-${d.day}';
              });
            }
          },
          controller: _dateController,
          prefixIcon: Icons.calendar_today_rounded,
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
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        const ModernSectionTitle(
          title: 'بيانات التواصل ذوي القربى',
          icon: Icons.contacts_rounded,
        ),
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
    );
  }

  Widget _buildCompensationSection() {
    return Column(
      children: [
        const ModernSectionTitle(
          title: 'بيانات الخلافة',
          icon: Icons.monetization_on_rounded,
        ),
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
    );
  }
}
