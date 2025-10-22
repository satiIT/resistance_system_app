import 'package:flutter/material.dart';
import './../../../core/services/personnel_service.dart';

class PersonnelFormScreen extends StatefulWidget {
  final String? personnelId;
  final Map<String, dynamic>? initialData;

  PersonnelFormScreen({this.personnelId, this.initialData});

  @override
  _PersonnelFormScreenState createState() => _PersonnelFormScreenState();
}

class _PersonnelFormScreenState extends State<PersonnelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditing = false;

  // بيانات النموذج
  final Map<String, dynamic> _formData = {
    'first_name': '',
    'second_name': '',
    'third_name': '',
    'fourth_name': '',
    'national_id': '',
    'birth_date': '',
    'gender': 'ذكر',
    'marital_status': 'أعزب',
    'military_id': '',
    'rank': '',
    'unit': '',
    'status': 'نشط',
    'enlistment_date': '',
    'phone_number': '',
    'email': '',
    'address': '',
    'emergency_contact_phone': '',
    'mother_full_name': '',
    'wives_count': '0',
    'children_count': '0',
    'dependents_count': '0',
    'state': '',
    'locality': '',
    'administrative_unit': '',
    'city_village': '',
    'education_level': '',
    'occupation': '',
    'skills': '',
    'health_conditions': '',
  };

  @override
  void initState() {
    super.initState();
    _isEditing = widget.personnelId != null;
    
    // إذا كان هناك بيانات أولية (للتعديل)، نقوم بملئها
    if (widget.initialData != null) {
      _formData.addAll(widget.initialData!);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isEditing) {
          await PersonnelService.updatePersonnel(widget.personnelId!, _formData);
        } else {
          await PersonnelService.createPersonnel(_formData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تحديث البيانات بنجاح' : 'تم إضافة المستنفر بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
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

  Widget _buildTextFormField(String label, String fieldName, {bool isRequired = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        initialValue: _formData[fieldName]?.toString(),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
        onSaved: (value) {
          _formData[fieldName] = value;
        },
      ),
    );
  }

  Widget _buildDropdownFormField(String label, String fieldName, List<String> options) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        value: _formData[fieldName]?.toString() ?? options.first,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _formData[fieldName] = value;
          });
        },
        onSaved: (value) {
          _formData[fieldName] = value;
        },
      ),
    );
  }

  Widget _buildNumberFormField(String label, String fieldName) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: TextInputType.number,
        initialValue: _formData[fieldName]?.toString(),
        onSaved: (value) {
          _formData[fieldName] = value;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل مستنفر' : 'إضافة مستنفر جديد'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // المعلومات الأساسية
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعلومات الأساسية',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            _buildTextFormField('الاسم الأول', 'first_name', isRequired: true),
                            _buildTextFormField('الاسم الثاني', 'second_name', isRequired: true),
                            _buildTextFormField('الاسم الثالث', 'third_name'),
                            _buildTextFormField('الاسم الرابع', 'fourth_name'),
                            _buildTextFormField('الرقم القومي', 'national_id', isRequired: true),
                            _buildTextFormField('تاريخ الميلاد', 'birth_date'),
                            _buildDropdownFormField('الجنس', 'gender', ['ذكر', 'أنثى']),
                            _buildDropdownFormField('الحالة الاجتماعية', 'marital_status', ['أعزب', 'متزوج', 'مطلق', 'أرمل']),
                          ],
                        ),
                      ),
                    ),

                    // المعلومات العسكرية
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعلومات العسكرية',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            _buildTextFormField('الرقم العسكري', 'military_id'),
                            _buildTextFormField('الرتبة', 'rank'),
                            _buildTextFormField('الوحدة', 'unit'),
                            _buildDropdownFormField('الحالة', 'status', ['نشط', 'غير نشط', 'متقاعد', 'شهيد', 'جريح']),
                            _buildTextFormField('تاريخ التجنيد', 'enlistment_date'),
                          ],
                        ),
                      ),
                    ),

                    // معلومات الاتصال
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات الاتصال',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            _buildTextFormField('رقم الهاتف', 'phone_number'),
                            _buildTextFormField('البريد الإلكتروني', 'email'),
                            _buildTextFormField('العنوان', 'address'),
                            _buildTextFormField('رقم هاتف الطوارئ', 'emergency_contact_phone'),
                          ],
                        ),
                      ),
                    ),

                    // المعلومات الجغرافية
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعلومات الجغرافية',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            _buildTextFormField('الولاية', 'state'),
                            _buildTextFormField('المحلية', 'locality'),
                            _buildTextFormField('الوحدة الإدارية', 'administrative_unit'),
                            _buildTextFormField('المدينة/القرية', 'city_village'),
                          ],
                        ),
                      ),
                    ),

                    // معلومات إضافية
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات إضافية',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            _buildTextFormField('المستوى التعليمي', 'education_level'),
                            _buildTextFormField('المهنة', 'occupation'),
                            _buildTextFormField('المهارات', 'skills'),
                            _buildTextFormField('الحالات الصحية', 'health_conditions'),
                            _buildTextFormField('اسم الأم بالكامل', 'mother_full_name'),
                            _buildNumberFormField('عدد الزوجات', 'wives_count'),
                            _buildNumberFormField('عدد الأطفال', 'children_count'),
                            _buildNumberFormField('عدد المعالين', 'dependents_count'),
                          ],
                        ),
                      ),
                    ),

                    // زر الحفظ
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditing ? 'تحديث البيانات' : 'إضافة المستنفر',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}