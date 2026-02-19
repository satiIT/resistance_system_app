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
  double? _availableStock; // المخزون المتاح للصنف المحدد في المخزن المحدد

  // قوائم الاختيارات
  final List<String> _movementTypes = ['وارد', 'منصرف', 'نقل'];

  // قائمة الأصناف مع معرفاتها
  final List<Map<String, dynamic>> _items = [
    {'id': 1, 'name': 'دقيق', 'code': 'FLO001'},
    {'id': 2, 'name': 'سكر', 'code': 'SUG001'},
    {'id': 3, 'name': 'زيت', 'code': 'OIL001'},
    {'id': 4, 'name': 'بصل', 'code': 'ONI001'},
    {'id': 5, 'name': 'أرز', 'code': 'RIC001'},
    {'id': 6, 'name': 'شاي', 'code': 'TEA001'},
    {'id': 7, 'name': 'قهوة', 'code': 'COF001'},
    {'id': 8, 'name': 'معكرونة', 'code': 'PAS001'},
    {'id': 9, 'name': 'لبن', 'code': 'MIL001'},
    {'id': 10, 'name': 'جبن', 'code': 'CHS001'},
    {'id': 11, 'name': 'لحم', 'code': 'MEA001'},
    {'id': 12, 'name': 'دجاج', 'code': 'CHI001'},
    {'id': 13, 'name': 'سمك', 'code': 'FIS001'},
    {'id': 14, 'name': 'خضار', 'code': 'VEG001'},
    {'id': 15, 'name': 'فواكه', 'code': 'FRU001'},
    {'id': 16, 'name': 'مواد تنظيف', 'code': 'CLE001'},
    {'id': 17, 'name': 'أدوية', 'code': 'MED001'},
  ];

  // قائمة المخازن
  final List<Map<String, dynamic>> _stores = [
    {'id': 1, 'name': 'المخزن المركزي'},
    {'id': 2, 'name': 'مخزن المواد الغذائية'},
    {'id': 3, 'name': 'مخزن الأسلحة'},
    {'id': 4, 'name': 'مخزن الذخيرة'},
    {'id': 5, 'name': 'مخزن الملابس'},
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
    'كيلو',
  ];

  // متغيرات للقوائم المنسدلة
  Map<String, dynamic>? _selectedItem;
  Map<String, dynamic>? _selectedFromStore;
  Map<String, dynamic>? _selectedToStore;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingItem != null;

    if (_isEditMode) {
      _item = widget.existingItem!;

      // تعيين العنصر المحدد
      if (_item.itemId != null) {
        _selectedItem = _items.firstWhere(
          (i) => i['id'] == _item.itemId,
          orElse: () => {'id': _item.itemId, 'name': _item.itemName ?? ''},
        );
      }

      // تعيين المخازن المحددة
      if (_item.fromStore != null) {
        _selectedFromStore = _stores.firstWhere(
          (s) => s['id'] == _item.fromStore,
          orElse: () => {
            'id': _item.fromStore,
            'name': _item.fromStoreName ?? '',
          },
        );
      }

      if (_item.toStore != null) {
        _selectedToStore = _stores.firstWhere(
          (s) => s['id'] == _item.toStore,
          orElse: () => {'id': _item.toStore, 'name': _item.toStoreName ?? ''},
        );
      }
    } else {
      _item = InventoryItem(
        movementType: 'وارد',
        quantity: 0,
        movementDate: DateTime.now(),
      );
    }

    // جلب المخزون إذا كنا في وضع التعديل وكان هناك صنف ومخزن مصدر
    if (_isEditMode && _item.itemId != null && _item.fromStore != null) {
      _fetchAvailableStock();
    }
  }

  Future<void> _fetchAvailableStock() async {
    if (_selectedItem == null ||
        (_item.movementType != 'منصرف' && _item.movementType != 'نقل')) {
      setState(() => _availableStock = null);
      return;
    }

    int? storeId = _selectedFromStore != null
        ? _selectedFromStore!['id']
        : null;
    if (storeId == null) {
      setState(() => _availableStock = null);
      return;
    }

    try {
      final stockList = await InventoryApi.getStoreStock(storeId);
      final itemStock = stockList.firstWhere(
        (s) => s['item_id'] == _selectedItem!['id'],
        orElse: () => {'quantity': 0.0},
      );

      if (mounted) {
        setState(() {
          _availableStock =
              double.tryParse(itemStock['quantity'].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      print('Error fetching stock: $e');
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // التحقق من اختيار الصنف
      if (_selectedItem == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى اختيار الصنف'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تعيين itemId من العنصر المحدد
      _item = _item.copyWith(
        itemId: _selectedItem!['id'],
        itemName: _selectedItem!['name'],
        itemCode: _selectedItem!['code'],
      );

      // تعيين المخازن حسب نوع الحركة
      if (_item.movementType == 'وارد' && _selectedToStore != null) {
        _item = _item.copyWith(
          toStore: _selectedToStore!['id'],
          toStoreName: _selectedToStore!['name'],
        );
      } else if (_item.movementType == 'منصرف' && _selectedFromStore != null) {
        _item = _item.copyWith(
          fromStore: _selectedFromStore!['id'],
          fromStoreName: _selectedFromStore!['name'],
        );
      } else if (_item.movementType == 'نقل') {
        if (_selectedFromStore != null && _selectedToStore != null) {
          _item = _item.copyWith(
            fromStore: _selectedFromStore!['id'],
            fromStoreName: _selectedFromStore!['name'],
            toStore: _selectedToStore!['id'],
            toStoreName: _selectedToStore!['name'],
          );
        }
      }

      setState(() {
        _isLoading = true;
      });

      try {
        print('📤 حفظ حركة المخزون: ${_item.toJson()}');

        if (_isEditMode) {
          await InventoryApi.updateInventoryItem(_item);
          _showSuccess('تم تحديث حركة المخزون بنجاح');
        } else {
          await InventoryApi.createInventoryItem(_item);
          _showSuccess('تم إنشاء حركة المخزون بنجاح');
        }
        Navigator.pop(context, true);
      } catch (e) {
        _showError('خطأ في الحفظ: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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

            // تاريخ الحركة
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تاريخ الحركة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(
                text:
                    '${_item.movementDate.year}-${_item.movementDate.month.toString().padLeft(2, '0')}-${_item.movementDate.day.toString().padLeft(2, '0')}',
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

            // نوع الحركة
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع الحركة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.compare_arrows),
              ),
              value: _item.movementType,
              items: _movementTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(movementType: value!);
                  // إعادة تعيين المخازن عند تغيير نوع الحركة
                  if (value != 'نقل') {
                    _selectedFromStore = null;
                    _selectedToStore = null;
                  }
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

  Widget _buildItemSelectionSection() {
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
                  'اختيار الصنف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // اختيار الصنف
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: 'الصنف *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedItem,
              items: [
                DropdownMenuItem(value: null, child: Text('اختر الصنف...')),
                ..._items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text('${item['name']} (${item['code']})'),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                  if (value != null) {
                    _item = _item.copyWith(
                      itemId: value['id'],
                      itemName: value['name'],
                      itemCode: value['code'],
                    );
                  }
                });
                _fetchAvailableStock();
              },
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار الصنف';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // حقول المخازن حسب نوع الحركة
            if (_item.movementType == 'وارد') ...[
              SizedBox(height: 12),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'المخزن المستلم *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.store),
                ),
                value: _selectedToStore,
                items: [
                  DropdownMenuItem(value: null, child: Text('اختر المخزن...')),
                  ..._stores.map((store) {
                    return DropdownMenuItem(
                      value: store,
                      child: Text(store['name']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedToStore = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار المخزن المستلم';
                  }
                  return null;
                },
              ),
            ],

            if (_item.movementType == 'منصرف') ...[
              SizedBox(height: 12),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'المخزن المصدر *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.store),
                ),
                value: _selectedFromStore,
                items: [
                  DropdownMenuItem(value: null, child: Text('اختر المخزن...')),
                  ..._stores.map((store) {
                    return DropdownMenuItem(
                      value: store,
                      child: Text(store['name']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFromStore = value;
                  });
                  _fetchAvailableStock();
                },
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار المخزن المصدر';
                  }
                  return null;
                },
              ),
            ],

            if (_item.movementType == 'نقل') ...[
              SizedBox(height: 12),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'المخزن المصدر *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.store),
                ),
                value: _selectedFromStore,
                items: [
                  DropdownMenuItem(value: null, child: Text('اختر المخزن...')),
                  ..._stores.map((store) {
                    return DropdownMenuItem(
                      value: store,
                      child: Text(store['name']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFromStore = value;
                  });
                  _fetchAvailableStock();
                },
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار المخزن المصدر';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'المخزن المستلم *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.store),
                ),
                value: _selectedToStore,
                items: [
                  DropdownMenuItem(value: null, child: Text('اختر المخزن...')),
                  ..._stores.map((store) {
                    return DropdownMenuItem(
                      value: store,
                      child: Text(store['name']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedToStore = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار المخزن المستلم';
                  }
                  return null;
                },
              ),
            ],
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
                Icon(Icons.add_box, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'تفاصيل الصنف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // الكمية
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الكمية *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              initialValue: _item.quantity > 0 ? _item.quantity.toString() : '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الكمية';
                }
                final qty = double.tryParse(value);
                if (qty == null) {
                  return 'يرجى إدخال رقم صحيح';
                }
                if (qty <= 0) {
                  return 'الكمية يجب أن تكون أكبر من صفر';
                }

                // التحقق من المخزون المتاح في حالة المنصرف أو النقل
                if ((_item.movementType == 'منصرف' ||
                        _item.movementType == 'نقل') &&
                    _availableStock != null &&
                    qty > _availableStock!) {
                  return 'الكمية تتجاوز المخزون المتاح ($_availableStock)';
                }

                return null;
              },
              onSaved: (value) =>
                  _item = _item.copyWith(quantity: double.parse(value!)),
            ),
            if (_availableStock != null &&
                (_item.movementType == 'منصرف' || _item.movementType == 'نقل'))
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                child: Text(
                  'المخزون المتاح: $_availableStock',
                  style: TextStyle(
                    color: _availableStock! <= 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            SizedBox(height: 12),

            // نوع العبوة
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'نوع العبوة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.inventory),
              ),
              value: _item.packaging,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('اختر نوع العبوة...'),
                ),
                ..._packagingTypes.map((packaging) {
                  return DropdownMenuItem(
                    value: packaging,
                    child: Text(packaging),
                  );
                }).toList(),
              ],
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
                Icon(Icons.info_outline, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'معلومات إضافية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // الجهة (مورد/مستلم)
            TextFormField(
              decoration: InputDecoration(
                labelText: _item.movementType == 'وارد'
                    ? 'الجهة الموردة *'
                    : 'الجهة المستلمة *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(
                  _item.movementType == 'وارد' ? Icons.support : Icons.person,
                ),
              ),
              initialValue: _item.movementType == 'وارد'
                  ? _item.supplierEntity
                  : _item.receiverEntity,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _item.movementType == 'وارد'
                      ? 'يرجى إدخال اسم المورد'
                      : 'يرجى إدخال اسم المستلم';
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

            // تاريخ الانتهاء
            TextFormField(
              decoration: InputDecoration(
                labelText: 'تاريخ انتهاء الصلاحية',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.calendar_month),
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
                  initialDate:
                      _item.expiryDate ??
                      DateTime.now().add(Duration(days: 365)),
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

            // رقم الدفعة
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رقم الدفعة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.qr_code),
              ),
              initialValue: _item.batchNumber,
              onSaved: (value) => _item = _item.copyWith(batchNumber: value),
            ),
            SizedBox(height: 12),

            // المعتمد
            TextFormField(
              decoration: InputDecoration(
                labelText: 'المعتمد',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.verified_user),
              ),
              initialValue: _item.approvedBy,
              onSaved: (value) => _item = _item.copyWith(approvedBy: value),
            ),
            SizedBox(height: 12),

            // ملاحظات
            TextFormField(
              decoration: InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.note),
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
        title: Text(
          _isEditMode ? 'تعديل حركة المخزون' : 'إضافة حركة مخزون جديدة',
        ),
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
              _buildItemSelectionSection(),
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
