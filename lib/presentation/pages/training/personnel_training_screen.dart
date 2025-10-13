import 'package:flutter/material.dart';
import 'package:resistance_system_app/presentation/pages/training/instructors_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/training_courses_screen.dart';
import './../../../core/models/training_record.dart';
import './../../../core/services/training_api.dart';
import 'training_form_screen.dart';
import 'training_detail_screen.dart';

class PersonnelTrainingScreen extends StatefulWidget {
  @override
  _PersonnelTrainingScreenState createState() =>
      _PersonnelTrainingScreenState();
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

  void _refreshData() {
    setState(() {
      isLoading = true;
    });
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
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<TrainingRecord> get filteredRecords {
    if (searchQuery.isEmpty) return trainingRecords;

    return trainingRecords.where((record) {
      return record.personnelName?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ==
              true ||
          record.militaryNumber?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ==
              true ||
          record.courseName?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ==
              true ||
          record.priorTrainingType?.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ==
              true;
    }).toList();
  }

  Widget _buildTrainingTable() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (filteredRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'لا توجد سجلات تدريب'
                  : 'لا توجد نتائج للبحث',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            if (searchQuery.isEmpty)
              ElevatedButton(
                onPressed: _addNewTrainingRecord,
                child: Text('إضافة سجل تدريب جديد'),
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 10,
          columns: const [
            DataColumn(
              label: Text(
                'الاسم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'الرقم العسكري',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'الدورة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'نوع التدريب',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'التقييم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'الحالة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'الإجراءات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: filteredRecords.map((record) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    record.personnelName ?? 'غير محدد',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => _viewTrainingDetails(record),
                ),
                DataCell(
                  Text(record.militaryNumber ?? 'غير محدد'),
                  onTap: () => _viewTrainingDetails(record),
                ),
                DataCell(
                  Tooltip(
                    message: record.courseName ?? '',
                    child: Text(
                      record.courseName != null &&
                              record.courseName!.length > 15
                          ? '${record.courseName!.substring(0, 15)}...'
                          : record.courseName ?? 'لا يوجد',
                    ),
                  ),
                  onTap: () => _viewTrainingDetails(record),
                ),
                DataCell(
                  Text(record.priorTrainingType ?? 'غير محدد'),
                  onTap: () => _viewTrainingDetails(record),
                ),
                DataCell(
                  _buildEvaluationCell(record.evaluationScore),
                  onTap: () => _viewTrainingDetails(record),
                ),
                DataCell(
                  _buildStatusChip(record.attendanceStatus),
                  onTap: () => _viewTrainingDetails(record),
                ),
                DataCell(_buildActionButtons(record)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(TrainingRecord record) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, color: Colors.blue),
              SizedBox(width: 8),
              Text('عرض التفاصيل'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.orange),
              SizedBox(width: 8),
              Text('تعديل'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف'),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'view':
            _viewTrainingDetails(record);
            break;
          case 'edit':
            _editTrainingRecord(record);
            break;
          case 'delete':
            _showDeleteDialog(record);
            break;
        }
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'حاضر':
        return Colors.green;
      case 'غائب':
        return Colors.red;
      case 'متأخر':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEvaluationCell(int? score) {
    if (score == null) return Text('--');

    Color scoreColor = Colors.red;
    if (score >= 80)
      scoreColor = Colors.green;
    else if (score >= 60)
      scoreColor = Colors.orange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          score.toString(),
          style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 4),
        Icon(Icons.star, color: Colors.amber, size: 16),
      ],
    );
  }

  // تحسين شريط الحالة
  Widget _buildStatusChip(String? status) {
    final statusInfo = _getStatusInfo(status);
    return Chip(
      label: Text(
        statusInfo['text'],
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: statusInfo['color'],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Map<String, dynamic> _getStatusInfo(String? status) {
    switch (status) {
      case 'حاضر':
        return {'text': 'حاضر', 'color': Colors.green};
      case 'غائب':
        return {'text': 'غائب', 'color': Colors.red};
      case 'متأخر':
        return {'text': 'متأخر', 'color': Colors.orange};
      default:
        return {'text': status ?? 'غير محدد', 'color': Colors.grey};
    }
  }

  void _showDeleteDialog(TrainingRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text(
            'هل أنت متأكد من حذف سجل التدريب لـ ${record.personnelName}؟',
          ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم حذف سجل التدريب بنجاح')));
    } catch (e) {
      _showErrorSnackBar('خطأ في حذف السجل: $e');
    }
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
      MaterialPageRoute(builder: (context) => TrainingFormScreen()),
    ).then((_) => _loadTrainingData());
  }

  void _showTrainingStats() async {
    try {
      final stats = await TrainingApi.getTrainingStats();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('إحصائيات التدريب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem(
                'إجمالي سجلات التدريب',
                stats['total_records']?.toString() ?? '0',
              ),
              _buildStatItem(
                'المستنفرين المدربين',
                stats['trained_personnel']?.toString() ?? '0',
              ),
              _buildStatItem(
                'الدورات النشطة',
                stats['active_courses']?.toString() ?? '0',
              ),
              _buildStatItem(
                'متوسط التقييم',
                stats['average_score']?.toString() ?? '0',
              ),
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
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الإحصائيات: $e');
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'courses',
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.green),
                    SizedBox(width: 8),
                    Text('إدارة الدورات'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'instructors',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('إدارة المدربين'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('الإحصائيات'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('تحديث البيانات'),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'stats':
                  _showTrainingStats();
                  break;
                case 'refresh':
                  _refreshData();
                  break;
                   case 'courses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrainingCoursesScreen()),
        );
        break;
      case 'instructors':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InstructorsScreen()),
        );
        break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'بحث في سجلات التدريب',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(child: _buildTrainingTable()),
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
