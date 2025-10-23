// lib/presentation/pages/dashboard/bulk_assignment_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/core/services/movements_service.dart';
import 'dart:math' as math;
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/services/personnel_service.dart';

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
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAvailablePersonnel();
  }

  Future<void> _loadAvailablePersonnel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic> response = await PersonnelService.getAllPersonnel();
      
      setState(() {
        _availablePersonnel = response.map<Map<String, dynamic>>((personnel) {
          // تحويل البيانات من dynamic إلى Map<String, dynamic>
          final Map<String, dynamic> personnelMap = personnel is Map ? Map<String, dynamic>.from(personnel) : {};
          
          // معالجة ID ليكون رقم صحيح
          final dynamic id = personnelMap['id'];
          final int personnelId = id is int ? id : (id is String ? int.tryParse(id) ?? 0 : 0);
          
          // بناء الاسم الكامل
          final String fullName = '${personnelMap['first_name'] ?? ''} '
              '${personnelMap['second_name'] ?? ''} '
              '${personnelMap['third_name'] ?? ''} '
              '${personnelMap['fourth_name'] ?? ''}'.trim();
          
          return {
            'id': personnelId,
            'name': fullName.isNotEmpty ? fullName : 'غير معروف',
            'military_id': personnelMap['military_id']?.toString() ?? 'غير معروف',
            'unit': personnelMap['unit'] ?? 'غير محدد',
            'status': personnelMap['status'] ?? 'غير معروف',
            'selected': false,
            // حفظ البيانات الأصلية للرجوع إليها
            'original_data': personnelMap,
          };
        }).where((personnel) => personnel['id'] > 0).toList(); // استبعاد الـ IDs غير الصالحة
        
        _filteredPersonnel = List.from(_availablePersonnel);
      });
      
      print('✅ تم تحميل ${_availablePersonnel.length} مستنفر');
    } catch (e) {
      print('❌ خطأ في تحميل البيانات: $e');
      _showError('فشل في تحميل بيانات المستنفرين: $e');
      
      // استخدام بيانات وهمية كبديل
      _loadMockPersonnelData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMockPersonnelData() {
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
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('إسناد مهمة جماعية'),
        centerTitle: true,
        actions: [
          if (!_isSubmitting)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _submitAssignment,
              tooltip: 'حفظ الإسناد',
            ),
          if (_isSubmitting)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري تحميل بيانات المستنفرين...'),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Form(
                    key: _formKey,
                    child: isWeb ? _buildWebLayout(constraints) : _buildMobileLayout(constraints),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildWebLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // نموذج بيانات المهمة
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: _buildAssignmentForm(),
          ),
        ),
        // قائمة المستنفرين
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: _buildPersonnelSelection(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              _buildAssignmentForm(),
              SizedBox(height: 20),
              _buildPersonnelSelection(),
              SizedBox(height: 20),
            ],
          ),
        ),
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
                  _assignmentData['to_location'] = value;
                });
              },
            ),
            SizedBox(height: 16),

            // مكان الانطلاق
            TextFormField(
              decoration: InputDecoration(
                labelText: 'مكان الانطلاق',
                hintText: 'أدخل مكان الانطلاق',
              ),
              onChanged: (value) {
                setState(() {
                  _assignmentData['from_location'] = value;
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
              onTap: () => _selectDate(context, 'movement_date'),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'تاريخ البدء',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _assignmentData['movement_date']?.isEmpty ?? true
                          ? 'اختر التاريخ'
                          : _assignmentData['movement_date'],
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
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _assignmentData['mission_description'] = value;
                });
              },
            ),
            SizedBox(height: 16),

            // وسيلة النقل
            TextFormField(
              decoration: InputDecoration(
                labelText: 'وسيلة النقل',
                hintText: 'أدخل وسيلة النقل',
              ),
              onChanged: (value) {
                setState(() {
                  _assignmentData['transport_mode'] = value;
                });
              },
            ),
            SizedBox(height: 16),

            // مصادق بواسطة
            TextFormField(
              decoration: InputDecoration(
                labelText: 'مصادق بواسطة',
                hintText: 'أدخل اسم المصادق',
              ),
              onChanged: (value) {
                setState(() {
                  _assignmentData['authorized_by'] = value;
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
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadAvailablePersonnel,
                  tooltip: 'تحديث القائمة',
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
            Container(
              height: 300,
              child: _filteredPersonnel.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'لا توجد بيانات',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
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
    // دالة مساعدة لعرض الرقم العسكري في CircleAvatar
    String getMilitaryIdDisplay() {
      final militaryId = personnel['military_id']?.toString() ?? '000';
      if (militaryId.length <= 2) {
        return militaryId;
      }
      return militaryId.substring(militaryId.length - 2);
    }

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
          personnel['name'] ?? 'غير معروف',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرقم العسكري: ${personnel['military_id'] ?? 'غير معروف'}', 
                style: TextStyle(fontSize: 12)),
            Text('الوحدة: ${personnel['unit'] ?? 'غير محدد'}', 
                style: TextStyle(fontSize: 12)),
            Text(
              'الحالة: ${personnel['status'] ?? 'غير معروف'}',
              style: TextStyle(
                color: (personnel['status'] == 'نشط' || personnel['status'] == 'مستنفر')
                    ? Colors.green
                    : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
        secondary: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            getMilitaryIdDisplay(),
            style: TextStyle(color: Colors.white, fontSize: 10),
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
          return personnel['name']?.toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ??
              false ||
              personnel['military_id']!.toString().contains(query) ?? false;
        }).toList();
      }
    });
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
                  child: Text(
                    (personnel['military_id']?.toString() ?? '000').substring(
                        (personnel['military_id']?.toString().length ?? 3) - 2),
                  ),
                ),
                title: Text(personnel['name'] ?? 'غير معروف'),
                subtitle: Text(
                  '${personnel['unit'] ?? 'غير محدد'} - ${personnel['military_id'] ?? 'غير معروف'}',
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _assignmentData[field] = picked.toString().split(' ')[0];
      });
    }
  }

  // في ملف bulk_assignment_screen.dart - تحديث دالة _submitAssignment
Future<void> _submitAssignment() async {
  final selectedPersonnel = _availablePersonnel
      .where((p) => p['selected'] == true)
      .toList();

  if (selectedPersonnel.isEmpty) {
    _showError('يرجى اختيار مستنفر واحد على الأقل');
    return;
  }

  if (_assignmentData['movement_date']?.isEmpty ?? true) {
    _showError('يرجى تحديد تاريخ البدء');
    return;
  }

  if (_assignmentData['to_location']?.isEmpty ?? true) {
    _showError('يرجى تحديد الوحدة الهدف');
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    // تحضير بيانات الإسناد الجماعي
    List<Map<String, dynamic>> assignments = [];
    
    for (var personnel in selectedPersonnel) {
      // Ensure personnel_id is properly typed
      final personnelId = personnel['id'] is int ? personnel['id'] : int.tryParse(personnel['id']?.toString() ?? '0');
      
      if (personnelId == null || personnelId == 0) {
        _showError('رقم المستنفر غير صالح: ${personnel['name']}');
        continue;
      }

      assignments.add({
        'personnel_id': personnelId,
        'movement_type': _assignmentData['movement_type'],
        'movement_date': _assignmentData['movement_date'],
        'from_location': _assignmentData['from_location'],
        'to_location': _assignmentData['to_location'],
        'purpose': _assignmentData['mission_description'], // سيتم حفظه في mission_description
        'authorized_by': _assignmentData['authorized_by'],
        'transport_mode': _assignmentData['transport_mode'],
        'status': 'نشط',
        'notes': _assignmentData['notes'],
      });
    }

    if (assignments.isEmpty) {
      _showError('لا توجد بيانات صالحة للإرسال');
      return;
    }

    // إرسال البيانات إلى API
    final results = await MovementsService.createBulkAssignments(assignments);
    
    _showSuccessDialog(selectedPersonnel.length);
    
  } catch (e) {
    _showError('خطأ في الإسناد: $e');
  } finally {
    setState(() {
      _isSubmitting = false;
    });
  }
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }
}