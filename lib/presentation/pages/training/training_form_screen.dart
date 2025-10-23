import 'package:flutter/material.dart';
import './../../../core/models/training_record.dart';
import '../../../core/models/training_course.dart';
import '../../../core/services/training_api.dart';

class TrainingFormScreen extends StatefulWidget {
  final TrainingRecord? existingRecord;

  TrainingFormScreen({this.existingRecord});

  @override
  _TrainingFormScreenState createState() => _TrainingFormScreenState();
}

class _TrainingFormScreenState extends State<TrainingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TrainingRecord _trainingRecord;
  bool isLoading = false;
  bool isInitialized = false;

  List<Map<String, dynamic>> _personnelList = [];
  List<TrainingCourse> _coursesList = [];
  List<String> _trainingTypes = ['مفتوح', 'أولي', 'متقدم', 'دورة سلاح معاون'];
  List<String> _attendanceStatuses = ['حاضر', 'غائب', 'متأخر', 'منقطع'];
  List<String> _specializedCourses = [
    'سواقة عربات',
    'دورة أمنية', 
    'دورة قيادة ميدان',
    'دورة استخبارات',
    'دورة اتصالات',
    'دورة إسعافات أولية'
  ];

  // List to store selected personnel
  List<Map<String, dynamic>> _selectedPersonnel = [];

  @override
  void initState() {
    super.initState();
    _trainingRecord = widget.existingRecord ?? TrainingRecord(
      personnelId: 0,
      courseId: 0,
    );
    
    // If editing existing record, add the existing personnel to selected list
    if (widget.existingRecord != null && widget.existingRecord!.personnelId != 0) {
      // We'll populate this after loading personnel data
    }
    
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final [personnel, courses] = await Future.wait([
        TrainingApi.getPersonnelList(),
        TrainingApi.getTrainingCourses(),
      ]);

      setState(() {
        _personnelList = personnel.cast<Map<String, dynamic>>();
        _coursesList = courses.cast<TrainingCourse>();
        
        // If editing existing record, find and add the existing personnel
        if (widget.existingRecord != null && widget.existingRecord!.personnelId != 0) {
          var existingPerson = _personnelList.firstWhere(
            (person) => person['id'] == widget.existingRecord!.personnelId,
            orElse: () => {},
          );
          if (existingPerson.isNotEmpty) {
            _selectedPersonnel.add(existingPerson);
          }
        }
        
        isInitialized = true;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
      setState(() {
        isInitialized = true;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildPersonnelSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.blue),
                SizedBox(width: 8),
                Text('إضافة المستنفرين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Selected personnel list
            if (_selectedPersonnel.isNotEmpty) ...[
              Text('المستنفرين المضافين:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              ..._selectedPersonnel.map((person) => Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey[50],
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text('${person['name']}'),
                  subtitle: Text('الرقم العسكري: ${person['military_number']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedPersonnel.remove(person);
                      });
                    },
                  ),
                ),
              )).toList(),
              SizedBox(height: 16),
            ],
            
            // Add personnel dropdown
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: 'اختر مستنفر لإضافته',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: null,
              onChanged: (Map<String, dynamic>? newValue) {
                if (newValue != null) {
                  // Check if already selected
                  bool alreadyExists = _selectedPersonnel.any(
                    (person) => person['id'] == newValue['id']
                  );
                  
                  if (!alreadyExists) {
                    setState(() {
                      _selectedPersonnel.add(newValue);
                    });
                    _showSuccessSnackBar('تم إضافة ${newValue['name']}');
                  } else {
                    _showErrorSnackBar('${newValue['name']} مضاف مسبقاً');
                  }
                }
              },
              items: _personnelList.map<DropdownMenuItem<Map<String, dynamic>>>((person) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: person,
                  child: Text('${person['name']} - ${person['military_number']}'),
                );
              }).toList(),
            ),
            
            SizedBox(height: 8),
            if (_selectedPersonnel.isNotEmpty)
              Text(
                'عدد المستنفرين المضافين: ${_selectedPersonnel.length}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSelector() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: 'اختر الدورة التدريبية',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: _trainingRecord.courseId != 0 ? _trainingRecord.courseId : null,
      onChanged: (int? newValue) {
        setState(() {
          _trainingRecord.courseId = newValue ?? 0;
        });
      },
      items: _coursesList.map<DropdownMenuItem<int>>((course) {
        return DropdownMenuItem<int>(
          value: course.id,
          child: Text(course.courseName),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value == 0) {
          return 'يرجى اختيار الدورة التدريبية';
        }
        return null;
      },
    );
  }

  Widget _buildTrainingTypeSection() {
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
                Text('نوع التدريب السابق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع التدريب السابق',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _trainingRecord.priorTrainingType,
              onChanged: (String? newValue) {
                setState(() {
                  _trainingRecord.priorTrainingType = newValue;
                });
              },
              items: _trainingTypes.map<DropdownMenuItem<String>>((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingDetailsSection() {
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
                Text('تفاصيل التدريب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'معسكر التدريب',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _trainingRecord.trainingCampName,
              onChanged: (value) {
                _trainingRecord.trainingCampName = value;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'موقع ضرب النار',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _trainingRecord.firingLocation,
              onChanged: (value) {
                _trainingRecord.firingLocation = value;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'نوع السلاح',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _trainingRecord.weaponType,
              onChanged: (value) {
                _trainingRecord.weaponType = value;
              },
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
                Icon(Icons.engineering, color: Colors.orange),
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
                labelText: 'نوع تدريب السلاح',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _trainingRecord.weaponTrainingType,
              onChanged: (value) {
                _trainingRecord.weaponTrainingType = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.purple),
                SizedBox(width: 8),
                Text('التقييم والمتابعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'حالة الحضور',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _trainingRecord.attendanceStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _trainingRecord.attendanceStatus = newValue;
                });
              },
              items: _attendanceStatuses.map<DropdownMenuItem<String>>((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'نتيجة التقييم (0-100)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              initialValue: _trainingRecord.evaluationScore?.toString(),
              onChanged: (value) {
                _trainingRecord.evaluationScore = int.tryParse(value);
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _trainingRecord.certificateReceived ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      _trainingRecord.certificateReceived = value ?? false;
                    });
                  },
                ),
                Text('تم استلام الشهادة'),
              ],
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
              maxLines: 3,
              initialValue: _trainingRecord.notes,
              onChanged: (value) {
                _trainingRecord.notes = value;
              },
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
      // Validate that at least one personnel is selected
      if (_selectedPersonnel.isEmpty) {
        _showErrorSnackBar('يرجى إضافة مستنفر واحد على الأقل');
        return;
      }

      _formKey.currentState!.save();
      
      setState(() {
        isLoading = true;
      });

      try {
        if (widget.existingRecord == null) {
          // Create multiple records for each selected personnel
          for (var person in _selectedPersonnel) {
            var record = TrainingRecord(
              personnelId: person['id'],
              courseId: _trainingRecord.courseId,
              priorTrainingType: _trainingRecord.priorTrainingType,
              trainingCampName: _trainingRecord.trainingCampName,
              firingLocation: _trainingRecord.firingLocation,
              weaponType: _trainingRecord.weaponType,
              specializedCourseType: _trainingRecord.specializedCourseType,
              weaponTrainingType: _trainingRecord.weaponTrainingType,
              attendanceStatus: _trainingRecord.attendanceStatus,
              evaluationScore: _trainingRecord.evaluationScore,
              certificateReceived: _trainingRecord.certificateReceived,
              notes: _trainingRecord.notes,
            );
            await TrainingApi.createTrainingRecord(record);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ ${_selectedPersonnel.length} سجل تدريب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // For existing records, we'll update the single record
          // You might want to modify this based on your requirements
          await TrainingApi.updateTrainingRecord(_trainingRecord);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث سجل التدريب بنجاح')),
          );
        }
        
        Navigator.pop(context, true);
        
      } catch (e) {
        _showErrorSnackBar('حدث خطأ أثناء الحفظ: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('تحميل...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              _buildCourseSelector(),
              SizedBox(height: 16),
              _buildTrainingTypeSection(),
              SizedBox(height: 16),
              _buildTrainingDetailsSection(),
              SizedBox(height: 16),
              _buildSpecializedCoursesSection(),
              SizedBox(height: 16),
              _buildEvaluationSection(),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}