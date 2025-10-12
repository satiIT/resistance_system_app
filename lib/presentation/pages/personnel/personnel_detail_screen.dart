// lib/presentation/pages/personnel/personnel_detail_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:resistance_system_app/presentation/pages/personnel/personnel_movements_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_training_screen.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_update_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_equipment_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_entitlements_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_reports_screen.dart';

class PersonnelDetailScreen extends StatelessWidget {
  final int personnelId;

  const PersonnelDetailScreen({Key? key, required this.personnelId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المستنفر'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editPersonnel(context),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _sharePersonnel(context),
          ),
        ],
      ),
      body: SafeArea(
        child: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // لوحة التنقل السريع - Sidebar ثابت
            _buildQuickActionsPanel(context),
            // المحتوى الرئيسي مع Scroll
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonnelHeader(context),
                      SizedBox(height: 20),
                      _buildInfoTabs(context),
                      SizedBox(height: 20), // مساحة إضافية في الأسفل
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
          _buildPersonnelHeader(context),
          SizedBox(height: 16),
          _buildQuickActionsGrid(context), // شبكة أزرار سريعة للموبايل
          SizedBox(height: 16),
          _buildInfoTabs(context),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel(BuildContext context) {
    return Container(
      width: 220, // عرض ثابت للـ Sidebar
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
              // رأس الـ Sidebar
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

              // قائمة الأزرار
              _buildActionButton(
                'تحديث البيانات',
                Icons.update,
                Colors.blue,
                () => _editPersonnel(context),
              ),
              _buildActionButton(
                'السجل التدريبي',
                Icons.school,
                Colors.green,
                () => _showTrainingHistory(context),
              ),
              _buildActionButton(
                'التحركات',
                Icons.directions,
                Colors.orange,
                () => _showMovements(context),
              ),
              _buildActionButton(
                'الاستحقاقات',
                Icons.attach_money,
                Colors.purple,
                () => _showEntitlements(context),
              ),
              _buildActionButton(
                'المعدات',
                Icons.security,
                Colors.red,
                () => _showEquipment(context),
              ),
              _buildActionButton(
                'التقارير',
                Icons.assessment,
                Colors.teal,
                () => _showReports(context),
              ),

              // فاصل
              Divider(height: 30, thickness: 1),

              // معلومات سريعة
              _buildQuickInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
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
                  () => _editPersonnel(context),
                ),
                _buildMobileActionButton(
                  'التدريب',
                  Icons.school,
                  Colors.green,
                  () => _showTrainingHistory(context),
                ),
                _buildMobileActionButton(
                  'التحركات',
                  Icons.directions,
                  Colors.orange,
                  () => _showMovements(context),
                ),
                _buildMobileActionButton(
                  'الاستحقاقات',
                  Icons.attach_money,
                  Colors.purple,
                  () => _showEntitlements(context),
                ),
                _buildMobileActionButton(
                  'المعدات',
                  Icons.security,
                  Colors.red,
                  () => _showEquipment(context),
                ),
                _buildMobileActionButton(
                  'التقارير',
                  Icons.assessment,
                  Colors.teal,
                  () => _showReports(context),
                ),
              ],
            ),
          ],
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
        _buildQuickInfoItem('الحالة', 'نشط', Colors.green),
        _buildQuickInfoItem('الرتبة', 'جندي', Colors.blue),
        _buildQuickInfoItem('الوحدة', 'عهد الرجال 1', Colors.orange),
        _buildQuickInfoItem('آخر تحديث', '2024-03-20', Colors.grey),
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

  Widget _buildPersonnelHeader(BuildContext context) {
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
                '1001',
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
                    'أحمد محمد أحمد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('الرقم العسكري: 1001', style: TextStyle(fontSize: 13)),
                  Text(
                    'الرقم الوطني: 12345678901234',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    'الحالة: نشط',
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Chip(
                  label: Text('جندي', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(height: 4),
                Chip(
                  label: Text('عهد الرجال 1', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.green[100],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTabs(BuildContext context) {
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
                height: math.min(400, MediaQuery.of(context).size.height * 0.5),
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
        _buildInfoRow('الاسم الرباعي', 'أحمد محمد أحمد علي'),
        _buildInfoRow('تاريخ الميلاد', '1985-05-15'),
        _buildInfoRow('الجنس', 'ذكر'),
        _buildInfoRow('الحالة الاجتماعية', 'متزوج'),
        _buildInfoRow('المستوى التعليمي', 'جامعي'),
        _buildInfoRow('المهنة', 'مهندس'),
        _buildInfoRow('المهارات', 'قيادة، اتصالات، إسعافات أولية'),
      ],
    );
  }

  Widget _buildGeographicalInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('الولاية', 'ولاية الخرطوم'),
        _buildInfoRow('المحلية', 'محلية شرق النيل'),
        _buildInfoRow('الوحدة الإدارية', 'الوحدة الإدارية 1'),
        _buildInfoRow('المدينة/القرية', 'الخرطوم'),
        _buildInfoRow('السكن الحالي', 'حي الصحافة'),
        _buildInfoRow('السكن قبل الحرب', 'حي الرياض'),
        _buildInfoRow('الموطن الأصلي', 'الخرطوم'),
      ],
    );
  }

  Widget _buildMilitaryInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('الرتبة', 'جندي'),
        _buildInfoRow('الوحدة', 'عهد الرجال 1'),
        _buildInfoRow('تاريخ الالتحاق', '2024-01-01'),
        _buildInfoRow('الخلفية العسكرية', 'نعم'),
        _buildInfoRow('التدريب الأساسي', 'مكتمل'),
        _buildInfoRow('نوع السلاح', 'AK-47'),
        _buildInfoRow('تاريخ آخر تدريب', '2024-02-15'),
      ],
    );
  }

  Widget _buildFamilyInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('عدد الزوجات', '1'),
        _buildInfoRow('عدد الأبناء', '3'),
        _buildInfoRow('عدد المعالين', '2'),
        _buildInfoRow('اسم الوالدة', 'فاطمة أحمد'),
        _buildInfoRow('رقم هاتف الوالدة', '0912345678'),
        _buildInfoRow('أقرب الأقربين', 'محمد أحمد - أخ'),
        _buildInfoRow('رقم هاتف الأقربين', '0918765432'),
      ],
    );
  }

  Widget _buildMedicalInfoTab() {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        _buildInfoRow('الحالة الصحية', 'جيدة'),
        _buildInfoRow('الأمراض المزمنة', 'لا يوجد'),
        _buildInfoRow('الحساسيات', 'لا يوجد'),
        _buildInfoRow('ملاحظات طبية', 'لا يوجد'),
        _buildInfoRow('فصيلة الدم', 'O+'),
        _buildInfoRow('رقم هاتف الطوارئ', '0918765432'),
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

  // navigatorKey removed; use local BuildContext passed into methods instead

  void _editPersonnel(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelUpdateScreen(
          personnelId: personnelId,
          personnelName: 'أحمد محمد أحمد',
        ),
      ),
    );
  }

  void _sharePersonnel(BuildContext context) {
    _showComingSoonDialog(context, 'مشاركة بيانات المستنفر');
  }

  void _showTrainingHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelTrainingScreen(
          personnelId: personnelId,
          personnelName: 'أحمد محمد أحمد',
        ),
      ),
    );
  }

  void _showMovements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelMovementsScreen(
          personnelId: personnelId,
          personnelName: 'أحمد محمد أحمد',
        ),
      ),
    );
  }

  void _showEntitlements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelEntitlementsScreen(
          personnelId: personnelId,
          personnelName: 'أحمد محمد أحمد',
        ),
      ),
    );
  }

  void _showEquipment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelEquipmentScreen(
          personnelId: personnelId,
          personnelName: 'أحمد محمد أحمد',
        ),
      ),
    );
  }

  void _showReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelReportsScreen(
          personnelId: personnelId,
          personnelName: 'أحمد محمد أحمد',
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
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
