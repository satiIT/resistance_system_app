import 'package:flutter/material.dart';
import '../../../core/models/casualty.dart';
import '../../../core/services/casualty_api.dart';

class CasualtyFormScreen extends StatefulWidget {
  final Casualty? existingCasualty;

  CasualtyFormScreen({this.existingCasualty});

  @override
  _CasualtyFormScreenState createState() => _CasualtyFormScreenState();
}

class _CasualtyFormScreenState extends State<CasualtyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Casualty _casualty;
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _showCompensationFields = false;
  bool _isInitialized = false;

  List<Map<String, dynamic>> _personnelList = [];
  Map<int, Map<String, dynamic>> _personnelCache = {};

  final List<String> _caseTypes = ['شهيد', 'جريح'];
  final List<String> _injurySeverities = ['خطيرة', 'محدودة', 'بسيطة', 'بسيطة جدا'];
  final List<String> _paymentMethods = ['نقدا', 'بنك'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingCasualty != null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // جلب قائمة المستنفرين
      final personnel = await CasualtyApi.getPersonnelList();
      
      setState(() {
        _personnelList = personnel;
        
        if (_isEditMode) {
          _casualty = widget.existingCasualty!;
          _showCompensationFields = _casualty.isMartyr;
        } else {
          _casualty = Casualty(
            personnelId: 0,
            caseType: 'جريح',
            incidentDate: DateTime.now(),
            incidentLocation: '',
            signalNumber: '',
            injurySeverity: 'بسيطة',
          );
        }
        
        _isInitialized = true;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadPersonnelData(int personnelId) async {
    if (_personnelCache.containsKey(personnelId)) {
      final person = _personnelCache[personnelId]!;
      setState(() {
        _casualty.militaryNumber = person['military_number'];
        _casualty.fullName = person['full_name'];
      });
      return;
    }

    try {
      final person = await CasualtyApi.getPersonnelById(personnelId);
      setState(() {
        _casualty.militaryNumber = person['military_id']?.toString() ?? '';
        _casualty.fullName = '${person['first_name']} ${person['second_name']} ${person['third_name']} ${person['fourth_name']}';
        _personnelCache[personnelId] = {
          'military_number': _casualty.militaryNumber,
          'full_name': _casualty.fullName,
        };
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل بيانات المستنفر: $e');
    }
  }

  Future<void> _saveCasualty() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // التحقق من اختيار مستنفر
      if (_casualty.personnelId == 0) {
        _showErrorSnackBar('يرجى اختيار مستنفر من القائمة');
        return;
      }

      // التحقق من عدم تكرار السجل
      if (!_isEditMode) {
        try {
          final isDuplicate = await CasualtyApi.checkDuplicateRecord(
            _casualty.personnelId ?? 0, 
            _casualty.caseType!
          );
          if (isDuplicate) {
            _showErrorSnackBar('يوجد سجل ${_casualty.caseType} مسبقاً لهذا المستنفر');
            return;
          }
        } catch (e) {
          _showErrorSnackBar('خطأ في التحقق من التكرار: $e');
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      try {
        if (_isEditMode) {
          await CasualtyApi.updateCasualty(_casualty);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث السجل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await CasualtyApi.createCasualty(_casualty);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء السجل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackBar('خطأ: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPersonnelSelectionSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_search, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'اختيار المستنفر',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'اختر المستنفر *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _casualty.personnelId != 0 ? _casualty.personnelId : null,
              items: _personnelList.map((person) {
                return DropdownMenuItem<int>(
                  value: person['id'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${person['full_name']}'),
                      Text(
                        'الرقم العسكري: ${person['military_number']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _casualty.personnelId = newValue;
                  });
                  _loadPersonnelData(newValue);
                }
              },
              validator: (value) {
                if (value == null || value == 0) {
                  return 'يرجى اختيار مستنفر من القائمة';
                }
                return null;
              },
            ),
            if (_casualty.personnelId != 0) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'البيانات الأساسية للمستنفر:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    SizedBox(height: 8),
                    Text('الاسم: ${_casualty.fullName ?? "جاري التحميل..."}'),
                    Text('الرقم العسكري: ${_casualty.militaryNumber ?? "جاري التحميل..."}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCasualtyTypeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'نوع الاستمارة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع الاستمارة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _casualty.caseType,
              items: _caseTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _casualty.caseType = value!;
                  _showCompensationFields = value == 'شهيد';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نوع الاستمارة';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'معلومات الحادث',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تاريخ الإصابة/الاستشهاد *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              controller: TextEditingController(
                text: '${_casualty.incidentDate!.year}-${_casualty.incidentDate!.month.toString().padLeft(2, '0')}-${_casualty.incidentDate!.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _casualty.incidentDate!,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _casualty.incidentDate = selectedDate;
                  });
                }
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'موقع الإصابة/الاستشهاد *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.incidentLocation,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال موقع الحادث';
                }
                return null;
              },
              onSaved: (value) => _casualty.incidentLocation = value!,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رقم إشارة الشهادة/الإصابة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.signalNumber,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الإشارة';
                }
                return null;
              },
              onSaved: (value) => _casualty.signalNumber = value!,
            ),
            if (_casualty.isInjured) ...[
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'حالة الإصابة *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                value: _casualty.injurySeverity,
                items: _injurySeverities.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Text(severity),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _casualty.injurySeverity = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار حالة الإصابة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'المستشفيات التي تعالج فيها الجريح',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                initialValue: _casualty.hospitals,
                onSaved: (value) => _casualty.hospitals = value,
              ),
            ],
            if (_casualty.isMartyr) ...[
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'مكان دفن الشهيد',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                initialValue: _casualty.burialLocation,
                onSaved: (value) => _casualty.burialLocation = value,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'إحداثيات قبر الشهيد',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                initialValue: _casualty.graveCoordinates,
                onSaved: (value) => _casualty.graveCoordinates = value,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextOfKinSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'بيانات ذوي القربى',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم ذوي القربى',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.nextOfKinName,
              onSaved: (value) => _casualty.nextOfKinName = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'هاتف ذوي القربى',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.phone,
              initialValue: _casualty.nextOfKinPhone,
              onSaved: (value) => _casualty.nextOfKinPhone = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'عنوان ذوي القربى',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.nextOfKinAddress,
              onSaved: (value) => _casualty.nextOfKinAddress = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompensationSection() {
    if (!_showCompensationFields) return SizedBox();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'خلافة الشهيد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تاريخ الخلافة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _casualty.compensationDate != null 
                    ? '${_casualty.compensationDate!.year}-${_casualty.compensationDate!.month.toString().padLeft(2, '0')}-${_casualty.compensationDate!.day.toString().padLeft(2, '0')}'
                    : '',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _casualty.compensationDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _casualty.compensationDate = selectedDate;
                  });
                }
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              initialValue: _casualty.compensationAmount?.toString(),
              onSaved: (value) => _casualty.compensationAmount = double.tryParse(value ?? '0'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'طريقة الدفع',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _casualty.paymentMethod,
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _casualty.paymentMethod = value;
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الشخص المستلم للمبلغ',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.compensationRecipient,
              onSaved: (value) => _casualty.compensationRecipient = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الجهة الدافعة للمبلغ',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.payingEntity,
              onSaved: (value) => _casualty.payingEntity = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'نوع المواد العينية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.materialItems,
              onSaved: (value) => _casualty.materialItems = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تقدير قيمة المواد (جنيه)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              initialValue: _casualty.materialValue?.toString(),
              onSaved: (value) => _casualty.materialValue = double.tryParse(value ?? '0'),
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
                  : Text(_isEditMode ? 'تحديث السجل' : 'حفظ السجل'),
              onPressed: _isLoading ? null : _saveCasualty,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.red,
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
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('تحميل...'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل قائمة المستنفرين...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'تعديل سجل شهيد/جريح' : 'إضافة سجل شهيد/جريح جديد'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildPersonnelSelectionSection(),
              SizedBox(height: 16),
              _buildCasualtyTypeSection(),
              SizedBox(height: 16),
              _buildIncidentInfoSection(),
              SizedBox(height: 16),
              _buildNextOfKinSection(),
              SizedBox(height: 16),
              _buildCompensationSection(),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}