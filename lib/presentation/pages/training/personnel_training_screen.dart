import 'package:flutter/material.dart';
import 'package:resistance_system_app/presentation/pages/training/instructors_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/training_courses_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/training_course_form_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/instructor_form_screen.dart';
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
  int _selectedFilter = 0; // 0: جميع السجلات, 1: حاضر فقط, 2: غائب فقط

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
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<TrainingRecord> get filteredRecords {
    var filtered = trainingRecords;

    // تطبيق البحث
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
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

    // تطبيق الفلتر حسب الحالة
    if (_selectedFilter == 1) {
      filtered = filtered.where((record) => record.attendanceStatus == 'حاضر').toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((record) => record.attendanceStatus == 'غائب').toList();
    }

    return filtered;
  }

  Widget _buildTrainingTable() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل البيانات...'),
          ],
        ),
      );
    }

    if (filteredRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              searchQuery.isEmpty && _selectedFilter == 0
                  ? 'لا توجد سجلات تدريب'
                  : 'لا توجد نتائج للبحث',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            if (searchQuery.isEmpty && _selectedFilter == 0)
              ElevatedButton.icon(
                onPressed: _addNewTrainingRecord,
                icon: Icon(Icons.add),
                label: Text('إضافة سجل تدريب جديد'),
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
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.blue[50],
          ),
          columns: const [
            DataColumn(
              label: Text(
                'الاسم',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            DataColumn(
              label: Text(
                'الرقم العسكري',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            DataColumn(
              label: Text(
                'الدورة',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            DataColumn(
              label: Text(
                'نوع التدريب',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            DataColumn(
              label: Text(
                'التقييم',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            DataColumn(
              label: Text(
                'الحالة',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            DataColumn(
              label: Text(
                'الإجراءات',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ],
          rows: filteredRecords.map((record) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      record.personnelName ?? 'غير محدد',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.visibility, color: Colors.blue),
          onPressed: () => _viewTrainingDetails(record),
          tooltip: 'عرض التفاصيل',
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.orange),
          onPressed: () => _editTrainingRecord(record),
          tooltip: 'تعديل',
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(record),
          tooltip: 'حذف',
        ),
      ],
    );
  }

  Widget _buildEvaluationCell(int? score) {
    if (score == null) return Text('--', style: TextStyle(color: Colors.grey));

    Color scoreColor = Colors.red;
    String evaluationText = 'ضعيف';
    
    if (score >= 90) {
      scoreColor = Colors.green;
      evaluationText = 'ممتاز';
    } else if (score >= 80) {
      scoreColor = Colors.green;
      evaluationText = 'جيد جداً';
    } else if (score >= 70) {
      scoreColor = Colors.blue;
      evaluationText = 'جيد';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      evaluationText = 'مقبول';
    }

    return Tooltip(
      message: evaluationText,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scoreColor),
            ),
            child: Text(
              score.toString(),
              style: TextStyle(
                color: scoreColor, 
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final statusInfo = _getStatusInfo(status);
    return Chip(
      label: Text(
        statusInfo['text'],
        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: statusInfo['color'],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
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
      case 'منقطع':
        return {'text': 'منقطع', 'color': Colors.purple};
      default:
        return {'text': status ?? 'غير محدد', 'color': Colors.grey};
    }
  }

  void _showDeleteDialog(TrainingRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('تأكيد الحذف'),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف سجل التدريب لـ ${record.personnelName}؟',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTrainingRecord(record);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('حذف', style: TextStyle(color: Colors.white)),
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
        SnackBar(
          content: Text('تم حذف سجل التدريب بنجاح'),
          backgroundColor: Colors.green,
        )
      );
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
          title: Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue),
              SizedBox(width: 8),
              Text('إحصائيات التدريب'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatItem('إجمالي سجلات التدريب', stats['total_records']?.toString() ?? '0', Icons.list),
                _buildStatItem('المستنفرين المدربين', stats['trained_personnel']?.toString() ?? '0', Icons.people),
                _buildStatItem('الدورات النشطة', stats['active_courses']?.toString() ?? '0', Icons.school),
                _buildStatItem('متوسط التقييم', stats['average_score']?.toString() ?? '0', Icons.star),
                _buildStatItem('الحاضرين', stats['present_count']?.toString() ?? '0', Icons.check_circle),
                _buildStatItem('الغائبين', stats['absent_count']?.toString() ?? '0', Icons.cancel),
              ],
            ),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(value, style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: Text('الكل (${trainingRecords.length})'),
            selected: _selectedFilter == 0,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 0 : _selectedFilter;
              });
            },
          ),
          FilterChip(
            label: Text('حاضر فقط'),
            selected: _selectedFilter == 1,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 1 : 0;
              });
            },
          ),
          FilterChip(
            label: Text('غائب فقط'),
            selected: _selectedFilter == 2,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 2 : 0;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استمارة التدريب والتسليح - استمارة رقم (2)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
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
                value: 'add_course',
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('إضافة دورة جديدة'),
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
                value: 'add_instructor',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('إضافة مدرب جديد'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.purple),
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
                case 'add_course':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrainingCourseFormScreen()),
                  );
                  break;
                case 'instructors':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstructorsScreen()),
                  );
                  break;
                case 'add_instructor':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstructorFormScreen()),
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
                hintText: 'ابحث بالاسم، الرقم العسكري، أو اسم الدورة...',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
          _buildFilterChips(),
          Expanded(child: _buildTrainingTable()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTrainingRecord,
        child: Icon(Icons.add),
        tooltip: 'إضافة سجل تدريب جديد',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}