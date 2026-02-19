// screens/finance/finance_form_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/financial_item.dart';
import '../../../core/services/financial_api.dart';

class FinanceFormScreen extends StatefulWidget {
  final FinancialItem? existingItem;
  final String? type; // 'incoming' أو 'outgoing'
  final double? currentBalance;

  FinanceFormScreen({this.existingItem, this.type, this.currentBalance});

  @override
  _FinanceFormScreenState createState() => _FinanceFormScreenState();
}

class _FinanceFormScreenState extends State<FinanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late FinancialItem _item;
  bool _isLoading = false;
  bool _isEditMode = false;

  // قوائم الاختيارات
  final List<String> _paymentMethods = [
    'نقداً',
    'بنك',
    'تحويل إلكتروني',
    'شيك',
    'أخرى',
  ];

  final List<String> _expenseItems = [
    'رواتب',
    'مشتريات',
    'صيانة',
    'نقل',
    'اتصالات',
    'إيجار',
    'خدمات',
    'معدات',
    'أدوية',
    'مواد غذائية',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingItem != null;

    if (_isEditMode) {
      _item = widget.existingItem!;
    } else {
      _item = FinancialItem(
        entryDate: DateTime.now(),
        type: widget.type ?? 'incoming',
        source: '',
        amount: 0,
        method: '',
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
          if (_item.type == 'incoming') {
            await FinancialApi.updateIncomingFund(_item);
          } else {
            await FinancialApi.updateOutgoingFund(_item);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث السجل المالي بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (_item.type == 'incoming') {
            await FinancialApi.createIncomingFund(_item);
          } else {
            await FinancialApi.createOutgoingFund(_item);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء السجل المالي بنجاح'),
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
                labelText: 'التاريخ *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              controller: TextEditingController(
                text:
                    '${_item.entryDate.year}-${_item.entryDate.month.toString().padLeft(2, '0')}-${_item.entryDate.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _item.entryDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _item = _item.copyWith(entryDate: selectedDate);
                  });
                }
              },
            ),
            SizedBox(height: 12),
            if (!_isEditMode) ...[
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('وارد'),
                      leading: Radio(
                        value: 'incoming',
                        groupValue: _item.type,
                        onChanged: (value) {
                          setState(() {
                            _item = _item.copyWith(type: value.toString());
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('منصرف'),
                      leading: Radio(
                        value: 'outgoing',
                        groupValue: _item.type,
                        onChanged: (value) {
                          setState(() {
                            _item = _item.copyWith(type: value.toString());
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  _item.type == 'incoming'
                      ? 'معلومات الوارد'
                      : 'معلومات المنصرف',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_item.type == 'incoming') ...[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'الجهة الموردة *',
                  hintText: 'اسم الجهة الموردة للأموال',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                initialValue: _item.source,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الجهة الموردة';
                  }
                  return null;
                },
                onSaved: (value) => _item = _item.copyWith(source: value!),
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'بند الصرف *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                value: _item.source.isNotEmpty ? _item.source : null,
                items: _expenseItems.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _item = _item.copyWith(source: value!);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار بند الصرف';
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

  Widget _buildAmountMethodSection() {
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
                  'المبلغ وطريقة التوريد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'المبلغ *',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
                suffixText: 'جنيه',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: _item.amount.toString(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال المبلغ';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'يرجى إدخال رقم صحيح';
                }
                if (_item.type == 'outgoing' &&
                    !_isEditMode &&
                    widget.currentBalance != null) {
                  if (amount > widget.currentBalance!) {
                    return 'المبلغ يتجاوز الرصيد الحالي (${widget.currentBalance})';
                  }
                }
                return null;
              },
              onSaved: (value) =>
                  _item = _item.copyWith(amount: double.parse(value!)),
            ),
            SizedBox(height: 12),
            if (_item.type == 'incoming') ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'طريقة التوريد *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                value: _item.method.isNotEmpty ? _item.method : null,
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _item = _item.copyWith(method: value!);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار طريقة التوريد';
                  }
                  return null;
                },
              ),
            ] else ...[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'الشخص المستلم *',
                  hintText: 'اسم الشخص المستلم للأموال',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                initialValue: _item.method,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المستلم';
                  }
                  return null;
                },
                onSaved: (value) => _item = _item.copyWith(method: value!),
              ),
            ],
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
                Icon(Icons.note, color: Colors.purple),
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
                backgroundColor: Colors.indigo,
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
          _isEditMode
              ? 'تعديل سجل ${_item.description}'
              : 'إضافة سجل ${_item.type == 'incoming' ? 'وارد' : 'منصرف'} جديد',
        ),
        backgroundColor: Colors.indigo,
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
              _buildSourceSection(),
              SizedBox(height: 16),
              _buildAmountMethodSection(),
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
