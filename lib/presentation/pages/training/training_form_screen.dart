import 'package:flutter/material.dart';
import '../../../core/models/training_record.dart';
import '../../../core/services/training_api.dart';

class TrainingFormScreen extends StatefulWidget {
  final TrainingRecord? existingRecord;

  TrainingFormScreen({this.existingRecord});

  @override
  _TrainingFormScreenState createState() => _TrainingFormScreenState();
}

class _TrainingFormScreenState extends State<TrainingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TrainingRecord _trainingRecord = TrainingRecord();
  bool isLoading = false;
  List<Map<String, dynamic>> _personnelList = [];
  List<String> _selectedAccessories = [];

  final List<String> _trainingTypes = [
    'مفتوح', 'أولي', 'متقدم', 'دورة سلاح معاون'
  ];

  final List<String> _specializedCourses = [
    'سواقة عربات',
    'دورة أمنية', 
    'دورة قيادة ميدان',
    'دورة استخبارات',
    'دورة اتصالات',
    'دورة إسعافات أولية'
  ];

  final List<String> _weaponAccessories = [
    'خزن', 'ذخيرة', 'كفوف', 'ماسورة احتياطي', 'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    _loadPersonnelData();
    if (widget.existingRecord != null) {
      _trainingRecord = TrainingRecord.fromJson(widget.existingRecord!.toJson());
      _selectedAccessories = _trainingRecord.weaponAccessories ?? [];
    }
  }

  Future<void> _loadPersonnelData() async {
    try {
      final personnel = await TrainingApi.getPersonnelList();
      setState(() {
        _personnelList = personnel;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل قائمة المستنفرين: $e')),
      );
    }
  }

  Widget _buildPersonnelSelector() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'اختر المستنفر',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _trainingRecord.personnelId?.toString(),
      onChanged: (String? newValue) {
        setState(() {
          _trainingRecord.personnelId = int.parse(newValue!);
          _loadPersonnelDataAutomatically();
        });
      },
      items: _personnelList.map<DropdownMenuItem<String>>((person) {
        return DropdownMenuItem<String>(
          value: person['id'].toString(),
          child: Text('${person['name']} - ${person['military_number']}'),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار المستنفر';
        }
        return null;
      },
    );
  }

  void _loadPersonnelDataAutomatically() {
    final selectedPerson = _personnelList.firstWhere(
      (person) => person['id'] == _trainingRecord.personnelId,
      orElse: () => {},
    );
    
    if (selectedPerson.isNotEmpty) {
      setState(() {
        _trainingRecord.personnelName = selectedPerson['name'];
        _trainingRecord.militaryNumber = selectedPerson['military_number'];
      });
    }
  }

  Widget _buildTrainingTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'نوع التدريب السابق',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _trainingRecord.previousTrainingType,
      onChanged: (String? newValue) {
        setState(() {
          _trainingRecord.previousTrainingType = newValue;
        });
      },
      items: _trainingTypes.map<DropdownMenuItem<String>>((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار نوع التدريب';
        }
        return null;
      },
    );
  }

  Widget _buildTrainingCampSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.military_tech, color: Colors.blue),
                SizedBox(width: 8),
                Text('التدريب بمعسكر عهد الرجال',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم الدورة التدريبية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _trainingRecord.trainingCampCourseName,
              onChanged: (value) {
                _trainingRecord.trainingCampCourseName = value;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم السلاح',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _trainingRecord.trainingCampWeaponName,
              onChanged: (value) {
                _trainingRecord.trainingCampWeaponName = value;
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'مدة الدورة (أيام)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _trainingRecord.trainingCampDuration?.toString(),
                    onChanged: (value) {
                      _trainingRecord.trainingCampDuration = int.tryParse(value);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'موقع ضرب النار',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    initialValue: _trainingRecord.trainingCampFiringRange,
                    onChanged: (value) {
                      _trainingRecord.trainingCampFiringRange = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializedCoursesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.green),
                SizedBox(width: 8),
                Text('الدورات المتخصصة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع الدورة المتخصصة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _trainingRecord.specializedCourseType,
              onChanged: (String? newValue) {
                setState(() {
                  _trainingRecord.specializedCourseType = newValue;
                });
              },
              items: _specializedCourses.map<DropdownMenuItem<String>>((String course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تفاصيل إضافية عن الدورة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              initialValue: _trainingRecord.specializedCourseDetails,
              onChanged: (value) {
                _trainingRecord.specializedCourseDetails = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaponSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red),
                SizedBox(width: 8),
                Text('بيانات التسليح',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'نوع السلاح المستلم',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    initialValue: _trainingRecord.weaponTypeReceived,
                    onChanged: (value) {
                      _trainingRecord.weaponTypeReceived = value;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'رقم السلاح',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    initialValue: _trainingRecord.weaponNumber,
                    onChanged: (value) {
                      _trainingRecord.weaponNumber = value;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('ملحقات السلاح:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _weaponAccessories.map((accessory) {
                return FilterChip(
                  label: Text(accessory),
                  selected: _selectedAccessories.contains(accessory),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedAccessories.add(accessory);
                      } else {
                        _selectedAccessories.remove(accessory);
                      }
                      _trainingRecord.weaponAccessories = _selectedAccessories;
                    });
                  },
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
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
              icon: isLoading ? SizedBox() : Icon(Icons.save),
              label: isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('حفظ البيانات'),
              onPressed: isLoading ? null : _saveTrainingRecord,
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
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrainingRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        isLoading = true;
      });

      try {
        if (widget.existingRecord == null) {
          await TrainingApi.createTrainingRecord(_trainingRecord);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حفظ سجل التدريب بنجاح')),
          );
        } else {
          await TrainingApi.updateTrainingRecord(_trainingRecord);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث سجل التدريب بنجاح')),
          );
        }
        
        Navigator.pop(context, true);
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord == null ? 
            'إضافة سجل تدريب جديد' : 'تعديل سجل تدريب'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildPersonnelSelector(),
              SizedBox(height: 16),
              _buildTrainingTypeDropdown(),
              SizedBox(height: 16),
              _buildTrainingCampSection(),
              SizedBox(height: 16),
              _buildSpecializedCoursesSection(),
              SizedBox(height: 16),
              _buildWeaponSection(),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}