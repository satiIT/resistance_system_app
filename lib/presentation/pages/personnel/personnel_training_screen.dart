// lib/presentation/pages/personnel/personnel_training_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelTrainingScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelTrainingScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelTrainingScreenState createState() => _PersonnelTrainingScreenState();
}

class _PersonnelTrainingScreenState extends State<PersonnelTrainingScreen> {
  List<Map<String, dynamic>> _trainingRecords = [];

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
  }

  void _loadTrainingData() {
    // بيانات وهمية للتدريب
    setState(() {
      _trainingRecords = [
        {
          'id': 1,
          'course_name': 'التدريب الأساسي',
          'course_type': 'أولي',
          'weapon_type': 'AK-47',
          'training_camp': 'عهد الرجال 1',
          'start_date': '2024-01-01',
          'end_date': '2024-01-30',
          'status': 'مكتمل',
          'score': 85,
          'certificate': true,
        },
        {
          'id': 2,
          'course_name': 'تدريب متقدم',
          'course_type': 'متقدم',
          'weapon_type': 'قناصة',
          'training_camp': 'عهد الرجال 2',
          'start_date': '2024-02-01',
          'end_date': '2024-02-20',
          'status': 'قيد التنفيذ',
          'score': null,
          'certificate': false,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('التدريب والتسليح - ${widget.personnelName}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addTrainingRecord(context),
          ),
        ],
      ),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // لوحة الإحصائيات
        _buildStatsPanel(context),
        // القائمة الرئيسية
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTrainingSummary(),
                SizedBox(height: 16),
                Expanded(
                  child: _buildTrainingTable(context),
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
          _buildTrainingSummary(),
          SizedBox(height: 16),
          Expanded(
            child: _buildTrainingList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(BuildContext context) {
    final int completed = _trainingRecords.where((record) => record['status'] == 'مكتمل').length;
    final int inProgress = _trainingRecords.where((record) => record['status'] == 'قيد التنفيذ').length;
    final double avgScore = _trainingRecords
        .where((record) => record['score'] != null)
        .map((record) => record['score'] as int)
        .fold(0, (a, b) => a + b) / 
        (_trainingRecords.where((record) => record['score'] != null).length);

    return Container(
      width: 200,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إحصائيات التدريب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _buildStatItem('الدورات المكتملة', completed.toString(), Icons.check_circle, Colors.green),
            _buildStatItem('قيد التنفيذ', inProgress.toString(), Icons.schedule, Colors.orange),
            _buildStatItem('متوسط النقاط', avgScore.isNaN ? '0' : avgScore.toStringAsFixed(1), Icons.assessment, Colors.blue),
            _buildStatItem('الشهادات', '${_trainingRecords.where((record) => record['certificate'] == true).length}', Icons.school, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTrainingSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.school, color: Colors.blue, size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('السجل التدريبي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('إجمالي الدورات: ${_trainingRecords.length} دورة'),
                  Text('آخر تدريب: ${_trainingRecords.isNotEmpty ? _trainingRecords.last['course_name'] : 'لا يوجد'}'),
                ],
              ),
            ),
            Chip(
              label: Text('نشط', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سجل التدريب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _addTrainingRecord(context),
                  icon: Icon(Icons.add),
                  label: Text('إضافة تدريب'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('اسم الدورة')),
                    DataColumn(label: Text('نوع التدريب')),
                    DataColumn(label: Text('نوع السلاح')),
                    DataColumn(label: Text('المعسكر')),
                    DataColumn(label: Text('المدة')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('التقييم')),
                    DataColumn(label: Text('الإجراءات')),
                  ],
                  rows: _trainingRecords.map((record) {
                    return DataRow(cells: [
                      DataCell(Text(record['course_name'])),
                      DataCell(Text(record['course_type'])),
                      DataCell(Text(record['weapon_type'])),
                      DataCell(Text(record['training_camp'])),
                      DataCell(Text('${record['start_date']} إلى ${record['end_date']}')),
                      DataCell(
                        Chip(
                          label: Text(
                            record['status'],
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: record['status'] == 'مكتمل' ? Colors.green : Colors.orange,
                        ),
                      ),
                      DataCell(Text(record['score']?.toString() ?? '--')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 18),
                            onPressed: () => _editTrainingRecord(context, record),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => _deleteTrainingRecord(context, record['id']),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingList(BuildContext context) {
    return ListView.builder(
      itemCount: _trainingRecords.length,
      itemBuilder: (context, index) {
        final record = _trainingRecords[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.school, color: Colors.blue),
            title: Text(record['course_name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${record['course_type']} - ${record['weapon_type']}'),
                Text('${record['start_date']} إلى ${record['end_date']}'),
                Row(
                  children: [
                    Chip(
                      label: Text(record['status'], style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: record['status'] == 'مكتمل' ? Colors.green : Colors.orange,
                    ),
                    if (record['score'] != null) ...[
                      SizedBox(width: 8),
                      Chip(
                        label: Text('${record['score']}%', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.blue[100],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text('تعديل'), value: 'edit'),
                PopupMenuItem(child: Text('حذف'), value: 'delete'),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editTrainingRecord(context, record);
                } else if (value == 'delete') {
                  _deleteTrainingRecord(context, record['id']);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _addTrainingRecord(BuildContext context) {
    _showTrainingFormDialog(context, null);
  }

  void _editTrainingRecord(BuildContext context, Map<String, dynamic> record) {
    _showTrainingFormDialog(context, record);
  }

  void _deleteTrainingRecord(BuildContext context, int recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف سجل التدريب'),
        content: Text('هل أنت متأكد من حذف هذا السجل التدريبي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _trainingRecords.removeWhere((record) => record['id'] == recordId);
              });
              Navigator.pop(context);
              _showSuccessMessage('تم حذف السجل التدريبي بنجاح');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showTrainingFormDialog(BuildContext context, Map<String, dynamic>? record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record == null ? 'إضافة سجل تدريبي' : 'تعديل سجل تدريبي'),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: record?['course_name'] ?? '',
                  decoration: InputDecoration(labelText: 'اسم الدورة'),
                ),
                // يمكن إضافة المزيد من الحقول هنا
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // حفظ البيانات
              Navigator.pop(context);
              _showSuccessMessage(record == null ? 'تم إضافة السجل التدريبي بنجاح' : 'تم تعديل السجل التدريبي بنجاح');
            },
            child: Text('حفظ'),
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