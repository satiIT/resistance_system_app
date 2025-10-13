import 'package:flutter/material.dart';
import '../../../core/models/training_course.dart';
import '../../../core/services/training_api.dart';

class TrainingCoursesScreen extends StatefulWidget {
  @override
  _TrainingCoursesScreenState createState() => _TrainingCoursesScreenState();
}

class _TrainingCoursesScreenState extends State<TrainingCoursesScreen> {
  List<TrainingCourse> _courses = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await TrainingApi.getTrainingCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      _showError('خطأ في تحميل الدورات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<TrainingCourse> get _filteredCourses {
    if (_searchQuery.isEmpty) return _courses;
    return _courses.where((course) {
      return course.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (course.courseType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Widget _buildCourseCard(TrainingCourse course) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.school, color: Colors.white),
        ),
        title: Text(
          course.courseName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course.courseType != null) Text('النوع: ${course.courseType}'),
            if (course.instructorName != null) Text('المدرب: ${course.instructorName}'),
            if (course.startDate != null) Text('البدء: ${_formatDate(course.startDate!)}'),
            if (course.maxParticipants != null) Text('السعة: ${course.maxParticipants} متدرب'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'trainees', child: Text('عرض المتدربين')),
            PopupMenuItem(value: 'edit', child: Text('تعديل')),
            PopupMenuItem(value: 'enroll', child: Text('تسجيل متدربين')),
            PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'trainees':
                _viewTrainees(course);
                break;
              case 'edit':
                _editCourse(course);
                break;
              case 'enroll':
                _enrollTrainees(course);
                break;
              case 'delete':
                _deleteCourse(course);
                break;
            }
          },
        ),
        onTap: () => _viewTrainees(course),
      ),
    );
  }

  void _viewTrainees(TrainingCourse course) {
    // TODO: تنفيذ شاشة عرض متدربين الدورة
    _showError('عرض المتدربين قريباً');
  }

  void _editCourse(TrainingCourse course) {
    // TODO: تنفيذ شاشة تعديل الدورة
    _showError('تعديل الدورة قريباً');
  }

  void _enrollTrainees(TrainingCourse course) {
    // TODO: تنفيذ شاشة تسجيل متدربين جدد
    _showError('تسجيل متدربين قريباً');
  }

  void _deleteCourse(TrainingCourse course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل تريد حذف دورة "${course.courseName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(course.id!);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int courseId) async {
    try {
      await TrainingApi.deleteTrainingCourse(courseId);
      setState(() {
        _courses.removeWhere((course) => course.id == courseId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف الدورة بنجاح')),
      );
    } catch (e) {
      _showError('خطأ في حذف الدورة: $e');
    }
  }

  void _addNewCourse() {
    // TODO: تنفيذ شاشة إضافة دورة جديدة
    _showError('إضافة دورة جديدة قريباً');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الدورات التدريبية'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewCourse,
            tooltip: 'إضافة دورة جديدة',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'بحث في الدورات',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                    ? Center(child: Text('لا توجد دورات تدريبية'))
                    : ListView.builder(
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          return _buildCourseCard(_filteredCourses[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCourse,
        child: Icon(Icons.add),
        tooltip: 'إضافة دورة جديدة',
      ),
    );
  }
}