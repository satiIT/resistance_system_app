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
  bool _isSearching = false;

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

  Widget _buildInstructorTableRow(Map<String, dynamic> instructor, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey[50]! : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.work, size: 14, color: Colors.blue),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'التخصص: ${instructor['specialty'] ?? 'غير محدد'}',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.military_tech, size: 14, color: Colors.orange),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'الرتبة: ${instructor['military_rank'] ?? 'غير محدد'}',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'المقر: ${instructor['current_residence'] ?? 'غير محدد'}',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.blue),
          itemBuilder: (context) => [
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
          onSelected: (value) {
            if (value == 'view') {
              _showInstructorDetails(instructor);
            } else if (value == 'edit') {
              _editInstructor(instructor);
            } else if (value == 'delete') {
              _deleteInstructor(instructor);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInstructorGridItem(Map<String, dynamic> instructor) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _showInstructorDetails(instructor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      instructor['full_name']?.toString().substring(0, 1) ?? '?',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instructor['full_name'] ?? 'غير معروف',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildInfoRow(Icons.work, 'التخصص', instructor['specialty']),
              _buildInfoRow(Icons.military_tech, 'الرتبة', instructor['military_rank']),
              _buildInfoRow(Icons.location_on, 'المقر', instructor['current_residence']),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () => _showInstructorDetails(instructor),
                    tooltip: 'عرض التفاصيل',
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editInstructor(instructor),
                    tooltip: 'تعديل',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteInstructor(instructor),
                    tooltip: 'حذف',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value ?? 'غير محدد',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showInstructorDetails(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'تفاصيل المدرب',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
            child: Text('إغلاق', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50]!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? 'غير محدد',
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
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
        title: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        content: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_forever, size: 48, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'هل تريد حذف المدرب',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                instructor['full_name'] ?? 'غير معروف',
                style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'هذا الإجراء لا يمكن التراجع عنه',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(instructor['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
            tooltip: 'بحث',
          ),
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
          // Search Section
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isSearching ? 80 : 0,
            child: _isSearching
                ? Padding(
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
                        fillColor: Colors.grey[50]!,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  )
                : SizedBox.shrink(),
          ),

          // Header Info
          if (!_isLoading)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50]!,
                border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                  Chip(
                    label: Text(
                      _filteredInstructors.length == _instructors.length 
                          ? 'جميع المدربين' 
                          : 'نتائج البحث',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.blue),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل بيانات المدربين...',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : _filteredInstructors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 80, color: Colors.grey[400]!),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'لا توجد مدربين مسجلين'
                                  : 'لا توجد نتائج للبحث',
                              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'انقر على زر (+) لإضافة مدرب جديد'
                                  : 'حاول البحث بكلمات أخرى',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            SizedBox(height: 20),
                            if (_searchQuery.isEmpty)
                              ElevatedButton.icon(
                                onPressed: _addNewInstructor,
                                icon: Icon(Icons.add),
                                label: Text('إضافة مدرب جديد'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredInstructors.length,
                        itemBuilder: (context, index) {
                          return _buildInstructorTableRow(_filteredInstructors[index], index);
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
        elevation: 4,
      ),
    );
  }
}