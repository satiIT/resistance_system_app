import 'package:flutter/material.dart';
import '../../../core/models/inventory_item.dart';
import '../../../core/services/inventory_api.dart';

class InventoryFormScreen extends StatefulWidget {
  final InventoryItem? existingItem;

  InventoryFormScreen({this.existingItem});

  @override
  _InventoryFormScreenState createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late InventoryItem _item;
  bool _isLoading = false;
  bool _isEditMode = false;

  // قوائم الاختيارات
  final List<String> _movementTypes = ['وارد', 'منصرف', 'نقل'];
  final List<String> _itemNames = [
    'دقيق', 'سكر', 'زيت', 'بصل', 'أرز', 'شاي', 'قهوة',
    'معكرونة', 'لبن', 'جبن', 'لحم', 'دجاج', 'سمك',
    'خضار', 'فواكه', 'مواد تنظيف', 'أدوية'
  ];
  final List<String> _packagingTypes = [
    'شوال 90 كيلو',
    'شوال 25 كيلو', 
    'باقة 36 رطل',
    'باقة 9 رطل',
    'كرتونة 45 قطعة',
    'كرتونة 40 علبة',
    'كيس 50 كيلو',
    'كيس 25 كيلو',
    'علبة',
    'قطعة',
    'لتر',
    'كيلو'
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingItem != null;
    
    if (_isEditMode) {
      _item = widget.existingItem!;
    } else {
      _item = InventoryItem(
        movementType: 'وارد',
        quantity: 0,
        movementDate: DateTime.now(),
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
          await InventoryApi.updateInventoryItem(_item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث حركة المخزون بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await InventoryApi.createInventoryItem(_item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء حركة المخزون بنجاح'),
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

  Widget _buildItemDetailsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'تفاصيل الصنف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم الصنف *',
                hintText: 'أدخل اسم الصنف',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _item.itemName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم الصنف';
                }
                return null;
              },
              onSaved: (value) {
                // Note: في التطبيق الحقيقي، سنحتاج للحصول على item_id من الاسم
                _item = _item.copyWith(itemName: value);
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: _item.movementType == 'وارد' ? 'الجهة الموردة *' : 'الجهة المستلمة *',
                hintText: _item.movementType == 'وارد' ? 'اسم المورد' : 'اسم المستلم',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _item.entity,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم الجهة';
                }
                return null;
              },
              onSaved: (value) {
                if (_item.movementType == 'وارد') {
                  _item = _item.copyWith(supplierEntity: value);
                } else {
                  _item = _item.copyWith(receiverEntity: value);
                }
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع العبوة *',
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نوع العبوة';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
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
                Icon(Icons.calendar_today, color: Colors.orange),
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
                labelText: 'رقم الدفعة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              initialValue: _item.batchNumber,
              onSaved: (value) => _item = _item.copyWith(batchNumber: value),
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
                backgroundColor: Colors.teal,
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
        title: Text(_isEditMode ? 'تعديل حركة المخزون' : 'إضافة حركة مخزون جديدة'),
        backgroundColor: Colors.teal,
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
              _buildItemDetailsSection(),
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

// إضافة دالة copyWith لنموذج InventoryItem
extension InventoryItemCopyWith on InventoryItem {
  InventoryItem copyWith({
    int? id,
    int? itemId,
    int? fromStore,
    int? toStore,
    String? movementType,
    double? quantity,
    DateTime? movementDate,
    String? approvedBy,
    String? notes,
    String? packaging,
    DateTime? expiryDate,
    String? supplierEntity,
    String? receiverEntity,
    String? packagingDetails,
    String? batchNumber,
    String? itemName,
    String? itemCode,
    String? category,
    String? unitOfMeasure,
    String? fromStoreName,
    String? toStoreName,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      fromStore: fromStore ?? this.fromStore,
      toStore: toStore ?? this.toStore,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      movementDate: movementDate ?? this.movementDate,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
      packaging: packaging ?? this.packaging,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierEntity: supplierEntity ?? this.supplierEntity,
      receiverEntity: receiverEntity ?? this.receiverEntity,
      packagingDetails: packagingDetails ?? this.packagingDetails,
      batchNumber: batchNumber ?? this.batchNumber,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      category: category ?? this.category,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      fromStoreName: fromStoreName ?? this.fromStoreName,
      toStoreName: toStoreName ?? this.toStoreName,
    );
  }
}