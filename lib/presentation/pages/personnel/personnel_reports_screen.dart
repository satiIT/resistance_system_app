// lib/presentation/pages/personnel/personnel_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelReportsScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelReportsScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelReportsScreenState createState() => _PersonnelReportsScreenState();
}

class _PersonnelReportsScreenState extends State<PersonnelReportsScreen> {
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  void _loadReportData() {
    // بيانات وهمية للتقارير
    setState(() {
      _reportData = {
        'performance': [
          {'month': 'يناير', 'score': 85},
          {'month': 'فبراير', 'score': 92},
          {'month': 'مارس', 'score': 78},
          {'month': 'أبريل', 'score': 88},
        ],
        'training': [
          {'course': 'التدريب الأساسي', 'status': 'مكتمل', 'score': 85},
          {'course': 'تدريب متقدم', 'status': 'مكتمل', 'score': 90},
          {'course': 'تدريب القناصة', 'status': 'قيد التنفيذ', 'score': null},
        ],
        'attendance': {
          'present': 45,
          'absent': 3,
          'late': 2,
          'percentage': 90.0,
        },
        'equipment': {
          'assigned': 8,
          'maintenance': 2,
          'returned': 1,
        },
        'financial': {
          'totalReceived': 1850000.0,
          'pending': 300000.0,
          'monthlyAverage': 650000.0,
        },
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
        title: Text('التقارير والإحصائيات - ${widget.personnelName}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _printReport(context),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareReport(context),
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
          _buildReportSummary(),
          SizedBox(height: 24),
          _buildChartsRow(),
          SizedBox(height: 24),
          _buildDetailedReports(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportSummary(),
          SizedBox(height: 16),
          _buildPerformanceChart(),
          SizedBox(height: 16),
          _buildAttendanceStats(),
          SizedBox(height: 16),
          _buildTrainingProgress(),
          SizedBox(height: 16),
          _buildFinancialSummary(),
        ],
      ),
    );
  }

  Widget _buildReportSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.assessment, color: Colors.blue, size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('التقارير والإحصائيات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('آخر تحديث: ${DateTime.now().toString().split(' ')[0]}'),
                  Text('فترة التقرير: من 2024-01-01 إلى 2024-04-30'),
                ],
              ),
            ),
            Chip(
              label: Text('متميز', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPerformanceChart(),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildAttendanceChart(),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('أداء المستنفر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  LineSeries<Map<String, dynamic>, String>(
                    dataSource: _reportData['performance'],
                    xValueMapper: (Map<String, dynamic> data, _) => data['month'],
                    yValueMapper: (Map<String, dynamic> data, _) => data['score'],
                    name: 'التقييم',
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    final attendance = _reportData['attendance'];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('الحضور والغياب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<Map<String, dynamic>, String>(
                    dataSource: [
                      {'type': 'حضور', 'value': attendance['present'], 'color': Colors.green},
                      {'type': 'غياب', 'value': attendance['absent'], 'color': Colors.red},
                      {'type': 'تأخير', 'value': attendance['late'], 'color': Colors.orange},
                    ],
                    xValueMapper: (Map<String, dynamic> data, _) => data['type'],
                    yValueMapper: (Map<String, dynamic> data, _) => data['value'],
                    pointColorMapper: (Map<String, dynamic> data, _) => data['color'],
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStats() {
    final attendance = _reportData['attendance'];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('إحصائيات الحضور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCircle('الحضور', attendance['present'], Colors.green, Icons.check_circle),
                _buildStatCircle('الغياب', attendance['absent'], Colors.red, Icons.cancel),
                _buildStatCircle('التأخير', attendance['late'], Colors.orange, Icons.schedule),
                _buildStatCircle('النسبة %', attendance['percentage'], Colors.blue, Icons.percent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCircle(String title, dynamic value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(height: 4),
              Text(value.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTrainingProgress() {
    final training = _reportData['training'];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('التقدم في التدريب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Column(
              children: training.map<Widget>((course) {
                return ListTile(
                  leading: Icon(
                    course['status'] == 'مكتمل' ? Icons.check_circle : Icons.schedule,
                    color: course['status'] == 'مكتمل' ? Colors.green : Colors.orange,
                  ),
                  title: Text(course['course']),
                  subtitle: Text(course['status']),
                  trailing: course['score'] != null 
                      ? Chip(
                          label: Text('${course['score']}%', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.blue,
                        )
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final financial = _reportData['financial'];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('ملخص مالي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFinancialItem('إجمالي المستلم', financial['totalReceived'], Colors.green),
                _buildFinancialItem('المعلقة', financial['pending'], Colors.orange),
                _buildFinancialItem('المتوسط الشهري', financial['monthlyAverage'], Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(_formatCurrency(amount), 
             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailedReports() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('التقارير التفصيلية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildReportCard('تقرير الأداء', Icons.assessment, Colors.blue, () => _generatePerformanceReport()),
                _buildReportCard('تقرير التدريب', Icons.school, Colors.green, () => _generateTrainingReport()),
                _buildReportCard('تقرير مالي', Icons.attach_money, Colors.orange, () => _generateFinancialReport()),
                _buildReportCard('تقرير المعدات', Icons.inventory, Colors.purple, () => _generateEquipmentReport()),
                _buildReportCard('تقرير الحضور', Icons.calendar_today, Colors.red, () => _generateAttendanceReport()),
                _buildReportCard('تقرير شامل', Icons.summarize, Colors.teal, () => _generateComprehensiveReport()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ج.س';
  }

  void _generatePerformanceReport() {
    _showReportDialog('تقرير الأداء', 'تم إنشاء تقرير الأداء بنجاح');
  }

  void _generateTrainingReport() {
    _showReportDialog('تقرير التدريب', 'تم إنشاء تقرير التدريب بنجاح');
  }

  void _generateFinancialReport() {
    _showReportDialog('تقرير مالي', 'تم إنشاء التقرير المالي بنجاح');
  }

  void _generateEquipmentReport() {
    _showReportDialog('تقرير المعدات', 'تم إنشاء تقرير المعدات بنجاح');
  }

  void _generateAttendanceReport() {
    _showReportDialog('تقرير الحضور', 'تم إنشاء تقرير الحضور بنجاح');
  }

  void _generateComprehensiveReport() {
    _showReportDialog('تقرير شامل', 'تم إنشاء التقرير الشامل بنجاح');
  }

  void _printReport(BuildContext context) {
    _showSuccessMessage('جاري إعداد التقرير للطباعة...');
  }

  void _shareReport(BuildContext context) {
    _showSuccessMessage('جاري مشاركة التقرير...');
  }

  void _showReportDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('تم حفظ التقرير بنجاح');
            },
            child: Text('حفظ التقرير'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}