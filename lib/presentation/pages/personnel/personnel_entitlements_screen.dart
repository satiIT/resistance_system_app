// lib/presentation/pages/personnel/personnel_entitlements_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/services/entitlements_api.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelEntitlementsScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelEntitlementsScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelEntitlementsScreenState createState() => _PersonnelEntitlementsScreenState();
}

class _PersonnelEntitlementsScreenState extends State<PersonnelEntitlementsScreen> {
  List<dynamic> _entitlements = [];
  bool _isLoading = true;
  String _errorMessage = '';
  double _totalReceived = 0.0;
  double _totalPending = 0.0;
  double _monthlyEntitlement = 0.0;
  double _arrears = 0.0;

  @override
  void initState() {
    super.initState();
    _loadEntitlementsData();
  }

  Future<void> _loadEntitlementsData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final entitlements = await EntitlementsApi.getEntitlementsByPersonnelId(widget.personnelId);
      
      // حساب الإحصائيات
      _calculateTotals(entitlements);
      
      setState(() {
        _entitlements = entitlements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحميل بيانات الاستحقاقات: $e';
      });
      _showErrorMessage('فشل في تحميل بيانات الاستحقاقات: $e');
    }
  }

  void _calculateTotals(List<dynamic> entitlements) {
    _totalReceived = entitlements
        .where((ent) => EntitlementsApi.getPaymentStatusDisplay(ent['payment_status']) == 'مستلم')
        .fold(0.0, (sum, ent) => sum + (double.tryParse(ent['amount']?.toString() ?? '0') ?? 0));

    _totalPending = entitlements
        .where((ent) => EntitlementsApi.getPaymentStatusDisplay(ent['payment_status']) == 'معلق')
        .fold(0.0, (sum, ent) => sum + (double.tryParse(ent['amount']?.toString() ?? '0') ?? 0));

    // حساب المستحق الشهري (يمكن تحسين هذا المنطق بناءً على بياناتك)
    _monthlyEntitlement = 650000.0; // قيمة افتراضية - يمكن حسابها من البيانات
    
    // حساب المتأخرات
    _arrears = _totalPending;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('الاستحقاقات المالية - ${widget.personnelName}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addEntitlement(context),
          ),
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: () => _makePayment(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEntitlementsData,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري تحميل بيانات الاستحقاقات...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEntitlementsData,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // لوحة الإحصائيات المالية
        _buildFinancialStatsPanel(),
        // القائمة الرئيسية
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEntitlementsSummary(),
                SizedBox(height: 16),
                Expanded(
                  child: _buildEntitlementsTable(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEntitlementsSummary(),
          SizedBox(height: 16),
          _buildFinancialStatsCards(),
          SizedBox(height: 16),
          Expanded(
            child: _buildEntitlementsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStatsPanel() {
    return Container(
      width: 250,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإحصائيات المالية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _buildFinancialStat('إجمالي المستلم', _totalReceived, Icons.check_circle, Colors.green),
            _buildFinancialStat('المبالغ المعلقة', _totalPending, Icons.pending, Colors.orange),
            _buildFinancialStat('المستحق الشهري', _monthlyEntitlement, Icons.calendar_today, Colors.blue),
            _buildFinancialStat('المتأخرات', _arrears, Icons.warning, Colors.red),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _makePayment(context),
              icon: Icon(Icons.payment),
              label: Text('دفع مستحقات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _calculateAutomaticEntitlements(),
              icon: Icon(Icons.calculate),
              label: Text('حساب استحقاقات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStat(String title, double amount, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(EntitlementsApi.formatCurrency(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildFinancialCard('المستلم', _totalReceived, Colors.green),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildFinancialCard('المعلق', _totalPending, Colors.orange),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildFinancialCard('المستحق', _monthlyEntitlement, Colors.blue),
        ),
      ],
    );
  }

  Widget _buildFinancialCard(String title, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: color)),
            SizedBox(height: 4),
            Text(EntitlementsApi.formatCurrency(amount), 
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntitlementsSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.attach_money, color: Colors.green, size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الاستحقاقات المالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('إجمالي المستلم: ${EntitlementsApi.formatCurrency(_totalReceived)}'),
                  Text('المبالغ المعلقة: ${EntitlementsApi.formatCurrency(_totalPending)}'),
                  Text('إجمالي الاستحقاقات: ${_entitlements.length} استحقاق'),
                ],
              ),
            ),
            Chip(
              label: Text(
                _entitlements.isNotEmpty ? 'نشط' : 'غير نشط',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _entitlements.isNotEmpty ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntitlementsTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سجل الاستحقاقات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _calculateAutomaticEntitlements(),
                      icon: Icon(Icons.calculate),
                      label: Text('حساب تلقائي'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _addEntitlement(context),
                      icon: Icon(Icons.add),
                      label: Text('إضافة استحقاق'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('النوع')),
                    DataColumn(label: Text('المبلغ')),
                    DataColumn(label: Text('التاريخ')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('الوصف')),
                    DataColumn(label: Text('الإجراءات')),
                  ],
                  rows: _entitlements.map((ent) {
                    final status = EntitlementsApi.getPaymentStatusDisplay(ent['payment_status']);
                    final type = EntitlementsApi.getEntitlementTypeDisplay(ent['entitlement_type']);
                    
                    return DataRow(cells: [
                      DataCell(Text(type)),
                      DataCell(Text(EntitlementsApi.formatCurrency(ent['amount']))),
                      DataCell(Text(EntitlementsApi.formatDate(ent['payment_date'] ?? ent['entitlement_date']))),
                      DataCell(
                        Chip(
                          label: Text(
                            status,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: EntitlementsApi.getPaymentStatusColor(ent['payment_status']),
                        ),
                      ),
                      DataCell(Text(ent['notes'] ?? '--')),
                      DataCell(Row(
                        children: [
                          if (status == 'معلق')
                            IconButton(
                              icon: Icon(Icons.payment, size: 18, color: Colors.green),
                              onPressed: () => _markAsPaid(context, ent['id']),
                            ),
                          IconButton(
                            icon: Icon(Icons.edit, size: 18),
                            onPressed: () => _editEntitlement(context, ent),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => _deleteEntitlement(context, ent['id']),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntitlementsList(BuildContext context) {
    return ListView.builder(
      itemCount: _entitlements.length,
      itemBuilder: (context, index) {
        final ent = _entitlements[index];
        final status = EntitlementsApi.getPaymentStatusDisplay(ent['payment_status']);
        final type = EntitlementsApi.getEntitlementTypeDisplay(ent['entitlement_type']);
        
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.attach_money, color: EntitlementsApi.getPaymentStatusColor(ent['payment_status'])),
            title: Text(type, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${EntitlementsApi.formatCurrency(ent['amount'])} - ${EntitlementsApi.formatDate(ent['payment_date'] ?? ent['entitlement_date'])}'),
                Text(ent['notes'] ?? '--'),
                SizedBox(height: 4),
                Chip(
                  label: Text(status, style: TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: EntitlementsApi.getPaymentStatusColor(ent['payment_status']),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (status == 'معلق')
                  PopupMenuItem(child: Text('تسديد'), value: 'pay'),
                PopupMenuItem(child: Text('تعديل'), value: 'edit'),
                PopupMenuItem(child: Text('حذف'), value: 'delete'),
              ],
              onSelected: (value) {
                if (value == 'pay') {
                  _markAsPaid(context, ent['id']);
                } else if (value == 'edit') {
                  _editEntitlement(context, ent);
                } else if (value == 'delete') {
                  _deleteEntitlement(context, ent['id']);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _addEntitlement(BuildContext context) {
    _showEntitlementFormDialog(context, null);
  }

  void _editEntitlement(BuildContext context, Map<String, dynamic> ent) {
    _showEntitlementFormDialog(context, ent);
  }

  Future<void> _markAsPaid(BuildContext context, int entId) async {
    try {
      final entitlement = _entitlements.firstWhere((ent) => ent['id'] == entId);
      final updatedData = Map<String, dynamic>.from(entitlement);
      updatedData['payment_status'] = 'paid';
      updatedData['payment_date'] = DateTime.now().toIso8601String().split('T')[0];

      await EntitlementsApi.updateEntitlement(entId, updatedData);
      
      setState(() {
        final index = _entitlements.indexWhere((ent) => ent['id'] == entId);
        if (index != -1) {
          _entitlements[index]['payment_status'] = 'paid';
          _entitlements[index]['payment_date'] = updatedData['payment_date'];
          _calculateTotals(_entitlements);
        }
      });
      _showSuccessMessage('تم تسديد الاستحقاق بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في تسديد الاستحقاق: $e');
    }
  }

  Future<void> _deleteEntitlement(BuildContext context, int entId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف استحقاق'),
        content: Text('هل أنت متأكد من حذف هذا الاستحقاق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await EntitlementsApi.deleteEntitlement(entId);
                setState(() {
                  _entitlements.removeWhere((ent) => ent['id'] == entId);
                  _calculateTotals(_entitlements);
                });
                _showSuccessMessage('تم حذف الاستحقاق بنجاح');
              } catch (e) {
                _showErrorMessage('فشل في حذف الاستحقاق: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _calculateAutomaticEntitlements() async {
    try {
      final calculatedEntitlements = await EntitlementsApi.calculateAutomaticEntitlements(widget.personnelId);
      
      setState(() {
        _entitlements.addAll(calculatedEntitlements);
        _calculateTotals(_entitlements);
      });
      _showSuccessMessage('تم حساب الاستحقاقات التلقائية بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في حساب الاستحقاقات التلقائية: $e');
    }
  }

  void _makePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('دفع المستحقات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المبلغ المعلق: ${EntitlementsApi.formatCurrency(_totalPending)}'),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'المبلغ المدفوع',
                prefixText: 'ج.س ',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'طريقة الدفع'),
              items: ['نقدي', 'تحويل بنكي', 'شيك', 'حوالة']
                  .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // معالجة الدفع
              Navigator.pop(context);
              _showSuccessMessage('تم تسديد المستحقات بنجاح');
            },
            child: Text('تأكيد الدفع'),
          ),
        ],
      ),
    );
  }

  void _showEntitlementFormDialog(BuildContext context, Map<String, dynamic>? ent) {
  // متغيرات لتخزين بيانات النموذج
  String? selectedEntitlementType = ent?['entitlement_type'] ?? 'war_share';
  String? selectedPaymentStatus = ent?['payment_status'] ?? 'pending';
  TextEditingController amountController = TextEditingController(
    text: ent?['amount']?.toString() ?? ''
  );
  TextEditingController notesController = TextEditingController(
    text: ent?['notes'] ?? ''
  );

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(ent == null ? 'إضافة استحقاق جديد' : 'تعديل الاستحقاق'),
          content: Container(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedEntitlementType,
                    decoration: InputDecoration(labelText: 'نوع الاستحقاق'),
                    items: [
                      DropdownMenuItem(value: 'war_share', child: Text('سهم حربي')),
                      DropdownMenuItem(value: 'basic_salary', child: Text('خلافة أساسية')),
                      DropdownMenuItem(value: 'transportation', child: Text('بدل انتقال')),
                      DropdownMenuItem(value: 'housing', child: Text('بدل سكن')),
                      DropdownMenuItem(value: 'performance', child: Text('مكافأة أداء')),
                      DropdownMenuItem(value: 'mujahid_basket', child: Text('سلة مجاهد')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedEntitlementType = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'المبلغ *',
                      prefixText: 'ج.س ',
                      errorText: _validateAmount(amountController.text),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(labelText: 'الوصف'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentStatus,
                    decoration: InputDecoration(labelText: 'حالة الدفع'),
                    items: [
                      DropdownMenuItem(value: 'pending', child: Text('معلق')),
                      DropdownMenuItem(value: 'paid', child: Text('مستلم')),
                      DropdownMenuItem(value: 'processing', child: Text('قيد المعالجة')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentStatus = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _validateAmount(amountController.text) == null
                  ? () {
                      _saveEntitlement(
                        context,
                        ent,
                        selectedEntitlementType!,
                        amountController.text,
                        notesController.text,
                        selectedPaymentStatus!,
                      );
                    }
                  : null,
              child: Text('حفظ'),
            ),
          ],
        );
      },
    ),
  );
}

String? _validateAmount(String value) {
  if (value.isEmpty) {
    return 'المبلغ مطلوب';
  }
  final amount = double.tryParse(value);
  if (amount == null || amount <= 0) {
    return 'المبلغ يجب أن يكون رقم صحيح';
  }
  return null;
}
bool _isSaving = false;
  Future<void> _saveEntitlement(
  BuildContext context,
  Map<String, dynamic>? ent,
  String entitlementType,
  String amount,
  String notes,
  String paymentStatus,
) async {
  if (_isSaving) return;
  
  setState(() {
    _isSaving = true;
  });
  try {
    // التحقق من صحة المبلغ
    final amountValue = double.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      _showErrorMessage('المبلغ غير صحيح');
      return;
    }

    final entitlementData = {
      'personnel_id': widget.personnelId,
      'entitlement_type': entitlementType,
      'amount': amountValue,
      'currency': 'SDG',
      'payment_status': paymentStatus,
      'notes': notes,
      'entitlement_date': DateTime.now().toIso8601String().split('T')[0],
    };

    // إذا كانت حالة الدفع "مدفوع"، نضيف تاريخ الدفع
    if (paymentStatus == 'paid') {
      entitlementData['payment_date'] = DateTime.now().toIso8601String().split('T')[0];
    }

    if (ent == null) {
      // إنشاء استحقاق جديد
      await EntitlementsApi.createEntitlement(entitlementData);
      _showSuccessMessage('تم إضافة الاستحقاق بنجاح');
    } else {
      // تحديث استحقاق موجود
      await EntitlementsApi.updateEntitlement(ent['id'], entitlementData);
      _showSuccessMessage('تم تعديل الاستحقاق بنجاح');
    }
    
    // إعادة تحميل البيانات
    _loadEntitlementsData();
  } catch (e) {
    _showErrorMessage('فشل في حفظ الاستحقاق: $e');
  } finally {
    setState(() {
      _isSaving = false;
    });
  }
}
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
}