import 'package:flutter/material.dart';
import '../../../core/services/training_api.dart';

class InstructorFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingInstructor;

  InstructorFormScreen({this.existingInstructor});

  @override
  _InstructorFormScreenState createState() => _InstructorFormScreenState();
}

class _InstructorFormScreenState extends State<InstructorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _instructorData = {};
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _militaryRanks = [
    'ملازم',
    'ملازم أول',
    'نقيب',
    'رائد',
    'مقدم',
    'عقيد',
    'عميد',
    'لواء'
  ];

  final List<String> _specialties = [
    'تدريب عسكري',
    'تدريب سلاح',
    'تدريب قيادة',
    'تدريب اتصالات',
    'تدريب طبي',
    'تدريب هندسي',
    'تدريب استخبارات'
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingInstructor != null;
    if (_isEditMode) {
      _instructorData.addAll(widget.existingInstructor!);
    }
  }

  Future<void> _saveInstructor() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isEditMode) {
          await TrainingApi.updateInstructor(_instructorData['id'], _instructorData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث بيانات المدرب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await TrainingApi.createInstructor(_instructorData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إضافة المدرب بنجاح'),
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

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'المعلومات الشخصية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['full_name'],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الاسم الكامل';
                }
                return null;
              },
              onSaved: (value) => _instructorData['full_name'] = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رقم الهوية الوطنية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['national_id'],
              keyboardType: TextInputType.number,
              onSaved: (value) => _instructorData['national_id'] = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['phone_number'],
              keyboardType: TextInputType.phone,
              onSaved: (value) => _instructorData['phone_number'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'المعلومات المهنية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'الرتبة العسكرية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _instructorData['military_rank'],
              items: _militaryRanks.map((rank) {
                return DropdownMenuItem(
                  value: rank,
                  child: Text(rank),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _instructorData['military_rank'] = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار الرتبة العسكرية';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'التخصص',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _instructorData['specialty'],
              items: _specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _instructorData['specialty'] = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار التخصص';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الوحدة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['unit'],
              onSaved: (value) => _instructorData['unit'] = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'سنوات الخبرة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['experience_years']?.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _instructorData['experience_years'] = int.tryParse(value ?? '0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'المعلومات الجغرافية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'مكان الإقامة الحالي',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['current_residence'],
              onSaved: (value) => _instructorData['current_residence'] = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'العنوان التفصيلي',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['address'],
              maxLines: 2,
              onSaved: (value) => _instructorData['address'] = value,
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
                Icon(Icons.info, color: Colors.purple),
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
                labelText: 'المؤهلات العلمية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['qualifications'],
              maxLines: 2,
              onSaved: (value) => _instructorData['qualifications'] = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الدورات الخاصة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['special_courses'],
              maxLines: 2,
              onSaved: (value) => _instructorData['special_courses'] = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _instructorData['notes'],
              maxLines: 3,
              onSaved: (value) => _instructorData['notes'] = value,
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
                  : Text(_isEditMode ? 'تحديث البيانات' : 'حفظ المدرب'),
              onPressed: _isLoading ? null : _saveInstructor,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
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
        title: Text(_isEditMode ? 'تعديل بيانات المدرب' : 'إضافة مدرب جديد'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildPersonalInfoSection(),
              SizedBox(height: 16),
              _buildProfessionalInfoSection(),
              SizedBox(height: 16),
              _buildLocationInfoSection(),
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