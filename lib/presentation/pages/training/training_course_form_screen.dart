import 'package:flutter/material.dart';
import '../../../core/models/training_course.dart';
import '../../../core/services/training_api.dart';

class TrainingCourseFormScreen extends StatefulWidget {
  final TrainingCourse? existingCourse;

  TrainingCourseFormScreen({this.existingCourse});

  @override
  _TrainingCourseFormScreenState createState() => _TrainingCourseFormScreenState();
}

class _TrainingCourseFormScreenState extends State<TrainingCourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TrainingCourse _course; // تغيير إلى late
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _courseTypes = [
    'تدريب أساسي',
    'تدريب متقدم',
    'تدريب متخصص',
    'دورة سلاح',
    'دورة قيادة',
    'دورة طبية',
    'دورة اتصالات'
  ];

  final List<String> _courseStatuses = [
    'مخطط',
    'قيد التنفيذ',
    'مكتمل',
    'ملغى'
  ];

  final List<String> _courseLevels = [
    'مبتدئ',
    'متوسط',
    'متقدم',
    'متخصص'
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingCourse != null;
    
    // تهيئة _course مع القيمة المناسبة
    if (_isEditMode) {
      _course = widget.existingCourse!;
    } else {
      _course = TrainingCourse(courseName: ''); // توفير المعامل المطلوب
    }
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isEditMode) {
          await TrainingApi.updateTrainingCourse(_course);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث الدورة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await TrainingApi.createTrainingCourse(_course);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء الدورة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'المعلومات الأساسية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم الدورة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.courseName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم الدورة';
                }
                return null;
              },
              onSaved: (value) => _course.courseName = value!,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع الدورة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _course.courseType,
              items: _courseTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _course.courseType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نوع الدورة';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'مستوى الدورة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _course.courseLevel,
              items: _courseLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _course.courseLevel = value;
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'مكان التدريب *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.location,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال مكان التدريب';
                }
                return null;
              },
              onSaved: (value) => _course.location = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الفئة المستهدفة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.targetGroup,
              onSaved: (value) => _course.targetGroup = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'الجدول الزمني',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تاريخ البدء',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _course.startDate != null 
                    ? '${_course.startDate!.year}-${_course.startDate!.month.toString().padLeft(2, '0')}-${_course.startDate!.day.toString().padLeft(2, '0')}'
                    : '',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _course.startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (selectedDate != null) {
                  setState(() {
                    _course.startDate = selectedDate;
                  });
                }
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تاريخ الانتهاء',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _course.endDate != null 
                    ? '${_course.endDate!.year}-${_course.endDate!.month.toString().padLeft(2, '0')}-${_course.endDate!.day.toString().padLeft(2, '0')}'
                    : '',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _course.endDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (selectedDate != null) {
                  setState(() {
                    _course.endDate = selectedDate;
                  });
                }
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'مدة الدورة (أيام)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              initialValue: _course.durationDays?.toString(),
              onSaved: (value) => _course.durationDays = int.tryParse(value ?? '0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'معلومات المدرب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم المدرب',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.instructorName,
              onSaved: (value) => _course.instructorName = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رتبة المدرب',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.instructorRank,
              onSaved: (value) => _course.instructorRank = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'وحدة المدرب',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.instructorUnit,
              onSaved: (value) => _course.instructorUnit = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'السعة والحالة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'العدد الأقصى للمشاركين',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              initialValue: _course.maxParticipants?.toString(),
              onSaved: (value) => _course.maxParticipants = int.tryParse(value ?? '0'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'حالة الدورة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _course.courseStatus ?? 'مخطط',
              items: _courseStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _course.courseStatus = value;
                });
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _course.isActive ?? true,
                  onChanged: (value) {
                    setState(() {
                      _course.isActive = value;
                    });
                  },
                ),
                Text('الدورة نشطة'),
                SizedBox(width: 20),
                Checkbox(
                  value: _course.certificateIssued ?? false,
                  onChanged: (value) {
                    setState(() {
                      _course.certificateIssued = value;
                    });
                  },
                ),
                Text('يتم إصدار شهادات'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'معلومات إضافية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم السلاح (إن وجد)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.trainingWeaponName,
              onSaved: (value) => _course.trainingWeaponName = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'المتطلبات الأساسية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.prerequisites,
              maxLines: 2,
              onSaved: (value) => _course.prerequisites = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'المنظم',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.organizer,
              onSaved: (value) => _course.organizer = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رابط المواد التدريبية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.courseMaterialUrl,
              onSaved: (value) => _course.courseMaterialUrl = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رابط نموذج التقييم',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _course.evaluationFormUrl,
              onSaved: (value) => _course.evaluationFormUrl = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              initialValue: _course.notes,
              maxLines: 3,
              onSaved: (value) => _course.notes = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: _isLoading ? SizedBox() : Icon(Icons.save),
              label: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(_isEditMode ? 'تحديث الدورة' : 'إنشاء الدورة'),
              onPressed: _isLoading ? null : _saveCourse,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.cancel),
              label: Text('إلغاء'),
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'تعديل الدورة التدريبية' : 'إضافة دورة تدريبية جديدة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildBasicInfoSection(),
              SizedBox(height: 16),
              _buildScheduleSection(),
              SizedBox(height: 16),
              _buildInstructorSection(),
              SizedBox(height: 16),
              _buildCapacitySection(),
              SizedBox(height: 16),
              _buildAdditionalInfoSection(),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}