import 'package:flutter/material.dart';
import './../../../core/models/training_record.dart';
import './../../../core/services/training_api.dart';
import 'training_form_screen.dart';
import 'training_detail_screen.dart';

class PersonnelTrainingScreen extends StatefulWidget {
  @override
  _PersonnelTrainingScreenState createState() => _PersonnelTrainingScreenState();
}

class _PersonnelTrainingScreenState extends State<PersonnelTrainingScreen> {
  List<TrainingRecord> trainingRecords = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
  }

  Future<void> _loadTrainingData() async {
    try {
      final response = await TrainingApi.getTrainingRecords();
      setState(() {
        trainingRecords = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  List<TrainingRecord> get filteredRecords {
    if (searchQuery.isEmpty) return trainingRecords;
    
    return trainingRecords.where((record) {
      return record.personnelName?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
             record.militaryNumber?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
             record.previousTrainingType?.toLowerCase().contains(searchQuery.toLowerCase()) == true;
    }).toList();
  }

  void _showDeleteDialog(TrainingRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف سجل التدريب لـ ${record.personnelName}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTrainingRecord(record);
              },
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTrainingRecord(TrainingRecord record) async {
    try {
      await TrainingApi.deleteTrainingRecord(record.id!);
      setState(() {
        trainingRecords.removeWhere((r) => r.id == record.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف سجل التدريب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف السجل: $e')),
      );
    }
  }

  Widget _buildTrainingTable() {
    if (filteredRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد سجلات تدريب',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 10,
        columns: const [
          DataColumn(label: Text('الاسم', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('الرقم العسكري', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('نوع التدريب', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('الدورة التدريبية', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('السلاح', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: filteredRecords.map((record) {
          return DataRow(cells: [
            DataCell(
              Text(record.personnelName ?? 'غير محدد',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(Text(record.militaryNumber ?? 'غير محدد')),
            DataCell(Text(record.previousTrainingType ?? 'غير محدد')),
            DataCell(Text(record.trainingCampCourseName ?? 'لا يوجد')),
            DataCell(Text(record.weaponTypeReceived ?? 'لا يوجد')),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () => _viewTrainingDetails(record),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editTrainingRecord(record),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(record),
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  void _viewTrainingDetails(TrainingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingDetailScreen(record: record),
      ),
    );
  }

  void _editTrainingRecord(TrainingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingFormScreen(existingRecord: record),
      ),
    ).then((_) => _loadTrainingData());
  }

  void _addNewTrainingRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingFormScreen(),
      ),
    ).then((_) => _loadTrainingData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استمارة التدريب والتسليح - استمارة رقم (2)'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewTrainingRecord,
            tooltip: 'إضافة سجل تدريب جديد',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTrainingData,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'بحث في سجلات التدريب',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: _buildTrainingTable(),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTrainingRecord,
        child: Icon(Icons.add),
        tooltip: 'إضافة سجل تدريب جديد',
      ),
    );
  }
}