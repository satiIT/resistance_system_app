// lib/presentation/pages/personnel/personnel_training_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/services/training_api.dart';
import '../../../core/models/training_record.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelTrainingScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelTrainingScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelTrainingScreenState createState() => _PersonnelTrainingScreenState();
}

class _PersonnelTrainingScreenState extends State<PersonnelTrainingScreen> {
  List<TrainingRecord> _trainingRecords = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
  }

  Future<void> _loadTrainingData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final records = await TrainingApi.getTrainingByPersonnelId(widget.personnelId);
      
      setState(() {
        _trainingRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحميل بيانات التدريب: $e';
      });
      _showErrorMessage('فشل في تحميل بيانات التدريب: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
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
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTrainingData,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري تحميل بيانات التدريب...'),
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
            onPressed: _loadTrainingData,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
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
    final int completed = _trainingRecords.where((record) => 
        _getStatusFromRecord(record) == 'مكتمل' || 
        _getStatusFromRecord(record) == 'completed').length;
    
    final int inProgress = _trainingRecords.where((record) => 
        _getStatusFromRecord(record) == 'قيد التنفيذ' || 
        _getStatusFromRecord(record) == 'in_progress').length;
    
    final double avgScore = _trainingRecords
        .where((record) => record.evaluationScore != null)
        .map((record) => record.evaluationScore!)
        .fold(0, (a, b) => a + b) / 
        (_trainingRecords.where((record) => record.evaluationScore != null).length);

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
            _buildStatItem('الشهادات', '${_trainingRecords.where((record) => record.certificateReceived == true).length}', Icons.school, Colors.purple),
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
                  Text('آخر تدريب: ${_trainingRecords.isNotEmpty ? (_trainingRecords.last.courseName ?? 'غير معروف') : 'لا يوجد'}'),
                ],
              ),
            ),
            Chip(
              label: Text(
                _trainingRecords.isNotEmpty ? 'نشط' : 'غير نشط',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _trainingRecords.isNotEmpty ? Colors.green : Colors.grey,
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
                      DataCell(Text(record.courseName ?? '--')),
                      DataCell(Text(_getCourseType(record) ?? '--')),
                      DataCell(Text(_getWeaponType(record) ?? '--')),
                      DataCell(Text(record.trainingCampName ?? '--')),
                      DataCell(Text('${_formatDate(record.courseStartDate)} إلى ${_formatDate(record.courseEndDate)}')),
                      DataCell(
                        Chip(
                          label: Text(
                            _getStatusTextFromRecord(record),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getStatusColorFromRecord(record),
                        ),
                      ),
                      DataCell(Text(record.evaluationScore?.toString() ?? '--')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 18),
                            onPressed: () => _editTrainingRecord(context, record),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => _deleteTrainingRecord(context, record.id!),
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
            title: Text(record.courseName ?? '--', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_getCourseType(record) ?? '--'} - ${_getWeaponType(record) ?? '--'}'),
                Text('${_formatDate(record.courseStartDate)} إلى ${_formatDate(record.courseEndDate)}'),
                Row(
                  children: [
                    Chip(
                      label: Text(_getStatusTextFromRecord(record), style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: _getStatusColorFromRecord(record),
                    ),
                    if (record.evaluationScore != null) ...[
                      SizedBox(width: 8),
                      Chip(
                        label: Text('${record.evaluationScore}%', style: TextStyle(fontSize: 10)),
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
                  _deleteTrainingRecord(context, record.id!);
                }
              },
            ),
          ),
        );
      },
    );
  }

  // Helper methods to get data from TrainingRecord
  String _getStatusFromRecord(TrainingRecord record) {
    return record.attendanceStatus ?? 'unknown';
  }

  String _getCourseType(TrainingRecord record) {
    return record.courseType ?? record.specializedCourseType ?? record.priorTrainingType ?? '--';
  }

  String _getWeaponType(TrainingRecord record) {
    return record.weaponType ?? record.weaponTrainingType ?? '--';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getStatusTextFromRecord(TrainingRecord record) {
    final status = _getStatusFromRecord(record);
    return _getStatusText(status);
  }

  Color _getStatusColorFromRecord(TrainingRecord record) {
    final status = _getStatusFromRecord(record);
    return _getStatusColor(status);
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'مكتمل':
      case 'finished':
        return 'مكتمل';
      case 'in_progress':
      case 'قيد التنفيذ':
      case 'ongoing':
        return 'قيد التنفيذ';
      case 'pending':
      case 'معلق':
        return 'معلق';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'مكتمل':
      case 'finished':
        return Colors.green;
      case 'in_progress':
      case 'قيد التنفيذ':
      case 'ongoing':
        return Colors.orange;
      case 'pending':
      case 'معلق':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _addTrainingRecord(BuildContext context) {
    _showTrainingFormDialog(context, null);
  }

  void _editTrainingRecord(BuildContext context, TrainingRecord record) {
    _showTrainingFormDialog(context, record);
  }

  Future<void> _deleteTrainingRecord(BuildContext context, int recordId) async {
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
            onPressed: () async {
              try {
                Navigator.pop(context);
                await TrainingApi.deleteTrainingRecord(recordId);
                setState(() {
                  _trainingRecords.removeWhere((record) => record.id == recordId);
                });
                _showSuccessMessage('تم حذف السجل التدريبي بنجاح');
              } catch (e) {
                _showErrorMessage('فشل في حذف السجل التدريبي: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showTrainingFormDialog(BuildContext context, TrainingRecord? record) {
    // Implement your form dialog here
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
                Text('هنا يمكنك إضافة نموذج لإدخال بيانات التدريب'),
                // Add your form fields here based on TrainingRecord model
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
              _saveTrainingRecord(record);
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrainingRecord(TrainingRecord? record) async {
    try {
      if (record == null) {
        // Create new record - you'll need to provide courseId
        final newRecord = TrainingRecord(
          personnelId: widget.personnelId,
          courseId: 1, // You need to get this from somewhere - maybe from a course selection
          courseName: 'دورة جديدة',
          courseType: 'نوع الدورة',
          weaponType: 'نوع السلاح',
          trainingCampName: 'المعسكر',
          courseStartDate: DateTime(2024, 1, 1),
          courseEndDate: DateTime(2024, 1, 30),
          attendanceStatus: 'مكتمل',
          evaluationScore: 85,
          certificateReceived: true,
        );
        await TrainingApi.createTrainingRecord(newRecord);
        _showSuccessMessage('تم إضافة السجل التدريبي بنجاح');
      } else {
        // Update existing record
        await TrainingApi.updateTrainingRecord(record);
        _showSuccessMessage('تم تعديل السجل التدريبي بنجاح');
      }
      _loadTrainingData(); // Reload data
    } catch (e) {
      _showErrorMessage('فشل في حفظ السجل التدريبي: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}