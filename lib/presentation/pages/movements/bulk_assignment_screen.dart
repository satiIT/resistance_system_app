// lib/presentation/pages/dashboard/bulk_assignment_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class BulkAssignmentScreen extends StatefulWidget {
  const BulkAssignmentScreen({Key? key}) : super(key: key);

  @override
  _BulkAssignmentScreenState createState() => _BulkAssignmentScreenState();
}

class _BulkAssignmentScreenState extends State<BulkAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _assignmentData = {
    'movement_type': 'مهمة',
    'priority': 'عادية',
    'start_date': '',
    'end_date': '',
    'selected_personnel': [],
  };

  List<Map<String, dynamic>> _availablePersonnel = [];
  List<Map<String, dynamic>> _filteredPersonnel = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailablePersonnel();
  }

  void _loadAvailablePersonnel() {
    // بيانات وهمية للمستنفرين المتاحين
    setState(() {
      _availablePersonnel = [
        {
          'id': 1001,
          'name': 'أحمد محمد أحمد',
          'military_id': '1001',
          'unit': 'عهد الرجال 1',
          'status': 'نشط',
          'selected': false,
        },
        {
          'id': 1002,
          'name': 'محمد سعيد علي',
          'military_id': '1002',
          'unit': 'عهد الرجال 1',
          'status': 'نشط',
          'selected': false,
        },
        {
          'id': 1003,
          'name': 'عمر حسن محمد',
          'military_id': '1003',
          'unit': 'عهد الرجال 2',
          'status': 'نشط',
          'selected': false,
        },
        {
          'id': 1004,
          'name': 'خالد عبد الله',
          'military_id': '1004',
          'unit': 'أسود العرين 1',
          'status': 'نشط',
          'selected': false,
        },
      ];
      _filteredPersonnel = List.from(_availablePersonnel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('إسناد مهمة جماعية'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _submitAssignment),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        // نموذج بيانات المهمة
        Expanded(flex: 1, child: _buildAssignmentForm()),
        // قائمة المستنفرين
        Expanded(flex: 1, child: _buildPersonnelSelection()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAssignmentForm(),
          SizedBox(height: 24),
          _buildPersonnelSelection(),
        ],
      ),
    );
  }

  Widget _buildAssignmentForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بيانات المهمة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // نوع التحرك
            DropdownButtonFormField<String>(
              value: _assignmentData['movement_type'],
              decoration: InputDecoration(labelText: 'نوع التحرك'),
              items: ['مهمة', 'نقل', 'توزيع', 'دورة تدريبية', 'إجازة جماعية']
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _assignmentData['movement_type'] = value;
                });
              },
            ),
            SizedBox(height: 16),

            // الوحدة الهدف
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الوحدة / المكان الهدف',
                hintText: 'أدخل اسم الوحدة أو المنطقة',
              ),
              onChanged: (value) {
                setState(() {
                  _assignmentData['target_unit'] = value;
                });
              },
            ),
            SizedBox(height: 16),

            // أولوية المهمة
            DropdownButtonFormField<String>(
              value: _assignmentData['priority'],
              decoration: InputDecoration(labelText: 'أولوية المهمة'),
              items: ['عادية', 'عالية', 'عاجلة']
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _assignmentData['priority'] = value;
                });
              },
            ),
            SizedBox(height: 16),

            // تاريخ البدء
            InkWell(
              onTap: () => _selectDate(context, 'start_date'),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'تاريخ البدء',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _assignmentData['start_date']?.isEmpty ?? true
                          ? 'اختر التاريخ'
                          : _assignmentData['start_date'],
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // تاريخ الانتهاء
            InkWell(
              onTap: () => _selectDate(context, 'end_date'),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'تاريخ الانتهاء',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _assignmentData['end_date']?.isEmpty ?? true
                          ? 'اختر التاريخ'
                          : _assignmentData['end_date'],
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // وصف المهمة
            TextFormField(
              decoration: InputDecoration(
                labelText: 'وصف المهمة',
                hintText: 'أدخل تفاصيل المهمة المطلوبة',
              ),
              maxLines: 4,
              onChanged: (value) {
                setState(() {
                  _assignmentData['description'] = value;
                });
              },
            ),
            SizedBox(height: 16),

            // ملاحظات
            TextFormField(
              decoration: InputDecoration(
                labelText: 'ملاحظات إضافية',
                hintText: 'أي تعليمات أو ملاحظات خاصة',
              ),
              maxLines: 2,
              onChanged: (value) {
                setState(() {
                  _assignmentData['notes'] = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelSelection() {
    final int selectedCount = _availablePersonnel
        .where((p) => p['selected'] == true)
        .length;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اختيار المستنفرين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    'محدد: $selectedCount',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 16),

            // شريط البحث والتحكم
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو الرقم العسكري...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filterPersonnel,
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton(
                  icon: Icon(Icons.filter_list),
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('الجميع'), value: 'all'),
                    PopupMenuItem(child: Text('عهد الرجال 1'), value: 'unit1'),
                    PopupMenuItem(child: Text('عهد الرجال 2'), value: 'unit2'),
                    PopupMenuItem(child: Text('أسود العرين'), value: 'unit3'),
                  ],
                  onSelected: (value) => _filterByUnit(value),
                ),
              ],
            ),
            SizedBox(height: 16),

            // أزرار التحكم الجماعي
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectAll,
                    icon: Icon(Icons.check_box),
                    label: Text('تحديد الكل'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deselectAll,
                    icon: Icon(Icons.check_box_outline_blank),
                    label: Text('إلغاء الكل'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // قائمة المستنفرين
            SizedBox(
              height: math.min(400, MediaQuery.of(context).size.height * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _filteredPersonnel.length,
                itemBuilder: (context, index) {
                  final personnel = _filteredPersonnel[index];
                  return _buildPersonnelListItem(personnel);
                },
              ),
            ),

            // ملخص التحديد
            if (selectedCount > 0) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تم تحديد $selectedCount مستنفر',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _showSelectedSummary,
                      child: Text('عرض الملخص'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelListItem(Map<String, dynamic> personnel) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: personnel['selected'] ?? false,
        onChanged: (value) {
          setState(() {
            personnel['selected'] = value;
            // تحديث القائمة الرئيسية أيضاً
            final mainIndex = _availablePersonnel.indexWhere(
              (p) => p['id'] == personnel['id'],
            );
            if (mainIndex != -1) {
              _availablePersonnel[mainIndex]['selected'] = value;
            }
          });
        },
        title: Text(
          personnel['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرقم العسكري: ${personnel['military_id']}'),
            Text('الوحدة: ${personnel['unit']}'),
            Text(
              'الحالة: ${personnel['status']}',
              style: TextStyle(
                color: personnel['status'] == 'نشط'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
        secondary: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            personnel['military_id'].toString().substring(2),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _filterPersonnel(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPersonnel = List.from(_availablePersonnel);
      } else {
        _filteredPersonnel = _availablePersonnel.where((personnel) {
          return personnel['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              personnel['military_id'].toString().contains(query);
        }).toList();
      }
    });
  }

  void _filterByUnit(String unit) {
    // تطبيق التصفية حسب الوحدة
    // (سيتم تنفيذها بالكامل لاحقاً)
  }

  void _selectAll() {
    setState(() {
      for (var personnel in _availablePersonnel) {
        personnel['selected'] = true;
      }
      _filteredPersonnel = List.from(_availablePersonnel);
    });
  }

  void _deselectAll() {
    setState(() {
      for (var personnel in _availablePersonnel) {
        personnel['selected'] = false;
      }
      _filteredPersonnel = List.from(_availablePersonnel);
    });
  }

  void _showSelectedSummary() {
    final selectedPersonnel = _availablePersonnel
        .where((p) => p['selected'] == true)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('المستنفرين المحددين (${selectedPersonnel.length})'),
        content: Container(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: selectedPersonnel.length,
            itemBuilder: (context, index) {
              final personnel = selectedPersonnel[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(personnel['military_id'].toString().substring(2)),
                ),
                title: Text(personnel['name']),
                subtitle: Text(
                  '${personnel['unit']} - ${personnel['military_id']}',
                ),
              );
            },
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

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _assignmentData[field] = picked.toString().split(' ')[0];
      });
    }
  }

  void _submitAssignment() {
    final selectedPersonnel = _availablePersonnel
        .where((p) => p['selected'] == true)
        .toList();

    if (selectedPersonnel.isEmpty) {
      _showError('يرجى اختيار مستنفر واحد على الأقل');
      return;
    }

    if (_assignmentData['start_date']?.isEmpty ?? true) {
      _showError('يرجى تحديد تاريخ البدء');
      return;
    }

    // هنا سيتم حفظ البيانات في قاعدة البيانات
    _showSuccessDialog(selectedPersonnel.length);
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تم الإسناد بنجاح'),
        content: Text('تم إسناد المهمة بنجاح إلى $count مستنفر'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
