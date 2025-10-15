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

  final List<String> _formTypes = ['شهيد', 'جريح'];
  final List<String> _injurySeverities = [
    'خطيرة',
    'محدودة', 
    'بسيطة',
    'بسيطة جدا'
  ];
  final List<String> _paymentMethods = ['نقدا', 'بنك'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingCasualty != null;
    
    if (_isEditMode) {
      _casualty = widget.existingCasualty!;
      _showCompensationFields = _casualty.isMartyr;
    } else {
      _casualty = Casualty(
        militaryNumber: '',
        formType: 'جريح',
        fullName: '',
        incidentDate: DateTime.now(),
        incidentLocation: '',
        caseSignalNumber: '',
        injurySeverity: 'بسيطة',
        nextOfKinName: '',
        nextOfKinPhone: '',
      );
    }
  }

  Future<void> _saveCasualty() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
                Icon(Icons.person, color: Colors.blue),
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
                labelText: 'الرقم العسكري *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.militaryNumber,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الرقم العسكري';
                }
                return null;
              },
              onSaved: (value) => _casualty.militaryNumber = value!,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع الاستمارة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _casualty.formType,
              items: _formTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _casualty.formType = value!;
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
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الإسم الكامل *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.fullName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الإسم الكامل';
                }
                return null;
              },
              onSaved: (value) => _casualty.fullName = value!,
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
                Icon(Icons.event, color: Colors.red),
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
                text: '${_casualty.incidentDate.year}-${_casualty.incidentDate.month.toString().padLeft(2, '0')}-${_casualty.incidentDate.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _casualty.incidentDate,
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
              initialValue: _casualty.caseSignalNumber,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الإشارة';
                }
                return null;
              },
              onSaved: (value) => _casualty.caseSignalNumber = value!,
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
                Icon(Icons.family_restroom, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'أقرب الأقربين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم أقرب الأقربين *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.nextOfKinName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم أقرب الأقربين';
                }
                return null;
              },
              onSaved: (value) => _casualty.nextOfKinName = value!,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رقم تلفون أقرب الأقربين *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.nextOfKinPhone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم التلفون';
                }
                return null;
              },
              onSaved: (value) => _casualty.nextOfKinPhone = value!,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'عنوان أقرب الأقربين',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _casualty.nextOfKinAddress,
              maxLines: 2,
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
              _buildBasicInfoSection(),
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