// lib/presentation/pages/main_dashboard.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/presentation/pages/casualties/casualties_screen.dart';
import 'package:resistance_system_app/presentation/pages/finance/finance_screen.dart';
import 'package:resistance_system_app/presentation/pages/inventory/inventory_screen.dart';
import 'package:resistance_system_app/presentation/pages/medicine/medicine_screen.dart';
import 'package:resistance_system_app/presentation/pages/movements/dashboard_movements_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_list_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_training_screen.dart';
import './../pages/training/personnel_training_screen.dart' as dashTraining;
import 'package:universal_platform/universal_platform.dart';
import '../../core/responsive/responsive_layout.dart';
//import '../../core/theme/app_theme.dart';

class MainDashboard extends StatelessWidget {
  final List<DashboardItem> menuItems = [
    DashboardItem('المستنفرين', Icons.people, Colors.blue, 'إدارة المستنفرين والموارد البشرية'),
    DashboardItem('التدريب', Icons.school, Colors.green, 'برامج التدريب والتسليح'),
    DashboardItem('التحركات', Icons.directions, Colors.orange, 'إدارة التحركات والمهام'),
    DashboardItem('الجرحى والشهداء', Icons.medical_services, Colors.red, 'السجلات الطبية والتعويضات'),
    DashboardItem('المخازن', Icons.inventory, Colors.purple, 'إدارة المخازن والمواد'),
    DashboardItem('الصيدلية', Icons.medication, Colors.teal, 'إدارة الأدوية والمستلزمات'),
    DashboardItem('المالية', Icons.attach_money, Colors.green, 'الإدارة المالية والمحاسبية'),
    DashboardItem('التقارير', Icons.assessment, Colors.indigo, 'التقارير والإحصائيات'),
    DashboardItem('الاستخبارات', Icons.security, Colors.red, 'نظام التقارير الاستخباراتية'),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: _buildAppBar(isWeb),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
      drawer: isMobile ? _buildDrawer(context) : null,
    );
  }

  AppBar _buildAppBar(bool isWeb) {
    return AppBar(
      title: Text('اللوحة الرئيسية'),
      centerTitle: true,
      actions: [
        if (isWeb) ..._buildWebAppBarActions(),
        IconButton(icon: Icon(Icons.notifications), onPressed: _showNotifications),
        IconButton(icon: Icon(Icons.logout), onPressed: _logout),
      ],
    );
  }

  List<Widget> _buildWebAppBarActions() {
    return [
      IconButton(icon: Icon(Icons.refresh), onPressed: _refreshData),
      IconButton(icon: Icon(Icons.help), onPressed: _showHelp),
    ];
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        _buildWebSidebar(context),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWebHeader(context),
                SizedBox(height: 24),
                _buildQuickStats(context),
                SizedBox(height: 32),
                Expanded(
                  child: _buildWebGrid(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSidebar(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(height: 10),
                Text(
                  'مدير النظام',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'admin@resistance.com',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildSidebarItem(menuItems[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(DashboardItem item, BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: item.color),
      title: Text(item.title),
      subtitle: Text(item.description, style: TextStyle(fontSize: 12)),
      onTap: () => _navigateToScreen(item.title, context),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً بك في نظام الإدارة',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.dashboard),
          label: Text('لوحة التحكم'),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('المستنفرين', '1,247', Icons.people, Colors.blue),
            _buildStatItem('نشط', '892', Icons.check_circle, Colors.green),
            _buildStatItem('تقارير اليوم', '23', Icons.assessment, Colors.orange),
            _buildStatItem('إنذارات', '5', Icons.warning, Colors.red),
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
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildWebGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _buildDashboardCard(menuItems[index], context);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMobileHeader(context),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildDashboardCard(menuItems[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مدير النظام', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('مرحباً بعودتك', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.refresh), onPressed: _refreshData),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(DashboardItem item, BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToScreen(item.title, context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, 
                size: isWeb ? 40 : 32, 
                color: item.color
              ),
              SizedBox(height: isWeb ? 12 : 8),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: isWeb ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (isWeb) ...[
                SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(height: 10),
                Text(
                  'مدير النظام',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'admin@resistance.com',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ...menuItems.map((item) => ListTile(
            leading: Icon(item.icon, color: item.color),
            title: Text(item.title),
            onTap: () => _navigateToScreen(item.title, context),
          )).toList(),
        ],
      ),
    );
  }

  // في main_dashboard.dart - تحديث دالة _navigateToScreen:
void _navigateToScreen(String title, BuildContext context) {
  switch (title) {
    case 'المستنفرين':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) => PersonnelListScreen()));
      break;
    case 'التحركات':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) => DashboardMovementsScreen()));
      break;
     case 'التدريب':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) =>  dashTraining.PersonnelTrainingScreen()));
      break;
      case 'الجرحى والشهداء':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) => CasualtiesScreen()));    
      break;
    case 'المخازن':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) => InventoryScreen()));    
      break;
      case 'الصيدلية':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) => MedicineScreen()));  
      break;
    
    case 'المالية':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) => FinanceScreen()));
      break;
      /*
    case 'التقارير':
      Navigator.push(context, 
        MaterialPageRoute(builder: (_) => ReportsScreen()));
      break;*/
    default:
       showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('قيد التطوير'),
        content: Text('شاشة $title قيد التطوير'),
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

  void _refreshData() {
    // تجديد البيانات
  }

  void _showNotifications() {
    // عرض الإشعارات
  }

  void _showHelp() {
    // عرض المساعدة
  }

  void _logout() {
    // تسجيل الخروج
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final String description;

  DashboardItem(this.title, this.icon, this.color, this.description, [this.route = '']);
}