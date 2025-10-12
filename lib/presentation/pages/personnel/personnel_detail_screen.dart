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

  const PersonnelDetailScreen({Key? key, required this.personnelId}) : super(key: key);

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
          IconButton(icon: Icon(Icons.edit), onPressed: () => _editPersonnel(context)),
          IconButton(icon: Icon(Icons.share), onPressed: () => _sharePersonnel(context)),
        ],
      ),
      body: SafeArea(child: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context)),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // لوحة التنقل السريع
        _buildQuickActionsPanel(context),
        // المحتوى الرئيسي
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                _buildPersonnelHeader(context),
                SizedBox(height: 24),
                _buildInfoTabs(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPersonnelHeader(context),
          SizedBox(height: 20),
          _buildInfoTabs(context),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionButton('السجل التدريبي', Icons.school, () => _showTrainingHistory(context)),
            _buildActionButton('التحركات', Icons.directions, () => _showMovements(context)),
            _buildActionButton('الاستحقاقات', Icons.attach_money, () => _showEntitlements(context)),
            _buildActionButton('المعدات', Icons.security, () => _showEquipment(context)),
            _buildActionButton('التقارير', Icons.assessment, () => _showReports(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(title, style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildPersonnelHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                '1001',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أحمد محمد أحمد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('الرقم العسكري: 1001'),
                  Text('الرقم الوطني: 12345678901234'),
                  Text('الحالة: نشط', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            Column(
              children: [
                Chip(label: Text('جندي'), backgroundColor: Colors.blue[100]),
                Chip(label: Text('عهد الرجال 1'), backgroundColor: Colors.green[100]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTabs(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'المعلومات الأساسية'),
              Tab(text: 'التصنيف الجغرافي'),
              Tab(text: 'المعلومات العسكرية'),
              Tab(text: 'المعلومات الأسرية'),
              Tab(text: 'المعلومات الطبية'),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: math.min(400, MediaQuery.of(context).size.height * 0.6),
            child: TabBarView(
              children: [
                _buildBasicInfoTab(),
                _buildGeographicalInfoTab(),
                _buildMilitaryInfoTab(),
                _buildFamilyInfoTab(),
                _buildMedicalInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return ListView(
      children: [
        _buildInfoRow('الاسم الرباعي', 'أحمد محمد أحمد علي'),
        _buildInfoRow('تاريخ الميلاد', '1985-05-15'),
        _buildInfoRow('الجنس', 'ذكر'),
        _buildInfoRow('الحالة الاجتماعية', 'متزوج'),
        _buildInfoRow('المستوى التعليمي', 'جامعي'),
        _buildInfoRow('المهنة', 'مهندس'),
      ],
    );
  }

  Widget _buildGeographicalInfoTab() {
    return ListView(
      children: [
        _buildInfoRow('الولاية', 'ولاية الخرطوم'),
        _buildInfoRow('المحلية', 'محلية شرق النيل'),
        _buildInfoRow('الوحدة الإدارية', 'الوحدة الإدارية 1'),
        _buildInfoRow('المدينة/القرية', 'الخرطوم'),
        _buildInfoRow('السكن الحالي', 'حي الصحافة'),
        _buildInfoRow('السكن قبل الحرب', 'حي الرياض'),
      ],
    );
  }

  Widget _buildMilitaryInfoTab() {
    return ListView(
      children: [
        _buildInfoRow('الرتبة', 'جندي'),
        _buildInfoRow('الوحدة', 'عهد الرجال 1'),
        _buildInfoRow('تاريخ الالتحاق', '2024-01-01'),
        _buildInfoRow('الخلفية العسكرية', 'نعم'),
        _buildInfoRow('التدريب الأساسي', 'مكتمل'),
        _buildInfoRow('نوع السلاح', 'AK-47'),
      ],
    );
  }

  Widget _buildFamilyInfoTab() {
    return ListView(
      children: [
        _buildInfoRow('عدد الزوجات', '1'),
        _buildInfoRow('عدد الأبناء', '3'),
        _buildInfoRow('عدد المعالين', '2'),
        _buildInfoRow('اسم الوالدة', 'فاطمة أحمد'),
        _buildInfoRow('أقرب الأقربين', 'محمد أحمد - أخ'),
      ],
    );
  }

  Widget _buildMedicalInfoTab() {
    return ListView(
      children: [
        _buildInfoRow('الحالة الصحية', 'جيدة'),
        _buildInfoRow('الأمراض المزمنة', 'لا يوجد'),
        _buildInfoRow('الحساسيات', 'لا يوجد'),
        _buildInfoRow('ملاحظات طبية', 'لا يوجد'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _editPersonnel(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => PersonnelUpdateScreen(personnelId: personnelId, personnelName: 'احمد محمد احمد',))
    );
    }

  void _sharePersonnel(BuildContext context) {
    _showComingSoonDialog(context, 'مشاركة بيانات المستنفر');
  }

  // ignore: unused_element
  void _showTrainingHistory(BuildContext context) {
     Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => PersonnelTrainingScreen(personnelId: personnelId, personnelName: 'احمد محمد أحمد'))
  );
  }

  void _showMovements(BuildContext context) {
     Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (_) => PersonnelMovementsScreen(
        personnelId: personnelId, 
        personnelName: 'أحمد محمد أحمد'
      )
    )
  );
  }

  void _showEntitlements(BuildContext context) {
 Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (_) => PersonnelEntitlementsScreen(
        personnelId: personnelId, 
        personnelName: 'أحمد محمد أحمد'
      )
    )
  );  }

  void _showEquipment(BuildContext context) {
  Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (_) => PersonnelEquipmentScreen(
        personnelId: personnelId, 
        personnelName: 'أحمد محمد أحمد'
      )
    )
  );  }

  void _showReports(BuildContext context) {
 Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (_) => PersonnelReportsScreen(
        personnelId: personnelId, 
        personnelName: 'أحمد محمد أحمد'
      )
    )
  );  }

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