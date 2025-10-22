// screens/medicine/medicine_form_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/medicine_item.dart';
import '../../../core/services/medicine_api.dart';

class MedicineFormScreen extends StatefulWidget {
  final MedicineItem? existingItem;

  MedicineFormScreen({this.existingItem});

  @override
  _MedicineFormScreenState createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late MedicineItem _item;
  bool _isLoading = false;
  bool _isEditMode = false;

  // قوائم الاختيارات
  final List<String> _movementTypes = ['وارد', 'منصرف'];
  final List<String> _medicineTypes = [
    'علاج ملاريا', 'مضاد حيوي', 'علاج سكري', 'مسكنات', 'فيتامينات',
    'مضادات الالتهاب', 'أدوية قلب', 'أدوية ضغط', 'مضادات حساسية',
    'أدوية هضمية', 'مطهرات', 'مضادات فطريات'
  ];
  final List<String> _packagingTypes = [
    'كرتونة 150 جرعة', 'فتيل', 'حقن', 'حبوب', 'شراب', 
    'لفة', 'شريط', 'كبسولة', 'مرهم', 'قطرة', 'بخاخ'
  ];
  final List<String> _dosageForms = [
    'أقراص', 'كبسولات', 'شراب', 'حقن', 'مرهم', 'كريم',
    'قطرة', 'بخاخ', 'لبوس', 'مسحوق', 'محلول'
  ];
  final List<String> _units = [
    'علبة', 'عبوة', 'قطعة', 'مل', 'مج', 'لتر', 'جم'
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingItem != null;
    
    if (_isEditMode) {
      _item = widget.existingItem!;
    } else {
      _item = MedicineItem(
        movementDate: DateTime.now(),
        movementType: 'وارد',
        quantity: 0,
      );
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isEditMode) {
          await MedicineApi.updateMedicineItem(_item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث سجل الدواء بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await MedicineApi.createMedicineItem(_item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء سجل الدواء بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
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
                labelText: 'تاريخ الحركة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              controller: TextEditingController(
                text: '${_item.movementDate.year}-${_item.movementDate.month.toString().padLeft(2, '0')}-${_item.movementDate.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _item.movementDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _item = _item.copyWith(movementDate: selectedDate);
                  });
                }
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع الحركة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _item.movementType,
              items: _movementTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(movementType: value!);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نوع الحركة';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineDetailsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'تفاصيل الدواء',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم الدواء *',
                hintText: 'أدخل اسم الدواء',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _item.itemName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم الدواء';
                }
                return null;
              },
            //
            // في _buildMedicineDetailsSection بدلاً من onSaved
onSaved: (value) {
  // طريقة بديلة إذا كانت copyWith لا تعمل
  setState(() {
    _item = MedicineItem(
      id: _item.id,
      movementDate: _item.movementDate,
      movementType: _item.movementType,
      itemId: _item.itemId,
      storeId: _item.storeId,
      sourceOrRecipient: _item.sourceOrRecipient,
      medicineType: _item.medicineType,
      packaging: _item.packaging,
      quantity: _item.quantity,
      unit: _item.unit,
      expiryDate: _item.expiryDate,
      notes: _item.notes,
      dosageForm: _item.dosageForm,
      strength: _item.strength,
      itemName: value, // تعيين القيمة مباشرة
      itemCode: _item.itemCode,
      medicineCategory: _item.medicineCategory,
      unitOfMeasure: _item.unitOfMeasure,
      storeName: _item.storeName,
      location: _item.location,
    );
  });
},
            //  onSaved: (value) => _item = _item.copyWith(itemName: value),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع الدواء',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _item.medicineType,
              items: _medicineTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(medicineType: value);
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: _item.movementType == 'وارد' ? 'المصدر *' : 'المستلم *',
                hintText: _item.movementType == 'وارد' ? 'اسم المورد' : 'اسم المستلم',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _item.sourceOrRecipient,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم الجهة';
                }
                return null;
              },
              onSaved: (value) => _item = _item.copyWith(sourceOrRecipient: value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.scale, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'الكمية والتعبئة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'الكمية *',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _item.quantity.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الكمية';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال رقم صحيح';
                      }
                      return null;
                    },
                    onSaved: (value) => _item = _item.copyWith(quantity: double.parse(value!)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'الوحدة',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    value: _item.unit,
                    items: _units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _item = _item.copyWith(unit: value);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع العبوة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _item.packaging,
              items: _packagingTypes.map((packaging) {
                return DropdownMenuItem(
                  value: packaging,
                  child: Text(packaging),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(packaging: value);
                });
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'شكل الجرعة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              value: _item.dosageForm,
              items: _dosageForms.map((form) {
                return DropdownMenuItem(
                  value: form,
                  child: Text(form),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(dosageForm: value);
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'التركيز / القوة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _item.strength,
              onSaved: (value) => _item = _item.copyWith(strength: value),
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
                Icon(Icons.calendar_today, color: Colors.purple),
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
                labelText: 'تاريخ انتهاء الصلاحية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _item.expiryDate != null 
                    ? '${_item.expiryDate!.year}-${_item.expiryDate!.month.toString().padLeft(2, '0')}-${_item.expiryDate!.day.toString().padLeft(2, '0')}'
                    : '',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _item.expiryDate ?? DateTime.now().add(Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 3650)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _item = _item.copyWith(expiryDate: selectedDate);
                  });
                }
              },
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
              initialValue: _item.notes,
              maxLines: 3,
              onSaved: (value) => _item = _item.copyWith(notes: value),
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
              onPressed: _isLoading ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.purple,
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
        title: Text(_isEditMode ? 'تعديل سجل الدواء' : 'إضافة سجل دواء جديد'),
        backgroundColor: Colors.purple,
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
              _buildMedicineDetailsSection(),
              SizedBox(height: 16),
              _buildQuantitySection(),
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