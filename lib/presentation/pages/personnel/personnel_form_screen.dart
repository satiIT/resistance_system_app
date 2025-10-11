// lib/presentation/pages/personnel/personnel_form_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelFormScreen extends StatefulWidget {
  final Map<String, dynamic>? personnelData;
  final bool isEdit;

  const PersonnelFormScreen({Key? key, this.personnelData, this.isEdit = false}) : super(key: key);

  @override
  _PersonnelFormScreenState createState() => _PersonnelFormScreenState();
}

class _PersonnelFormScreenState extends State<PersonnelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  // قوائم الاختيارات
  final List<String> _states = ['ولاية الخرطوم', 'ولاية الجزيرة', 'ولاية كردفان', 'ولاية دارفور'];
  final List<String> _localities = ['محلية شرق النيل', 'محلية غرب النيل', 'محلية الخرطوم', 'محلية أم درمان'];
  final List<String> _ranks = ['جندي', 'عريف', 'رقيب', 'مساعد', 'ملازم'];
  final List<String> _units = ['عهد الرجال 1', 'عهد الرجال 2', 'عهد الرجال 3', 'أسود العرين 1', 'أسود العرين 2'];
  final List<String> _maritalStatus = ['أعزب', 'متزوج', 'مطلق', 'أرمل'];
  final List<String> _educationLevels = ['أمي', 'ابتدائي', 'متوسط', 'ثانوي', 'جامعي', 'فوق الجامعي'];

  @override
  void initState() {
    super.initState();
    // إذا كان تعديل، نملأ البيانات
    if (widget.isEdit && widget.personnelData != null) {
      _formData.addAll(widget.personnelData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'تعديل بيانات المستنفر' : 'إضافة مستنفر جديد'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildBasicInfoSection(),
          SizedBox(height: 24),
          _buildGeographicalInfoSection(),
          SizedBox(height: 24),
          _buildMilitaryInfoSection(),
          SizedBox(height: 24),
          _buildFamilyInfoSection(),
          SizedBox(height: 24),
          _buildMedicalInfoSection(),
          SizedBox(height: 32),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: TabBar(
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: 'المعلومات الأساسية'),
                Tab(text: 'التصنيف الجغرافي'),
                Tab(text: 'المعلومات العسكرية'),
                Tab(text: 'المعلومات الأسرية'),
                Tab(text: 'المعلومات الطبية'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBasicInfoSection(),
                _buildGeographicalInfoSection(),
                _buildMilitaryInfoSection(),
                _buildFamilyInfoSection(),
                _buildMedicalInfoSection(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'المعلومات الأساسية',
      icon: Icons.person,
      children: [
        _buildTextFormField('الاسم الأول', 'first_name', required: true),
        _buildTextFormField('الاسم الثاني', 'second_name', required: true),
        _buildTextFormField('الاسم الثالث', 'third_name', required: true),
        _buildTextFormField('الاسم الرابع', 'fourth_name', required: true),
        _buildTextFormField('الرقم الوطني', 'national_id', required: true, keyboardType: TextInputType.number),
        _buildDateField('تاريخ الميلاد', 'birth_date'),
        _buildDropdownField('الجنس', 'gender', ['ذكر', 'أنثى']),
        _buildDropdownField('الحالة الاجتماعية', 'marital_status', _maritalStatus),
        _buildDropdownField('المستوى التعليمي', 'education_level', _educationLevels),
        _buildTextFormField('المهنة', 'occupation'),
        _buildTextFormField('المهارات والتخصصات', 'skills', maxLines: 3),
      ],
    );
  }

  Widget _buildGeographicalInfoSection() {
    return _buildSection(
      title: 'التصنيف الجغرافي',
      icon: Icons.location_on,
      children: [
        _buildDropdownField('الولاية', 'state', _states, required: true),
        _buildDropdownField('المحلية', 'locality', _localities, required: true),
        _buildTextFormField('الوحدة الإدارية', 'administrative_unit', required: true),
        _buildTextFormField('المدينة/القرية', 'city_village', required: true),
        _buildTextFormField('السكن الحالي', 'current_address', maxLines: 2),
        _buildTextFormField('السكن قبل الحرب', 'prewar_address', maxLines: 2),
        _buildTextFormField('الموطن الأصلي', 'hometown'),
      ],
    );
  }

  Widget _buildMilitaryInfoSection() {
    return _buildSection(
      title: 'المعلومات العسكرية',
      icon: Icons.security,
      children: [
        _buildTextFormField('الرقم العسكري', 'military_id', required: true, keyboardType: TextInputType.number),
        _buildDropdownField('الرتبة', 'rank', _ranks),
        _buildDropdownField('الوحدة', 'unit', _units),
        _buildDateField('تاريخ الالتحاق', 'enlistment_date'),
        _buildCheckboxField('خلفية عسكرية سابقة', 'military_background'),
        _buildTextFormField('ملاحظات', 'military_notes', maxLines: 3),
      ],
    );
  }

  Widget _buildFamilyInfoSection() {
    return _buildSection(
      title: 'المعلومات الأسرية',
      icon: Icons.family_restroom,
      children: [
        _buildNumberField('عدد الزوجات', 'wives_count'),
        _buildNumberField('عدد الأبناء', 'children_count'),
        _buildNumberField('عدد المعالين', 'dependents_count'),
        _buildTextFormField('أسماء الزوجات', 'wives_names', maxLines: 2),
        _buildTextFormField('اسم الوالدة', 'mother_full_name'),
        _buildTextFormField('الرقم الوطني للوالدة', 'mother_national_id'),
        _buildTextFormField('مكان ميلاد الوالدة', 'mother_birthplace'),
        _buildTextFormField('مكان ميلاد الوالد', 'father_birthplace'),
        _buildTextFormField('أقرب الأقربين', 'next_of_kin_name'),
        _buildTextFormField('عنوان أقرب الأقربين', 'next_of_kin_address', maxLines: 2),
      ],
    );
  }

  Widget _buildMedicalInfoSection() {
    return _buildSection(
      title: 'المعلومات الطبية',
      icon: Icons.medical_services,
      children: [
        _buildTextFormField('الحالة الصحية', 'health_conditions', maxLines: 3),
        _buildTextFormField('رقم الهاتف', 'phone_number', keyboardType: TextInputType.phone),
        _buildTextFormField('رقم الطوارئ', 'emergency_contact_phone', keyboardType: TextInputType.phone),
        _buildTextFormField('الوصية الخاصة', 'final_will', maxLines: 4),
      ],
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, String field, {bool required = false, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _formData[field]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: required ? (value) {
          if (value == null || value.isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        } : null,
        onSaved: (value) => _formData[field] = value,
      ),
    );
  }

  Widget _buildNumberField(String label, String field) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _formData[field]?.toString() ?? '0',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onSaved: (value) => _formData[field] = int.tryParse(value ?? '0') ?? 0,
      ),
    );
  }

  Widget _buildDateField(String label, String field) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _selectDate(context, field),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formData[field]?.toString() ?? 'اختر التاريخ'),
              Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String field, List<String> items, {bool required = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _formData[field]?.toString() ?? items.first,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: OutlineInputBorder(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: required ? (value) {
          if (value == null || value.isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        } : null,
        onChanged: (value) => _formData[field] = value,
      ),
    );
  }

  Widget _buildCheckboxField(String label, String field) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Checkbox(
            value: _formData[field] ?? false,
            onChanged: (value) => setState(() => _formData[field] = value),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    
    return Row(
      children: [
        if (isMobile) Expanded(child: SizedBox()),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
            label: Text(widget.isEdit ? 'حفظ التعديلات' : 'إضافة المستنفر'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.cancel),
            label: Text('إلغاء'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (isMobile) Expanded(child: SizedBox()),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _formData[field] = picked.toString().split(' ')[0];
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // هنا سيتم إرسال البيانات للـ API
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تم الحفظ بنجاح'),
        content: Text(widget.isEdit ? 'تم تحديث بيانات المستنفر بنجاح' : 'تم إضافة المستنفر الجديد بنجاح'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }
}