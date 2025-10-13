import 'package:flutter/material.dart';
import '../../../core/services/training_api.dart';

class InstructorsScreen extends StatefulWidget {
  @override
  _InstructorsScreenState createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  List<dynamic> _instructors = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  Future<void> _loadInstructors() async {
    try {
      final response = await TrainingApi.getInstructors();
      setState(() {
        _instructors = response;
        _isLoading = false;
      });
    } catch (e) {
      _showError('خطأ في تحميل المدربين: $e');
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

  List<dynamic> get _filteredInstructors {
    if (_searchQuery.isEmpty) return _instructors;
    return _instructors.where((instructor) {
      return instructor['full_name']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
             instructor['specialty']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
    }).toList();
  }

  Widget _buildInstructorCard(Map<String, dynamic> instructor) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            instructor['full_name']?.toString().substring(0, 1) ?? '?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          instructor['full_name'] ?? 'غير معروف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (instructor['specialty'] != null) 
              Text('التخصص: ${instructor['specialty']}'),
            if (instructor['military_rank'] != null)
              Text('الرتبة: ${instructor['military_rank']}'),
            if (instructor['current_residence'] != null)
              Text('المقر: ${instructor['current_residence']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('تعديل')),
            PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editInstructor(instructor);
            } else if (value == 'delete') {
              _deleteInstructor(instructor);
            }
          },
        ),
      ),
    );
  }

  void _editInstructor(Map<String, dynamic> instructor) {
    // TODO: تنفيذ شاشة تعديل المدرب
    _showError('ميزة التعديل قريباً');
  }

  void _deleteInstructor(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المدرب ${instructor['full_name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(instructor['id']);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int instructorId) async {
    try {
      await TrainingApi.deleteInstructor(instructorId);
      setState(() {
        _instructors.removeWhere((instructor) => instructor['id'] == instructorId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف المدرب بنجاح')),
      );
    } catch (e) {
      _showError('خطأ في حذف المدرب: $e');
    }
  }

  void _addNewInstructor() {
    // TODO: تنفيذ شاشة إضافة مدرب جديد
    _showError('ميزة الإضافة قريباً');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المدربين'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewInstructor,
            tooltip: 'إضافة مدرب جديد',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'بحث في المدربين',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredInstructors.isEmpty
                    ? Center(child: Text('لا توجد مدربين'))
                    : ListView.builder(
                        itemCount: _filteredInstructors.length,
                        itemBuilder: (context, index) {
                          return _buildInstructorCard(_filteredInstructors[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewInstructor,
        child: Icon(Icons.add),
        tooltip: 'إضافة مدرب جديد',
      ),
    );
  }
}