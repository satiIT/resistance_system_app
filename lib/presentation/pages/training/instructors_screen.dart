import 'package:flutter/material.dart';
import '../../../core/services/training_api.dart';
import 'instructor_form_screen.dart';

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
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.green,
      ),
    );
  }

  List<dynamic> get _filteredInstructors {
    if (_searchQuery.isEmpty) return _instructors;
    return _instructors.where((instructor) {
      return instructor['full_name']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
             instructor['specialty']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
             instructor['military_rank']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            PopupMenuItem(
              value: 'edit', 
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
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
          onSelected: (value) {
            if (value == 'edit') {
              _editInstructor(instructor);
            } else if (value == 'delete') {
              _deleteInstructor(instructor);
            }
          },
        ),
        onTap: () => _showInstructorDetails(instructor),
      ),
    );
  }

  void _showInstructorDetails(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('تفاصيل المدرب'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('الاسم الكامل', instructor['full_name']),
              _buildDetailItem('الرتبة', instructor['military_rank']),
              _buildDetailItem('التخصص', instructor['specialty']),
              _buildDetailItem('الوحدة', instructor['unit']),
              _buildDetailItem('مكان الإقامة', instructor['current_residence']),
              _buildDetailItem('رقم الهاتف', instructor['phone_number']),
              _buildDetailItem('سنوات الخبرة', instructor['experience_years']?.toString()),
              _buildDetailItem('المؤهلات', instructor['qualifications']),
              if (instructor['notes'] != null)
                _buildDetailItem('ملاحظات', instructor['notes']),
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
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'غير محدد',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _editInstructor(Map<String, dynamic> instructor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstructorFormScreen(existingInstructor: instructor),
      ),
    ).then((_) => _loadInstructors());
  }

  void _deleteInstructor(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text('هل تريد حذف المدرب ${instructor['full_name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(instructor['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: TextStyle(color: Colors.white)),
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
      _showSuccess('تم حذف المدرب بنجاح');
    } catch (e) {
      _showError('خطأ في حذف المدرب: $e');
    }
  }

  void _addNewInstructor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InstructorFormScreen()),
    ).then((_) => _loadInstructors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المدربين'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewInstructor,
            tooltip: 'إضافة مدرب جديد',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadInstructors,
            tooltip: 'تحديث البيانات',
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
                hintText: 'ابحث بالاسم، التخصص، أو الرتبة...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
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
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          if (!_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.people, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'إجمالي المدربين: ${_filteredInstructors.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري تحميل بيانات المدربين...'),
                      ],
                    ),
                  )
                : _filteredInstructors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'لا توجد مدربين مسجلين'
                                  : 'لا توجد نتائج للبحث',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            if (_searchQuery.isEmpty)
                              ElevatedButton.icon(
                                onPressed: _addNewInstructor,
                                icon: Icon(Icons.add),
                                label: Text('إضافة مدرب جديد'),
                              ),
                          ],
                        ),
                      )
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}