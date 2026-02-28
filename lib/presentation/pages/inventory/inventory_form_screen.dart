import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/inventory_item.dart';
import '../../../core/services/inventory_api.dart';
import '../../widgets/modern_widgets.dart';

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
  double? _availableStock;

  final List<String> _movementTypes = ['وارد', 'منصرف', 'نقل'];

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

  Map<String, dynamic>? _selectedItem;
  Map<String, dynamic>? _selectedFromStore;
  Map<String, dynamic>? _selectedToStore;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingItem != null;

    if (_isEditMode) {
      _item = widget.existingItem!;
      if (_item.itemId != null) {
        _selectedItem = _items.firstWhere(
          (i) => i['id'] == _item.itemId,
          orElse: () => {'id': _item.itemId, 'name': _item.itemName ?? ''},
        );
      }
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

      if (_selectedItem == null) {
        _showError('يرجى اختيار الصنف');
        return;
      }

      _item = _item.copyWith(
        itemId: _selectedItem!['id'],
        itemName: _selectedItem!['name'],
        itemCode: _selectedItem!['code'],
      );

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

      setState(() => _isLoading = true);

      try {
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
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: _isEditMode ? 'تعديل حركة' : 'حركة مخزنية جديدة',
      children: [
        const ModernScreenHeader(
          title: 'إدارة المخزن',
          subtitle: 'قم بتسجيل تفاصيل الوارد والمنصرف بدقة لضمان توازن المخزون',
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildBasicInfoSection(),
              _buildItemSelectionSection(),
              _buildItemDetailsSection(),
              _buildAdditionalInfoSection(),
              const SizedBox(height: 12),
              ModernGradientButton(
                text: _isEditMode ? 'تحديث البيانات' : 'حفظ الحركة',
                onPressed: _saveItem,
                isLoading: _isLoading,
                icon: Icons.save_rounded,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.tajawal(color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return ModernSectionCard(
      title: 'المعلومات الأساسية',
      icon: Icons.info_outline,
      child: Column(
        children: [
          ModernTextField(
            label: 'تاريخ الحركة',
            prefixIcon: Icons.calendar_today_rounded,
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
                setState(
                  () => _item = _item.copyWith(movementDate: selectedDate),
                );
              }
            },
          ),
          ModernDropdownField<String>(
            label: 'نوع الحركة',
            prefixIcon: Icons.swap_vert_rounded,
            value: _item.movementType,
            items: _movementTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _item = _item.copyWith(movementType: value!);
                if (value != 'نقل') {
                  _selectedFromStore = null;
                  _selectedToStore = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemSelectionSection() {
    return ModernSectionCard(
      title: 'اختيار الصنف والمخزن',
      icon: Icons.inventory_2_outlined,
      child: Column(
        children: [
          ModernDropdownField<Map<String, dynamic>>(
            label: 'الصنف',
            prefixIcon: Icons.category_rounded,
            value: _selectedItem,
            items: _items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text('${item['name']} (${item['code']})'),
                  ),
                )
                .toList(),
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
          ),
          if (_item.movementType == 'وارد' || _item.movementType == 'نقل')
            ModernDropdownField<Map<String, dynamic>>(
              label: _item.movementType == 'وارد'
                  ? 'المخزن المستلم'
                  : 'المخزن الوجهة',
              prefixIcon: Icons.store_rounded,
              value: _selectedToStore,
              items: _stores
                  .map(
                    (store) => DropdownMenuItem(
                      value: store,
                      child: Text(store['name']),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedToStore = value),
            ),
          if (_item.movementType == 'منصرف' || _item.movementType == 'نقل')
            ModernDropdownField<Map<String, dynamic>>(
              label: 'المخزن المصدر',
              prefixIcon: Icons.storefront_rounded,
              value: _selectedFromStore,
              items: _stores
                  .map(
                    (store) => DropdownMenuItem(
                      value: store,
                      child: Text(store['name']),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedFromStore = value);
                _fetchAvailableStock();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildItemDetailsSection() {
    return ModernSectionCard(
      title: 'تفاصيل الكمية',
      icon: Icons.analytics_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernTextField(
            label: 'الكمية',
            prefixIcon: Icons.add_chart_rounded,
            keyboardType: TextInputType.number,
            initialValue: _item.quantity > 0 ? _item.quantity.toString() : '',
            validator: (value) {
              if (value == null || value.isEmpty) return 'يرجى إدخال الكمية';
              final qty = double.tryParse(value);
              if (qty == null || qty <= 0)
                return 'الكمية يجب أن تكون أكبر من صفر';
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
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ModernStatusBadge(
                text: 'المخزون المتاح: $_availableStock',
                color: _availableStock! <= 0 ? Colors.red : Colors.green,
              ),
            ),
          ModernDropdownField<String>(
            label: 'نوع العبوة',
            prefixIcon: Icons.inventory_2_rounded,
            value: _item.packaging,
            items: _packagingTypes
                .map((pkg) => DropdownMenuItem(value: pkg, child: Text(pkg)))
                .toList(),
            onChanged: (value) =>
                setState(() => _item = _item.copyWith(packaging: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return ModernSectionCard(
      title: 'بيانات إضافية',
      icon: Icons.more_horiz_rounded,
      child: Column(
        children: [
          ModernTextField(
            label: _item.movementType == 'وارد'
                ? 'الجهة الموردة'
                : 'الجهة المستلمة',
            prefixIcon: _item.movementType == 'وارد'
                ? Icons.local_shipping_rounded
                : Icons.person_pin_rounded,
            initialValue: _item.movementType == 'وارد'
                ? _item.supplierEntity
                : _item.receiverEntity,
            onSaved: (value) {
              if (_item.movementType == 'وارد') {
                _item = _item.copyWith(supplierEntity: value);
              } else {
                _item = _item.copyWith(receiverEntity: value);
              }
            },
          ),
          ModernTextField(
            label: 'تاريخ انتهاء الصلاحية',
            prefixIcon: Icons.event_busy_rounded,
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
                    DateTime.now().add(const Duration(days: 365)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (selectedDate != null) {
                setState(
                  () => _item = _item.copyWith(expiryDate: selectedDate),
                );
              }
            },
          ),
          ModernTextField(
            label: 'رقم الدفعة (Batch No)',
            prefixIcon: Icons.tag_rounded,
            initialValue: _item.batchNumber,
            onSaved: (value) => _item = _item.copyWith(batchNumber: value),
          ),
          ModernTextField(
            label: 'المعتمد (Approved By)',
            prefixIcon: Icons.assignment_turned_in_rounded,
            initialValue: _item.approvedBy,
            onSaved: (value) => _item = _item.copyWith(approvedBy: value),
          ),
          ModernTextField(
            label: 'ملاحظات',
            prefixIcon: Icons.notes_rounded,
            initialValue: _item.notes,
            maxLines: 3,
            onSaved: (value) => _item = _item.copyWith(notes: value),
          ),
        ],
      ),
    );
  }
}
