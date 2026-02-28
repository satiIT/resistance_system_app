// lib/presentation/pages/personnel/personnel_reports_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:universal_platform/universal_platform.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/services/reports_api.dart';

class PersonnelReportsScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelReportsScreen({
    Key? key,
    required this.personnelId,
    required this.personnelName,
  }) : super(key: key);

  @override
  _PersonnelReportsScreenState createState() => _PersonnelReportsScreenState();
}

class _PersonnelReportsScreenState extends State<PersonnelReportsScreen> {
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final reportData = await ReportsApi.getPersonnelReport(
        widget.personnelId,
      );

      setState(() {
        _reportData = reportData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في جلب بيانات التقرير: $e';
      });
      _showErrorMessage('فشل في جلب بيانات التقرير: $e');
    }
  }

  // Safe data access methods with proper type handling
  Map<String, dynamic> _getMap(String key) {
    final data = _reportData[key];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      // Convert any Map to Map<String, dynamic>
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  List<dynamic> _getList(String key) {
    final data = _reportData[key];
    if (data is List) {
      return data;
    }
    return [];
  }

  // Safe number conversion
  double _getNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Safe string conversion - FIXED THE TYPE ERROR
  String _getString(dynamic value) {
    if (value == null) return '--';
    if (value is String) return value;
    // Convert any other type to string
    return value.toString();
  }

  // Safe nested access
  dynamic _getNested(Map<String, dynamic> map, List<String> keys) {
    dynamic current = map;
    for (final key in keys) {
      if (current is Map) {
        current = (current as Map)[key];
      } else {
        return null;
      }
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('التقارير والإحصائيات - ${widget.personnelName}'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadReportData),
          if (!_isLoading) _buildExportMenu(),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildContent(isWeb, isMobile),
    );
  }

  Widget _buildExportMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'print':
            _printReport();
            break;
          case 'pdf':
            _sharePdf();
            break;
          case 'csv':
            _exportCsv();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'print',
          child: Row(
            children: [
              Icon(Icons.print, color: Colors.blue),
              SizedBox(width: 8),
              Text('طباعة التقرير'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text('تصدير PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.green),
              SizedBox(width: 8),
              Text('تصدير CSV'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isWeb, bool isMobile) {
    return SafeArea(child: isWeb ? _buildWebLayout() : _buildMobileLayout());
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري تحميل بيانات التقرير...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReportData,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildReportSummary(),
          SizedBox(height: 24),
          _buildChartsRow(),
          SizedBox(height: 24),
          _buildStatsGrid(),
          SizedBox(height: 24),
          _buildDetailedReports(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportSummary(),
          SizedBox(height: 16),
          _buildPerformanceChart(),
          SizedBox(height: 16),
          _buildAttendanceChart(),
          SizedBox(height: 16),
          _buildStatsGrid(),
          SizedBox(height: 16),
          _buildDetailedReportsMobile(),
        ],
      ),
    );
  }

  Widget _buildReportSummary() {
    final summary = _getMap('summary');
    final performance = _getMap('performance');

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assessment, color: Colors.blue, size: 40),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التقارير والإحصائيات الشاملة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 20,
                    runSpacing: 8,
                    children: [
                      _buildSummaryItem(
                        'آخر تحديث',
                        _getCurrentDateFormatted(),
                      ),
                      _buildSummaryItem(
                        'متوسط الأداء',
                        ReportsApi.formatPercentage(
                          _getNumber(performance['average_score']),
                        ),
                      ),
                      _buildSummaryItem(
                        'فترة التقرير',
                        _getString(summary['report_period']),
                      ),
                      _buildSummaryItem('حالة النظام', 'نشط'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ReportsApi.getStatusColor(
                  _getString(summary['overall_status']),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getString(summary['overall_status']),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: Colors.grey),
        SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600])),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getCurrentDateFormatted() {
    return DateFormat('yyyy/MM/dd - HH:mm').format(DateTime.now());
  }

  Widget _buildChartsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildPerformanceChart()),
        SizedBox(width: 16),
        Expanded(flex: 1, child: _buildAttendanceChart()),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    final monthlyScores = _getList('monthly_scores');

    final List<ChartData> chartData = monthlyScores.map((item) {
      if (item is Map) {
        final mapItem = Map<String, dynamic>.from(item);
        return ChartData(
          _getString(mapItem['month']),
          _getNumber(mapItem['score']),
        );
      }
      return ChartData('--', 0);
    }).toList();

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'تطور الأداء الشهري',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: chartData.isNotEmpty
                  ? SfCartesianChart(
                      primaryXAxis: CategoryAxis(labelRotation: -45),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.compact(),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<ChartData, String>>[
                        LineSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.month,
                          yValueMapper: (ChartData data, _) => data.score,
                          name: 'التقييم',
                          markerSettings: MarkerSettings(isVisible: true),
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          color: Colors.blue,
                        ),
                      ],
                    )
                  : _buildEmptyChart('لا توجد بيانات للأداء'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    final attendance = _getMap('attendance');
    final breakdown = _getNested(attendance, ['breakdown']) ?? {};

    final List<PieData> pieData = [
      PieData('حضور', _getNumber(breakdown['present']), Colors.green),
      PieData('غياب', _getNumber(breakdown['absent']), Colors.red),
      PieData('تأخير', _getNumber(breakdown['late']), Colors.orange),
      PieData('إجازة', _getNumber(breakdown['leave']), Colors.blue),
    ].where((data) => data.value > 0).toList();

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'توزيع الحضور',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: pieData.isNotEmpty
                  ? SfCircularChart(
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                      ),
                      series: <CircularSeries<PieData, String>>[
                        DoughnutSeries<PieData, String>(
                          dataSource: pieData,
                          xValueMapper: (PieData data, _) => data.type,
                          yValueMapper: (PieData data, _) => data.value,
                          pointColorMapper: (PieData data, _) => data.color,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                          ),
                        ),
                      ],
                    )
                  : _buildEmptyChart('لا توجد بيانات للحضور'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final performance = _getMap('performance');
    final attendance = _getMap('attendance');
    // final training = _getMap('training');
    final financial = _getMap('financial');
    final courses = _getList('courses');

    final stats = [
      StatItem(
        'متوسط الأداء',
        ReportsApi.formatPercentage(_getNumber(performance['average_score'])),
        Icons.assessment,
        Colors.blue,
      ),
      StatItem(
        'نسبة الحضور',
        ReportsApi.formatPercentage(
          _getNumber(
            attendance['attendance_rate'] ??
                attendance['stats']?['attendance_rate'],
          ),
        ),
        Icons.percent,
        Colors.green,
      ),
      StatItem(
        'الدورات المكتملة',
        '${courses.where((c) {
          if (c is Map) {
            final course = Map<String, dynamic>.from(c);
            return _getString(course['status']).toLowerCase().contains('مكتمل');
          }
          return false;
        }).length}',
        Icons.check_circle,
        Colors.orange,
      ),
      StatItem(
        'المستحقات',
        ReportsApi.formatCurrency(
          _getNumber(financial['pending'] ?? financial['stats']?['pending']),
        ),
        Icons.pending,
        Colors.red,
      ),
    ];

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'إحصائيات سريعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.isMobile(context) ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return _buildStatCard(stat);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(StatItem stat) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.icon, color: stat.color, size: 24),
            SizedBox(height: 8),
            Text(
              stat.value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: stat.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReports() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'التقارير التفصيلية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'اختر نوع التقرير لعرض البيانات التفصيلية والتحليلات المتقدمة',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildReportCard(
                  'تقرير الأداء',
                  Icons.assessment,
                  Colors.blue,
                  'تحليل مفصل لأداء المستنفر',
                  () => _generatePerformanceReport(),
                ),
                _buildReportCard(
                  'تقرير التدريب',
                  Icons.school,
                  Colors.green,
                  'متابعة التقدم في البرامج التدريبية',
                  () => _generateTrainingReport(),
                ),
                _buildReportCard(
                  'تقرير مالي',
                  Icons.attach_money,
                  Colors.orange,
                  'تحليل شامل للبيانات المالية',
                  () => _generateFinancialReport(),
                ),
                _buildReportCard(
                  'تقرير المعدات',
                  Icons.inventory,
                  Colors.purple,
                  'سجل المعدات والصيانة',
                  () => _generateEquipmentReport(),
                ),
                _buildReportCard(
                  'تقرير الحضور',
                  Icons.calendar_today,
                  Colors.red,
                  'تحليل أنماط الحضور والغياب',
                  () => _generateAttendanceReport(),
                ),
                _buildReportCard(
                  'تقرير شامل',
                  Icons.dashboard,
                  Colors.teal,
                  'تقرير متكامل بجميع البيانات',
                  () => _generateComprehensiveReport(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReportsMobile() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'التقارير التفصيلية',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            ..._buildReportListTiles(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReportListTiles() {
    final reports = [
      ReportItem(
        'تقرير الأداء',
        Icons.assessment,
        Colors.blue,
        _generatePerformanceReport,
      ),
      ReportItem(
        'تقرير التدريب',
        Icons.school,
        Colors.green,
        _generateTrainingReport,
      ),
      ReportItem(
        'تقرير مالي',
        Icons.attach_money,
        Colors.orange,
        _generateFinancialReport,
      ),
      ReportItem(
        'تقرير المعدات',
        Icons.inventory,
        Colors.purple,
        _generateEquipmentReport,
      ),
      ReportItem(
        'تقرير الحضور',
        Icons.calendar_today,
        Colors.red,
        _generateAttendanceReport,
      ),
      ReportItem(
        'تقرير شامل',
        Icons.dashboard,
        Colors.teal,
        _generateComprehensiveReport,
      ),
    ];

    return reports.map((report) => _buildReportListTile(report)).toList();
  }

  Widget _buildReportListTile(ReportItem report) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: report.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(report.icon, color: report.color),
        ),
        title: Text(report.title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: report.onTap,
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 160,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Detailed Report Methods ==========

  Future<void> _generatePerformanceReport() async {
    try {
      final report = await ReportsApi.getPerformanceReport(widget.personnelId);
      _showDetailedReportDialog('تقرير الأداء', report);
    } catch (e) {
      _showErrorMessage('فشل في إنشاء تقرير الأداء: $e');
    }
  }

  Future<void> _generateTrainingReport() async {
    try {
      final report = await ReportsApi.getTrainingReport(widget.personnelId);
      _showDetailedReportDialog('تقرير التدريب', report);
    } catch (e) {
      _showErrorMessage('فشل في إنشاء تقرير التدريب: $e');
    }
  }

  Future<void> _generateFinancialReport() async {
    try {
      final report = await ReportsApi.getFinancialReport(widget.personnelId);
      _showDetailedReportDialog('تقرير مالي', report);
    } catch (e) {
      _showErrorMessage('فشل في إنشاء التقرير المالي: $e');
    }
  }

  Future<void> _generateEquipmentReport() async {
    try {
      final report = await ReportsApi.getEquipmentReport(widget.personnelId);
      _showDetailedReportDialog('تقرير المعدات', report);
    } catch (e) {
      _showErrorMessage('فشل في إنشاء تقرير المعدات: $e');
    }
  }

  Future<void> _generateAttendanceReport() async {
    try {
      final report = await ReportsApi.getAttendanceReport(widget.personnelId);
      _showDetailedReportDialog('تقرير الحضور', report);
    } catch (e) {
      _showErrorMessage('فشل في إنشاء تقرير الحضور: $e');
    }
  }

  Future<void> _generateComprehensiveReport() async {
    try {
      _showDetailedReportDialog('تقرير شامل', _reportData);
    } catch (e) {
      _showErrorMessage('فشل في إنشاء التقرير الشامل: $e');
    }
  }

  void _showDetailedReportDialog(String title, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getReportIcon(title)),
            SizedBox(width: 12),
            Expanded(child: Text(title)),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Container(
          width: math.min(MediaQuery.of(context).size.width * 0.9, 800),
          height: math.min(MediaQuery.of(context).size.height * 0.8, 600),
          child: _buildReportContent(title, report),
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

  Widget _buildReportContent(String title, Map<String, dynamic> report) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('بيانات التقرير'),
          SizedBox(height: 16),
          ..._buildReportDataList(report),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      ),
    );
  }

  List<Widget> _buildReportDataList(Map<String, dynamic> report) {
    return report.entries.map((entry) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text(
            _getString(entry.key), // Use _getString to handle key conversion
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: _buildValueWidget(entry.value),
        ),
      );
    }).toList();
  }

  Widget _buildValueWidget(dynamic value) {
    if (value is Map) {
      final mapValue = Map<String, dynamic>.from(value as Map);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mapValue.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${_getString(entry.key)}: ${_formatValue(entry.value)}',
            ),
          );
        }).toList(),
      );
    } else if (value is List) {
      return Text('عدد العناصر: ${value.length}');
    } else {
      return Text(_formatValue(value));
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) return '--';
    if (value is num) {
      if (value.toString().contains('.') || value < 1) {
        return ReportsApi.formatPercentage(value);
      }
      return value.toString();
    }
    return _getString(value);
  }

  IconData _getReportIcon(String title) {
    switch (title) {
      case 'تقرير الأداء':
        return Icons.assessment;
      case 'تقرير التدريب':
        return Icons.school;
      case 'تقرير مالي':
        return Icons.attach_money;
      case 'تقرير المعدات':
        return Icons.inventory;
      case 'تقرير الحضور':
        return Icons.calendar_today;
      case 'تقرير شامل':
        return Icons.dashboard;
      default:
        return Icons.description;
    }
  }

  // ========== Export Methods ==========

  void _printReport() {
    _showSuccessMessage('جاري إعداد التقرير للطباعة...');
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Text('تقرير ${widget.personnelName}'));
        },
      ),
    );

    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  Future<void> _sharePdf() async {
    try {
      final fileUrl = await ReportsApi.generatePdfReport(
        widget.personnelId,
        'comprehensive',
      );
      _showSuccessMessage('تم إنشاء ملف PDF بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في إنشاء ملف PDF: $e');
    }
  }

  Future<void> _exportCsv() async {
    try {
      final performance = _getMap('performance');
      final monthlyData = _getList('monthly_scores');

      final List<List<dynamic>> rows = [];
      rows.add(['الشهر', 'التقييم']);

      for (var row in monthlyData) {
        if (row is Map) {
          final mapRow = Map<String, dynamic>.from(row as Map);
          rows.add([
            _getString(mapRow['month']),
            _getNumber(mapRow['score']).toString(),
          ]);
        }
      }

      String csv = const ListToCsvConverter().convert(rows);
      await Clipboard.setData(ClipboardData(text: csv));

      _showSuccessMessage('تم نسخ البيانات إلى الحافظة');
    } catch (e) {
      _showErrorMessage('فشل في تصدير البيانات: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// ========== Data Models ==========

class ChartData {
  final String month;
  final double score;

  ChartData(this.month, this.score);
}

class PieData {
  final String type;
  final double value;
  final Color color;

  PieData(this.type, this.value, this.color);
}

class StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  StatItem(this.label, this.value, this.icon, this.color);
}

class ReportItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  ReportItem(this.title, this.icon, this.color, this.onTap);
}
