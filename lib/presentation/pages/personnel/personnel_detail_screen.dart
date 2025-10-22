import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:universal_platform/universal_platform.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/services/personnel_service.dart';
import 'personnel_update_screen.dart';
import 'personnel_training_screen.dart';
import 'personnel_movements_screen.dart';
import 'personnel_equipment_screen.dart';
import 'personnel_entitlements_screen.dart';
import 'personnel_reports_screen.dart';

class PersonnelDetailScreen extends StatefulWidget {
  final int personnelId;

  const PersonnelDetailScreen({Key? key, required this.personnelId})
    : super(key: key);

  @override
  _PersonnelDetailScreenState createState() => _PersonnelDetailScreenState();
}

class _PersonnelDetailScreenState extends State<PersonnelDetailScreen> {
  Map<String, dynamic> _personnelDetails = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPersonnelDetails();
  }

  Future<void> _loadPersonnelDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // PersonnelService expects an id as String in this project; convert.
      final result = await PersonnelService.getPersonnelById(
        widget.personnelId.toString(),
      );
      setState(() {
        _personnelDetails = Map<String, dynamic>.from(result ?? {});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getField(String key) {
    final v = _personnelDetails[key];
    if (v == null) return 'غير محدد';
    return v.toString();
  }

  String _fullName() {
    final parts =
        [
              _personnelDetails['first_name'],
              _personnelDetails['second_name'],
              _personnelDetails['third_name'],
              _personnelDetails['fourth_name'],
            ]
            .where((p) => p != null && p.toString().trim().isNotEmpty)
            .map((e) => e.toString())
            .toList();
    if (parts.isEmpty) return 'غير معروف';
    return parts.join(' ');
  }

  void _editPersonnel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelUpdateScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    ).then((_) => _loadPersonnelDetails());
  }

  void _showTrainingHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelTrainingScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showMovements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelMovementsScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showEntitlements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelEntitlementsScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showEquipment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelEquipmentScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelReportsScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          textAlign: TextAlign.start,
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.grey[800],
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          alignment: Alignment.centerLeft,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsPanel() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(right: BorderSide(color: Colors.grey[300]!, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 0)),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(Icons.dashboard, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'الإجراءات السريعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),

              _buildActionButton(
                'تحديث البيانات',
                Icons.update,
                Colors.blue,
                _editPersonnel,
              ),
              _buildActionButton(
                'السجل التدريبي',
                Icons.school,
                Colors.green,
                _showTrainingHistory,
              ),
              _buildActionButton(
                'التحركات',
                Icons.directions,
                Colors.orange,
                _showMovements,
              ),
              _buildActionButton(
                'الاستحقاقات',
                Icons.attach_money,
                Colors.purple,
                _showEntitlements,
              ),
              _buildActionButton(
                'المعدات',
                Icons.security,
                Colors.red,
                _showEquipment,
              ),
              _buildActionButton(
                'التقارير',
                Icons.assessment,
                Colors.teal,
                _showReports,
              ),

              Divider(height: 30, thickness: 1),
              _buildQuickInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'الإجراءات السريعة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMobileActionButton(
                  'تحديث البيانات',
                  Icons.update,
                  Colors.blue,
                  _editPersonnel,
                ),
                _buildMobileActionButton(
                  'التدريب',
                  Icons.school,
                  Colors.green,
                  _showTrainingHistory,
                ),
                _buildMobileActionButton(
                  'التحركات',
                  Icons.directions,
                  Colors.orange,
                  _showMovements,
                ),
                _buildMobileActionButton(
                  'الاستحقاقات',
                  Icons.attach_money,
                  Colors.purple,
                  _showEntitlements,
                ),
                _buildMobileActionButton(
                  'المعدات',
                  Icons.security,
                  Colors.red,
                  _showEquipment,
                ),
                _buildMobileActionButton(
                  'التقارير',
                  Icons.assessment,
                  Colors.teal,
                  _showReports,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات سريعة',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        _buildQuickInfoItem('الحالة', _getField('status'), Colors.green),
        _buildQuickInfoItem('الرتبة', _getField('rank'), Colors.blue),
        _buildQuickInfoItem('الوحدة', _getField('unit'), Colors.orange),
        _buildQuickInfoItem('آخر تحديث', _getField('updated_at'), Colors.grey),
      ],
    );
  }

  Widget _buildQuickInfoItem(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonnelHeader() {
    final idText = widget.personnelId.toString();
    final name = _fullName();
    final status = _getField('status');
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue,
              child: Text(
                idText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'الرقم العسكري: ${_getField('military_id')}',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    'الرقم الوطني: ${_getField('national_id')}',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    'الحالة: $status',
                    style: TextStyle(
                      color: status.toLowerCase().contains('نشط')
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Chip(
                  label: Text(
                    _getField('rank'),
                    style: TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(height: 4),
                Chip(
                  label: Text(
                    _getField('unit'),
                    style: TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.green[100],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTabs() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: DefaultTabController(
          length: 5,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  isScrollable: true,
                  labelColor: Colors.blue[700],
                  unselectedLabelColor: Colors.grey[600],
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  tabs: [
                    Tab(text: 'المعلومات الأساسية'),
                    Tab(text: 'التصنيف الجغرافي'),
                    Tab(text: 'المعلومات العسكرية'),
                    Tab(text: 'المعلومات الأسرية'),
                    Tab(text: 'المعلومات الطبية'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: math.min(
                  400,
                  MediaQuery.of(context).size.height * 0.55,
                ),
                child: TabBarView(
                  children: [
                    _wrapTabWithScrollbar(_buildBasicInfoTab()),
                    _wrapTabWithScrollbar(_buildGeographicalInfoTab()),
                    _wrapTabWithScrollbar(_buildMilitaryInfoTab()),
                    _wrapTabWithScrollbar(_buildFamilyInfoTab()),
                    _wrapTabWithScrollbar(_buildMedicalInfoTab()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrapTabWithScrollbar(Widget tab) {
    return Scrollbar(thumbVisibility: true, child: tab);
  }

  Widget _buildBasicInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('الاسم الرباعي', _fullName()),
        _buildInfoRow('تاريخ الميلاد', _getField('birth_date')),
        _buildInfoRow('الجنس', _getField('gender')),
        _buildInfoRow('الحالة الاجتماعية', _getField('marital_status')),
        _buildInfoRow('المستوى التعليمي', _getField('education_level')),
        _buildInfoRow('المهنة', _getField('occupation')),
        _buildInfoRow('المهارات', _getField('skills')),
      ],
    );
  }

  Widget _buildGeographicalInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('الولاية', _getField('state')),
        _buildInfoRow('المحلية', _getField('locality')),
        _buildInfoRow('الوحدة الإدارية', _getField('administrative_unit')),
        _buildInfoRow('المدينة/القرية', _getField('city_village')),
        _buildInfoRow('السكن الحالي', _getField('current_residence')),
        _buildInfoRow('السكن قبل الحرب', _getField('prewar_residence')),
        _buildInfoRow('الموطن الأصلي', _getField('place_of_origin')),
      ],
    );
  }

  Widget _buildMilitaryInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('الرتبة', _getField('rank')),
        _buildInfoRow('الوحدة', _getField('unit')),
        _buildInfoRow('تاريخ الالتحاق', _getField('enlistment_date')),
        _buildInfoRow('الخلفية العسكرية', _getField('military_background')),
        _buildInfoRow('التدريب الأساسي', _getField('basic_training')),
        _buildInfoRow('نوع السلاح', _getField('weapon_type')),
        _buildInfoRow('تاريخ آخر تدريب', _getField('last_training_date')),
      ],
    );
  }

  Widget _buildFamilyInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('عدد الزوجات', _getField('wives_count')),
        _buildInfoRow('عدد الأبناء', _getField('children_count')),
        _buildInfoRow('عدد المعالين', _getField('dependents_count')),
        _buildInfoRow('اسم الوالدة', _getField('mother_full_name')),
        _buildInfoRow('رقم هاتف الوالدة', _getField('mother_phone')),
        _buildInfoRow('أقرب الأقربين', _getField('next_of_kin')),
        _buildInfoRow('رقم هاتف الأقربين', _getField('next_of_kin_phone')),
      ],
    );
  }

  Widget _buildMedicalInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('الحالة الصحية', _getField('health_status')),
        _buildInfoRow('الأمراض المزمنة', _getField('chronic_conditions')),
        _buildInfoRow('الحساسيات', _getField('allergies')),
        _buildInfoRow('ملاحظات طبية', _getField('medical_notes')),
        _buildInfoRow('فصيلة الدم', _getField('blood_type')),
        _buildInfoRow('رقم هاتف الطوارئ', _getField('emergency_contact_phone')),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);

    Widget bodyContent;
    if (_isLoading) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل البيانات...'),
          ],
        ),
      );
    } else if (_errorMessage.isNotEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('حدث خطأ'),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPersonnelDetails,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    } else {
      // Main content
      bodyContent = isWeb
          ? _buildWebLayout(context)
          : _buildMobileLayout(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المستنفر'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _editPersonnel),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _showComingSoonDialog('مشاركة بيانات المستنفر'),
          ),
        ],
      ),
      body: SafeArea(child: bodyContent),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActionsPanel(),
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonnelHeader(),
                      SizedBox(height: 20),
                      _buildInfoTabs(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          _buildPersonnelHeader(),
          SizedBox(height: 16),
          _buildQuickActionsGrid(),
          SizedBox(height: 16),
          _buildInfoTabs(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('قيد التطوير'),
        content: Text('ميزة $feature قيد التطوير'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }
}
