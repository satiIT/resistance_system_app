// lib/presentation/pages/personnel/personnel_list_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_detail_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_form_screen.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المستنفرين'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToAddPersonnel(context),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // الشريط الجانبي للتصفية
        _buildFilterSidebar(context),
        // القائمة الرئيسية
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(context),
                SizedBox(height: 16),
                Expanded(
                  child: _buildPersonnelGrid(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchBar(context),
          SizedBox(height: 16),
          Expanded(
            child: _buildPersonnelList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSidebar(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    
    return Container(
      width: isMobile ? 200 : 250,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('التصنيف الجغرافي', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildFilterItem('الولاية', ['كل الولايات', 'ولاية 1', 'ولاية 2']),
            _buildFilterItem('المحلية', ['كل المحليات', 'محلية 1', 'محلية 2']),
            _buildFilterItem('الحالة', ['جميع', 'نشط', 'غير نشط']),
            _buildFilterItem('الرتبة', ['جميع', 'جندي', 'عريف', 'رقيب']),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: options.first,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (newValue) {},
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو الرقم العسكري...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelGrid(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    
    // بيانات وهمية للعرض
    List<Map<String, dynamic>> personnelData = [
      {
        'id': 1001,
        'name': 'أحمد محمد أحمد',
        'militaryId': '1001',
        'state': 'ولاية الخرطوم',
        'locality': 'محلية شرق النيل',
        'status': 'نشط',
        'rank': 'جندي',
        'unit': 'عهد الرجال 1'
      },
      // ... يمكن إضافة المزيد من البيانات الوهمية
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 1.8,
      ),
      itemCount: personnelData.length,
      itemBuilder: (context, index) {
        return _buildPersonnelCard(personnelData[index], context);
      },
    );
  }

  Widget _buildPersonnelList(BuildContext context) {
    // بيانات وهمية
    List<Map<String, dynamic>> personnelData = [
      {
        'id': 1001,
        'name': 'أحمد محمد أحمد',
        'militaryId': '1001',
        'state': 'ولاية الخرطوم',
        'status': 'نشط'
      },
      // ... بيانات إضافية
    ];

    return ListView.builder(
      itemCount: personnelData.length,
      itemBuilder: (context, index) {
        return _buildPersonnelListItem(personnelData[index], context);
      },
    );
  }

  Widget _buildPersonnelCard(Map<String, dynamic> personnel, BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToPersonnelDetail(context, personnel['id']),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    personnel['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: personnel['status'] == 'نشط' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      personnel['status'],
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text('الرقم العسكري: ${personnel['militaryId']}'),
              Text('الولاية: ${personnel['state']}'),
              Text('المحلية: ${personnel['locality']}'),
              Text('الرتبة: ${personnel['rank']}'),
              Text('الوحدة: ${personnel['unit']}'),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToPersonnelDetail(context, personnel['id']),
                      child: Text('عرض التفاصيل'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonnelListItem(Map<String, dynamic> personnel, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            personnel['militaryId'],
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(personnel['name']),
        subtitle: Text('${personnel['state']} - ${personnel['status']}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => _navigateToPersonnelDetail(context, personnel['id']),
      ),
    );
  }

  void _navigateToAddPersonnel(BuildContext context) {
    Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => PersonnelFormScreen())
  );
  }

  void _navigateToPersonnelDetail(BuildContext context, int personnelId) {
    Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => PersonnelDetailScreen(personnelId: personnelId))
  );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('بحث متقدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'الاسم')),
            TextField(decoration: InputDecoration(labelText: 'الرقم العسكري')),
            TextField(decoration: InputDecoration(labelText: 'الرقم الوطني')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية النتائج'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterItem('الولاية', ['كل الولايات', 'ولاية 1', 'ولاية 2']),
              _buildFilterItem('المحلية', ['كل المحليات', 'محلية 1', 'محلية 2']),
              _buildFilterItem('الحالة', ['جميع', 'نشط', 'غير نشط']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
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