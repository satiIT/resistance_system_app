// lib/presentation/pages/personnel/personnel_entitlements_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelEntitlementsScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelEntitlementsScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelEntitlementsScreenState createState() => _PersonnelEntitlementsScreenState();
}

class _PersonnelEntitlementsScreenState extends State<PersonnelEntitlementsScreen> {
  List<Map<String, dynamic>> _entitlements = [];
  double _totalReceived = 0.0;
  double _totalPending = 0.0;

  @override
  void initState() {
    super.initState();
    _loadEntitlementsData();
  }

  void _loadEntitlementsData() {
    // بيانات وهمية للاستحقاقات
    setState(() {
      _entitlements = [
        {
          'id': 1,
          'type': 'خلافة أساسية',
          'amount': 500000.0,
          'date': '2024-02-01',
          'status': 'مستلم',
          'description': 'راتب شهر فبراير',
        },
        {
          'id': 2,
          'type': ' خلافة',
          'amount': 150000.0,
          'date': '2024-02-01',
          'status': 'مستلم',
          'description': 'بدل انتقال لشهر فبراير',
        },
        {
          'id': 3,
          'type': ' سهم حربي',
          'amount': 200000.0,
          'date': '2024-02-15',
          'status': 'مستلم',
          'description': 'مكافأة أداء متميز',
        },
        {
          'id': 4,
          'type': 'سهم حربي ',
          'amount': 300000.0,
          'date': '2024-03-01',
          'status': 'معلق',
          'description': 'بدل سكن لشهر مارس',
        },
      ];

      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalReceived = _entitlements
        .where((ent) => ent['status'] == 'مستلم')
        .fold(0.0, (sum, ent) => sum + (ent['amount'] as double));

    _totalPending = _entitlements
        .where((ent) => ent['status'] == 'معلق')
        .fold(0.0, (sum, ent) => sum + (ent['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
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
        ],
      ),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
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
            _buildFinancialStat('المستحق الشهري', 650000.0, Icons.calendar_today, Colors.blue),
            _buildFinancialStat('المتأخرات', 300000.0, Icons.warning, Colors.red),
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
                Text(_formatCurrency(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            Text(_formatCurrency(amount), 
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
                  Text('إجمالي المستلم: ${_formatCurrency(_totalReceived)}'),
                  Text('المبالغ المعلقة: ${_formatCurrency(_totalPending)}'),
                ],
              ),
            ),
            Chip(
              label: Text('نشط', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
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
                ElevatedButton.icon(
                  onPressed: () => _addEntitlement(context),
                  icon: Icon(Icons.add),
                  label: Text('إضافة استحقاق'),
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
                    return DataRow(cells: [
                      DataCell(Text(ent['type'])),
                      DataCell(Text(_formatCurrency(ent['amount']))),
                      DataCell(Text(ent['date'])),
                      DataCell(
                        Chip(
                          label: Text(
                            ent['status'],
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: ent['status'] == 'مستلم' ? Colors.green : Colors.orange,
                        ),
                      ),
                      DataCell(Text(ent['description'])),
                      DataCell(Row(
                        children: [
                          if (ent['status'] == 'معلق')
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
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.attach_money, color: ent['status'] == 'مستلم' ? Colors.green : Colors.orange),
            title: Text(ent['type'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_formatCurrency(ent['amount'])} - ${ent['date']}'),
                Text(ent['description']),
                SizedBox(height: 4),
                Chip(
                  label: Text(ent['status'], style: TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: ent['status'] == 'مستلم' ? Colors.green : Colors.orange,
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (ent['status'] == 'معلق')
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

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} جنيه';
  }

  void _addEntitlement(BuildContext context) {
    _showEntitlementFormDialog(context, null);
  }

  void _editEntitlement(BuildContext context, Map<String, dynamic> ent) {
    _showEntitlementFormDialog(context, ent);
  }

  void _markAsPaid(BuildContext context, int entId) {
    setState(() {
      final index = _entitlements.indexWhere((ent) => ent['id'] == entId);
      if (index != -1) {
        _entitlements[index]['status'] = 'مستلم';
        _entitlements[index]['date'] = DateTime.now().toString().split(' ')[0];
        _calculateTotals();
      }
    });
    _showSuccessMessage('تم تسديد الاستحقاق بنجاح');
  }

  void _deleteEntitlement(BuildContext context, int entId) {
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
            onPressed: () {
              setState(() {
                _entitlements.removeWhere((ent) => ent['id'] == entId);
                _calculateTotals();
              });
              Navigator.pop(context);
              _showSuccessMessage('تم حذف الاستحقاق بنجاح');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _makePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('دفع المستحقات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المبلغ المعلق: ${_formatCurrency(_totalPending)}'),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'المبلغ المدفوع',
                prefixText: 'ج.س ',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'طريقة الدفع'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ent == null ? 'إضافة استحقاق جديد' : 'تعديل الاستحقاق'),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: ent?['type'] ?? ' سهم حربي',
                  decoration: InputDecoration(labelText: 'نوع الاستحقاق'),
                  items: [' سهم حربي', ' خلافة اساسية', 'أخرى']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {},
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: ent?['amount']?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: 'المبلغ',
                    prefixText: 'ج.س ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: ent?['description'] ?? '',
                  decoration: InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
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
            onPressed: () {
              // حفظ البيانات
              Navigator.pop(context);
              _showSuccessMessage(ent == null ? 'تم إضافة الاستحقاق بنجاح' : 'تم تعديل الاستحقاق بنجاح');
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}