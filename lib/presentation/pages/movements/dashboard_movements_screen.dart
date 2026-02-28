// lib/presentation/pages/dashboard/dashboard_movements_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:resistance_system_app/presentation/pages/movements/bulk_assignment_screen.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/services/personnel_service.dart';
import '../../../core/services/movements_service.dart';

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
  // البيانات الحقيقية من API
  Map<String, dynamic> _statsData = {
    'total_movements': 0,
    'today_movements': 0,
    'pending_movements': 0,
    'completed_movements': 0,
    'movements_by_type': {},
    'movements_by_status': {},
    'recent_movements': [],
    'geographical_distribution': [],
  };

  List<Map<String, dynamic>> _allMovements = [];
  bool _isLoading = true;
  String _selectedFilter = 'اليوم';
  String _selectedChartType = 'نوع التحرك';

  @override
  void initState() {
    super.initState();
    _loadMovementsData();
  }

  // في ملف dashboard_movements_screen.dart - استبدال دالة _loadMovementsData
  Future<void> _loadMovementsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await MovementsService.getAllMovements();

      if (response['success'] == true) {
        final movements = List<Map<String, dynamic>>.from(
          response['data'] ?? [],
        );
        _allMovements = movements;
        _calculateStatistics(movements);
        print('✅ تم تحميل ${movements.length} حركة من API');
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب البيانات');
      }
    } catch (e) {
      print('❌ خطأ في تحميل البيانات من API: $e');
      _showError('فشل في تحميل البيانات: $e');

      // استخدام بيانات وهمية كبديل فقط للعرض
      _calculateStatistics(_getMockMovementsData());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // بيانات وهمية للتحركات (ستستبدل بالبيانات الحقيقية من API)
  List<Map<String, dynamic>> _getMockMovementsData() {
    return [
      {
        'id': 1,
        'personnel_name': 'أحمد محمد أحمد',
        'movement_type': 'نقل',
        'from_location': 'عهد الرجال 1',
        'to_location': 'أسود العرين',
        'movement_date': '2024-03-20',
        'status': 'مكتمل',
      },
      {
        'id': 2,
        'personnel_name': 'محمد سعيد علي',
        'movement_type': 'مهمة',
        'from_location': 'عهد الرجال 2',
        'to_location': 'المنطقة الشمالية',
        'movement_date': '2024-03-19',
        'status': 'قيد التنفيذ',
      },
      {
        'id': 3,
        'personnel_name': 'عمر حسن محمد',
        'movement_type': 'توزيع',
        'from_location': 'مركز التدريب',
        'to_location': 'عهد الرجال 3',
        'movement_date': '2024-03-18',
        'status': 'مكتمل',
      },
      {
        'id': 4,
        'personnel_name': 'خالد عبد الله',
        'movement_type': 'إجازة',
        'from_location': 'عهد الرجال 1',
        'to_location': 'منزل',
        'movement_date': '2024-03-17',
        'status': 'مكتمل',
      },
      {
        'id': 5,
        'personnel_name': 'سالم علي أحمد',
        'movement_type': 'مهمة',
        'from_location': 'أسود العرين',
        'to_location': 'المنطقة الجنوبية',
        'movement_date': '2024-03-16',
        'status': 'نشط',
      },
    ];
  }

  void _calculateStatistics(List<Map<String, dynamic>> movements) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // إحصائيات أساسية
    final total = movements.length;
    final todayMovements = movements.where((movement) {
      final movementDate = DateTime.tryParse(movement['movement_date'] ?? '');
      return movementDate != null &&
          movementDate.year == today.year &&
          movementDate.month == today.month &&
          movementDate.day == today.day;
    }).length;

    final pendingMovements = movements
        .where(
          (movement) =>
              (movement['status'] ?? '') == 'نشط' ||
              (movement['status'] ?? '') == 'قيد التنفيذ',
        )
        .length;

    final completedMovements = movements
        .where((movement) => (movement['status'] ?? '') == 'مكتمل')
        .length;

    // التوزيع حسب النوع
    final movementsByType = <String, int>{};
    for (var movement in movements) {
      final type = movement['movement_type'] ?? 'غير محدد';
      movementsByType[type] = (movementsByType[type] ?? 0) + 1;
    }

    // التوزيع حسب الحالة
    final movementsByStatus = <String, int>{};
    for (var movement in movements) {
      final status = movement['status'] ?? 'غير محدد';
      movementsByStatus[status] = (movementsByStatus[status] ?? 0) + 1;
    }

    // التوزيع الجغرافي
    final geographicalDistribution = <String, int>{};
    for (var movement in movements) {
      final location = movement['to_location'] ?? 'غير محدد';
      geographicalDistribution[location] =
          (geographicalDistribution[location] ?? 0) + 1;
    }

    // أحدث التحركات (آخر 5 تحركات)
    final recentMovements = movements.take(5).toList();

    setState(() {
      _statsData = {
        'total_movements': total,
        'today_movements': todayMovements,
        'pending_movements': pendingMovements,
        'completed_movements': completedMovements,
        'movements_by_type': movementsByType,
        'movements_by_status': movementsByStatus,
        'recent_movements': recentMovements,
        'geographical_distribution': geographicalDistribution.entries
            .map((e) => {'region': e.key, 'count': e.value})
            .toList(),
      };
    });
  }

  // دالة لتحويل البيانات للرسوم البيانية
  List<ChartData> _getChartData(Map<String, int> dataMap) {
    return dataMap.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  List<ChartData> _getGeographicalData() {
    final data = _statsData['geographical_distribution'] as List;
    return data.map<ChartData>((item) {
      return ChartData(item['region'], item['count']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
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
              _loadMovementsData(); // إعادة تحميل البيانات عند تغيير الفلتر
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'اليوم', child: Text('اليوم')),
              PopupMenuItem(value: 'أسبوع', child: Text('الأسبوع')),
              PopupMenuItem(value: 'شهر', child: Text('الشهر')),
              PopupMenuItem(value: 'كل', child: Text('الكل')),
            ],
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadMovementsData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل بيانات التحركات...'),
                ],
              ),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return isWeb
                      ? _buildWebLayout(constraints)
                      : _buildMobileLayout(constraints);
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
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
              SizedBox(height: 80),
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
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ الدالة المفقودة تم إضافتها هنا
  Widget _buildChartsSection(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: constraints.maxHeight * 0.6),
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
          Expanded(flex: 1, child: _buildRecentMovementsPanel()),
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
            Container(height: 250, child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedChartType) {
      case 'نوع التحرك':
        final chartData = _getChartData(_statsData['movements_by_type'] ?? {});
        if (chartData.isEmpty) {
          return Center(child: Text('لا توجد بيانات'));
        }
        return SfCircularChart(
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        );
      case 'حالة التحرك':
        final chartData = _getChartData(
          _statsData['movements_by_status'] ?? {},
        );
        if (chartData.isEmpty) {
          return Center(child: Text('لا توجد بيانات'));
        }
        return SfCircularChart(
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CircularSeries>[
            PieSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(isVisible: true),
            ),
          ],
        );
      default:
        return Container(child: Center(child: Text('لا توجد بيانات')));
    }
  }

  Widget _buildGeographicalChart() {
    final chartData = _getGeographicalData();

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
              child: chartData.isEmpty
                  ? Center(child: Text('لا توجد بيانات'))
                  : SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(minimum: 0),
                      series: <CartesianSeries<ChartData, String>>[
                        ColumnSeries<ChartData, String>(
                          dataSource: chartData,
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
    final recentMovements = _statsData['recent_movements'] as List;

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
              child: recentMovements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('لا توجد تحركات حديثة'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: recentMovements.length,
                      itemBuilder: (context, index) {
                        final movement = recentMovements[index];
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
          movement['personnel_name'] ??
              movement['personnelName'] ??
              movement['name'] ??
              'غير معروف',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${movement['movement_type']} - ${movement['movement_date']}',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'من ${movement['from_location']} إلى ${movement['to_location']}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            movement['status'] ?? 'غير محدد',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          backgroundColor:
              (movement['status'] == 'مكتمل' || movement['status'] == 'مكتملة')
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
                      label: Text(
                        'معلومات الخريطة',
                        style: TextStyle(fontSize: 12),
                      ),
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
    _loadMovementsData();
    _showSuccessMessage('تم تحديث البيانات بنجاح');
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
              'المستنفر: ${movement['personnel_name'] ?? movement['personnelName'] ?? movement['name'] ?? 'غير معروف'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('نوع التحرك: ${movement['movement_type'] ?? 'غير محدد'}'),
            Text('من: ${movement['from_location'] ?? 'غير محدد'}'),
            Text('إلى: ${movement['to_location'] ?? 'غير محدد'}'),
            Text('التاريخ: ${movement['movement_date'] ?? 'غير محدد'}'),
            Text('الحالة: ${movement['status'] ?? 'غير محدد'}'),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
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
