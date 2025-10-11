// lib/presentation/pages/personnel/personnel_update_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelUpdateScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelUpdateScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelUpdateScreenState createState() => _PersonnelUpdateScreenState();
}

class _PersonnelUpdateScreenState extends State<PersonnelUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _personnelData = {};

  @override
  void initState() {
    super.initState();
    _loadPersonnelData();
  }

  void _loadPersonnelData() {
    // بيانات وهمية - سيتم استبدالها بالبيانات الحقيقية من API
    setState(() {
      _personnelData = {
        'id': widget.personnelId,
        'name': widget.personnelName,
        'military_id': '1001',
        'national_id': '12345678901234',
        'rank': 'جندي',
        'unit': 'عهد الرجال 1',
        'state': 'ولاية الخرطوم',
        'locality': 'محلية شرق النيل',
        'status': 'نشط',
        'phone': '0912345678',
        'emergency_contact': '0918765432',
        'health_status': 'جيدة',
        'weapon_type': 'AK-47',
        'ammunition_count': 120,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('تحديث بيانات - ${widget.personnelName}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveUpdates,
          ),
        ],
      ),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildQuickStats(),
          SizedBox(height: 24),
          _buildUpdateForm(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'المعلومات الأساسية'),
                Tab(text: 'المعلومات العسكرية'),
                Tab(text: 'التصنيف الجغرافي'),
                Tab(text: 'المعلومات الطبية'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBasicInfoForm(),
                _buildMilitaryInfoForm(),
                _buildGeographicalInfoForm(),
                _buildMedicalInfoForm(),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('الحالة', _personnelData['status'] ?? 'غير محدد', Icons.person, Colors.blue),
            _buildStatItem('الرتبة', _personnelData['rank'] ?? 'غير محدد', Icons.security, Colors.green),
            _buildStatItem('الوحدة', _personnelData['unit'] ?? 'غير محدد', Icons.group, Colors.orange),
            _buildStatItem('السلاح', _personnelData['weapon_type'] ?? 'غير محدد', Icons.settings, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUpdateForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('تحديث المعلومات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormField('الحالة', 'status', ['نشط', 'غير نشط', 'مريض', 'إجازة']),
                  _buildFormField('الرتبة', 'rank', ['جندي', 'عريف', 'رقيب', 'مساعد', 'ملازم']),
                  _buildFormField('الوحدة', 'unit', ['عهد الرجال 1', 'عهد الرجال 2', 'عهد الرجال 3']),
                  _buildFormField('نوع السلاح', 'weapon_type', ['AK-47', 'قناصة', 'رشاش', 'مسدس']),
                  _buildNumberField('كمية الذخيرة', 'ammunition_count'),
                  _buildTextFormField('رقم الهاتف', 'phone', TextInputType.phone),
                  _buildTextFormField('رقم الطوارئ', 'emergency_contact', TextInputType.phone),
                  _buildFormField('الحالة الصحية', 'health_status', ['جيدة', 'متوسطة', 'سيئة', 'بحاجة رعاية']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextFormField('رقم الهاتف', 'phone', TextInputType.phone),
            _buildTextFormField('رقم الطوارئ', 'emergency_contact', TextInputType.phone),
            _buildFormField('الحالة الاجتماعية', 'marital_status', ['أعزب', 'متزوج', 'مطلق', 'أرمل']),
          ],
        ),
      ),
    );
  }

  Widget _buildMilitaryInfoForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormField('الحالة', 'status', ['نشط', 'غير نشط', 'مريض', 'إجازة']),
          _buildFormField('الرتبة', 'rank', ['جندي', 'عريف', 'رقيب', 'مساعد', 'ملازم']),
          _buildFormField('الوحدة', 'unit', ['عهد الرجال 1', 'عهد الرجال 2', 'عهد الرجال 3']),
          _buildFormField('نوع السلاح', 'weapon_type', ['AK-47', 'قناصة', 'رشاش', 'مسدس']),
          _buildNumberField('كمية الذخيرة', 'ammunition_count'),
        ],
      ),
    );
  }

  Widget _buildGeographicalInfoForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormField('الولاية', 'state', ['ولاية الخرطوم', 'ولاية الجزيرة', 'ولاية كردفان']),
          _buildFormField('المحلية', 'locality', ['محلية شرق النيل', 'محلية غرب النيل', 'محلية الخرطوم']),
          _buildTextFormField('الوحدة الإدارية', 'administrative_unit', TextInputType.text),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormField('الحالة الصحية', 'health_status', ['جيدة', 'متوسطة', 'سيئة', 'بحاجة رعاية']),
          _buildTextFormField('الأمراض المزمنة', 'chronic_diseases', TextInputType.text),
          _buildTextFormField('الحساسيات', 'allergies', TextInputType.text),
          _buildTextFormField('ملاحظات طبية', 'medical_notes', TextInputType.multiline),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String field, List<String> options) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _personnelData[field] ?? options.first,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _personnelData[field] = value;
          });
        },
      ),
    );
  }

  Widget _buildTextFormField(String label, String field, TextInputType keyboardType, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _personnelData[field]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (value) {
          setState(() {
            _personnelData[field] = value;
          });
        },
      ),
    );
  }

  Widget _buildNumberField(String label, String field) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _personnelData[field]?.toString() ?? '0',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _personnelData[field] = int.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveUpdates,
              icon: Icon(Icons.save),
              label: Text('حفظ التغييرات'),
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
        ],
      ),
    );
  }

  void _saveUpdates() {
    if (_formKey.currentState?.validate() ?? false) {
      // هنا سيتم حفظ البيانات في API
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تم التحديث بنجاح'),
        content: Text('تم تحديث بيانات ${widget.personnelName} بنجاح'),
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