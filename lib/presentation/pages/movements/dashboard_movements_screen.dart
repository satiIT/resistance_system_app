// lib/presentation/pages/dashboard/dashboard_movements_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:resistance_system_app/presentation/pages/movements/bulk_assignment_screen.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/responsive/responsive_layout.dart';

// نموذج بيانات للرسوم البيانية
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}

class DashboardMovementsScreen extends StatefulWidget {
  const DashboardMovementsScreen({Key? key}) : super(key: key);

  @override
  _DashboardMovementsScreenState createState() =>
      _DashboardMovementsScreenState();
}

class _DashboardMovementsScreenState extends State<DashboardMovementsScreen> {
  // البيانات الوهمية للإحصائيات
  final Map<String, dynamic> _statsData = {
    'total_movements': 156,
    'today_movements': 12,
    'pending_movements': 23,
    'completed_movements': 133,
    'movements_by_type': {'مهمة': 45, 'نقل': 38, 'توزيع': 52, 'إجازة': 21},
    'movements_by_status': {'مكتمل': 133, 'قيد التنفيذ': 23, 'ملغى': 5},
    'recent_movements': [
      {
        'id': 1,
        'personnel_name': 'أحمد محمد أحمد',
        'movement_type': 'نقل',
        'from_unit': 'عهد الرجال 1',
        'to_unit': 'أسود العرين',
        'date': '2024-03-20',
        'status': 'مكتمل',
      },
      {
        'id': 2,
        'personnel_name': 'محمد سعيد علي',
        'movement_type': 'مهمة',
        'from_unit': 'عهد الرجال 2',
        'to_unit': 'المنطقة الشمالية',
        'date': '2024-03-19',
        'status': 'قيد التنفيذ',
      },
      {
        'id': 3,
        'personnel_name': 'عمر حسن محمد',
        'movement_type': 'توزيع',
        'from_unit': 'مركز التدريب',
        'to_unit': 'عهد الرجال 3',
        'date': '2024-03-18',
        'status': 'مكتمل',
      },
      {
        'id': 4,
        'personnel_name': 'خالد عبد الله',
        'movement_type': 'إجازة',
        'from_unit': 'عهد الرجال 1',
        'to_unit': 'منزل',
        'date': '2024-03-17',
        'status': 'مكتمل',
      },
    ],
    'geographical_distribution': [
      {'region': 'الخرطوم', 'count': 45},
      {'region': 'أم درمان', 'count': 32},
      {'region': 'بحري', 'count': 28},
      {'region': 'شرق النيل', 'count': 25},
      {'region': 'غرب النيل', 'count': 26},
    ],
  };

  // ignore: unused_field
  String _selectedFilter = 'اليوم';
  String _selectedChartType = 'نوع التحرك';

  // دالة لتحويل البيانات للرسوم البيانية
  List<ChartData> _getChartData(Map<String, int> dataMap) {
    return dataMap.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  List<ChartData> _getGeographicalData() {
    return _statsData['geographical_distribution'].map<ChartData>((item) {
      return ChartData(item['region'], item['count']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم التحركات'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'اليوم', child: Text('اليوم')),
              PopupMenuItem(value: 'أسبوع', child: Text('الأسبوع')),
              PopupMenuItem(value: 'شهر', child: Text('الشهر')),
              PopupMenuItem(value: 'كل', child: Text('الكل')),
            ],
            icon: Icon(Icons.filter_list),
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return isWeb ? _buildWebLayout(constraints) : _buildMobileLayout(constraints);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToBulkAssignment(context),
        icon: Icon(Icons.group_add),
        label: Text('إسناد جماعي'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildWebLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(),
              SizedBox(height: 24),
              _buildChartsSection(constraints),
              SizedBox(height: 24),
              _buildDistributionMap(),
              SizedBox(height: 24),
              _buildQuickReports(),
              SizedBox(height: 80), // مساحة للزر العائم
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              _buildStatsGrid(),
              SizedBox(height: 16),
              _buildMovementsChart(),
              SizedBox(height: 16),
              _buildGeographicalChart(),
              SizedBox(height: 16),
              _buildRecentMovementsPanel(),
              SizedBox(height: 16),
              _buildQuickReports(),
              SizedBox(height: 80), // مساحة للزر العائم
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsSection(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: constraints.maxHeight * 0.6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildMovementsChart(),
                SizedBox(height: 16),
                _buildGeographicalChart(),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildRecentMovementsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            'إجمالي التحركات',
            _statsData['total_movements'].toString(),
            Icons.directions,
            Colors.blue,
            Icons.trending_up,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'تحركات اليوم',
            _statsData['today_movements'].toString(),
            Icons.today,
            Colors.green,
            Icons.update,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'قيد التنفيذ',
            _statsData['pending_movements'].toString(),
            Icons.schedule,
            Colors.orange,
            Icons.access_time,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'مكتملة',
            _statsData['completed_movements'].toString(),
            Icons.check_circle,
            Colors.green,
            Icons.done_all,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'إجمالي التحركات',
          _statsData['total_movements'].toString(),
          Icons.directions,
          Colors.blue,
          Icons.trending_up,
        ),
        _buildStatCard(
          'تحركات اليوم',
          _statsData['today_movements'].toString(),
          Icons.today,
          Colors.green,
          Icons.update,
        ),
        _buildStatCard(
          'قيد التنفيذ',
          _statsData['pending_movements'].toString(),
          Icons.schedule,
          Colors.orange,
          Icons.access_time,
        ),
        _buildStatCard(
          'مكتملة',
          _statsData['completed_movements'].toString(),
          Icons.check_circle,
          Colors.green,
          Icons.done_all,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    IconData trendIcon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(trendIcon, color: Colors.green, size: 16),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementsChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'توزيع التحركات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedChartType,
                  items: ['نوع التحرك', 'حالة التحرك']
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue == null) return;
                    setState(() {
                      _selectedChartType = newValue;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              height: 250,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedChartType) {
      case 'نوع التحرك':
        return SfCircularChart(
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: _getChartData(_statsData['movements_by_type']),
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        );
      case 'حالة التحرك':
        return SfCircularChart(
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CircularSeries>[
            PieSeries<ChartData, String>(
              dataSource: _getChartData(_statsData['movements_by_status']),
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        );
      default:
        return Container(
          child: Center(child: Text('لا توجد بيانات')),
        );
    }
  }

  Widget _buildGeographicalChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'التوزيع الجغرافي',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(minimum: 0),
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: _getGeographicalData(),
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMovementsPanel() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آخر التحركات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _viewAllMovements(context),
                  child: Text('عرض الكل'),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: _statsData['recent_movements'].length,
                itemBuilder: (context, index) {
                  final movement = _statsData['recent_movements'][index];
                  return _buildMovementListItem(movement, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementListItem(
    Map<String, dynamic> movement,
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getMovementIcon(movement['movement_type']),
        title: Text(
          movement['personnel_name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${movement['movement_type']} - ${movement['date']}', style: TextStyle(fontSize: 12)),
            Text('من ${movement['from_unit']} إلى ${movement['to_unit']}', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Chip(
          label: Text(
            movement['status'],
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          backgroundColor: movement['status'] == 'مكتمل'
              ? Colors.green
              : Colors.orange,
        ),
        onTap: () => _viewMovementDetails(context, movement),
      ),
    );
  }

  Widget _buildDistributionMap() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خريطة التوزيع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'خريطة التوزيع الجغرافي',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'سيتم دمج الخرائط عند توصيل بيانات GPS',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showMapInfo(context),
                      icon: Icon(Icons.info, size: 16),
                      label: Text('معلومات الخريطة', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReports() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقارير السريعة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReportChip(
                  'تقرير التحركات اليومية',
                  Icons.today,
                  Colors.blue,
                  () => _generateReport('daily'),
                ),
                _buildReportChip(
                  'تقرير التحركات الأسبوعية',
                  Icons.calendar_view_week,
                  Colors.green,
                  () => _generateReport('weekly'),
                ),
                _buildReportChip(
                  'تقرير التوزيع الجغرافي',
                  Icons.map,
                  Colors.orange,
                  () => _generateReport('geographical'),
                ),
                _buildReportChip(
                  'تقرير المهام النشطة',
                  Icons.assignment,
                  Colors.purple,
                  () => _generateReport('active'),
                ),
                _buildReportChip(
                  'تقرير الإنجازات',
                  Icons.assessment,
                  Colors.teal,
                  () => _generateReport('achievements'),
                ),
                _buildReportChip(
                  'تصدير البيانات',
                  Icons.download,
                  Colors.red,
                  () => _exportData(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportChip(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 6),
            Text(title, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Icon _getMovementIcon(String movementType) {
    switch (movementType) {
      case 'مهمة':
        return Icon(Icons.assignment, color: Colors.blue, size: 20);
      case 'نقل':
        return Icon(Icons.swap_horiz, color: Colors.green, size: 20);
      case 'توزيع':
        return Icon(Icons.group, color: Colors.orange, size: 20);
      case 'إجازة':
        return Icon(Icons.beach_access, color: Colors.purple, size: 20);
      default:
        return Icon(Icons.directions, color: Colors.grey, size: 20);
    }
  }

  void _refreshData() {
    setState(() {
      _showSuccessMessage('تم تحديث البيانات بنجاح');
    });
  }

  void _navigateToBulkAssignment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BulkAssignmentScreen()),
    );
  }

  void _viewAllMovements(BuildContext context) {
    _showComingSoonDialog(context, 'شاشة جميع التحركات');
  }

  void _viewMovementDetails(
    BuildContext context,
    Map<String, dynamic> movement,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل التحرك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المستنفر: ${movement['personnel_name']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('نوع التحرك: ${movement['movement_type']}'),
            Text('من: ${movement['from_unit']}'),
            Text('إلى: ${movement['to_unit']}'),
            Text('التاريخ: ${movement['date']}'),
            Text('الحالة: ${movement['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showMapInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('معلومات الخريطة'),
        content: Text(
          'سيتم دمج الخرائط الحقيقية مع بيانات GPS عند توفرها. حالياً نستخدم بيانات وهمية للعرض.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _generateReport(String reportType) {
    String reportName = '';
    switch (reportType) {
      case 'daily':
        reportName = 'تقرير التحركات اليومية';
        break;
      case 'weekly':
        reportName = 'تقرير التحركات الأسبوعية';
        break;
      case 'geographical':
        reportName = 'تقرير التوزيع الجغرافي';
        break;
      case 'active':
        reportName = 'تقرير المهام النشطة';
        break;
      case 'achievements':
        reportName = 'تقرير الإنجازات';
        break;
    }

    _showSuccessMessage('جارٍ إنشاء $reportName...');
  }

  void _exportData() {
    _showSuccessMessage('جارٍ تصدير البيانات...');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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