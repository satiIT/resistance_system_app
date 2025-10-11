// lib/presentation/pages/personnel/personnel_equipment_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelEquipmentScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelEquipmentScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelEquipmentScreenState createState() => _PersonnelEquipmentScreenState();
}

class _PersonnelEquipmentScreenState extends State<PersonnelEquipmentScreen> {
  List<Map<String, dynamic>> _equipmentList = [];

  @override
  void initState() {
    super.initState();
    _loadEquipmentData();
  }

  void _loadEquipmentData() {
    // بيانات وهمية للمعدات
    setState(() {
      _equipmentList = [
        {
          'id': 1,
          'name': 'بندقية AK-47',
          'type': 'سلاح ناري',
          'serial_number': 'AK47-001',
          'condition': 'جيدة',
          'issue_date': '2024-01-15',
          'return_date': '',
          'status': 'مستلم',
        },
        {
          'id': 2,
          'name': 'سترة واقية',
          'type': 'معدات وقائية',
          'serial_number': 'VEST-045',
          'condition': 'جيدة',
          'issue_date': '2024-01-15',
          'return_date': '',
          'status': 'مستلم',
        },
        {
          'id': 3,
          'name': 'خوذة',
          'type': 'معدات وقائية',
          'serial_number': 'HELMET-123',
          'condition': 'متوسطة',
          'issue_date': '2024-01-15',
          'return_date': '',
          'status': 'مستلم',
        },
        {
          'id': 4,
          'name': 'ذخيرة 7.62 ملم',
          'type': 'ذخيرة',
          'quantity': 120,
          'issue_date': '2024-02-01',
          'status': 'مستلم',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    // ignore: unused_local_variable
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('المعدات والأسلحة - ${widget.personnelName}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addEquipment(context),
          ),
        ],
      ),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // لوحة الإحصائيات
        _buildStatsPanel(),
        // القائمة الرئيسية
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEquipmentSummary(),
                SizedBox(height: 16),
                Expanded(
                  child: _buildEquipmentTable(context),
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
          _buildEquipmentSummary(),
          SizedBox(height: 16),
          Expanded(
            child: _buildEquipmentList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel() {
    final int totalItems = _equipmentList.length;
    final int goodCondition = _equipmentList.where((item) => item['condition'] == 'جيدة').length;
    final int weapons = _equipmentList.where((item) => item['type'] == 'سلاح ناري').length;
    final int protective = _equipmentList.where((item) => item['type'] == 'معدات وقائية').length;

    return Container(
      width: 200,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إحصائيات المعدات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _buildEquipmentStat('إجمالي القطع', totalItems.toString(), Icons.inventory, Colors.blue),
            _buildEquipmentStat('بحالة جيدة', goodCondition.toString(), Icons.check_circle, Colors.green),
            _buildEquipmentStat('أسلحة', weapons.toString(), Icons.security, Colors.red),
            _buildEquipmentStat('وقائية', protective.toString(), Icons.shield, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentStat(String title, String value, IconData icon, Color color) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.inventory, color: Colors.blue, size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المعدات والأسلحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('إجمالي القطع: ${_equipmentList.length} قطعة'),
                  Text('آخر تحديث: ${DateTime.now().toString().split(' ')[0]}'),
                ],
              ),
            ),
            Chip(
              label: Text('مكتمل', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سجل المعدات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _addEquipment(context),
                  icon: Icon(Icons.add),
                  label: Text('إضافة معدات'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('اسم القطعة')),
                    DataColumn(label: Text('النوع')),
                    DataColumn(label: Text('الرقم التسلسلي')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('تاريخ الإصدار')),
                    DataColumn(label: Text('الإجراءات')),
                  ],
                  rows: _equipmentList.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(item['name'])),
                      DataCell(Text(item['type'])),
                      DataCell(Text(item['serial_number'] ?? '--')),
                      DataCell(
                        Chip(
                          label: Text(
                            item['condition'] ?? item['status'],
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getConditionColor(item['condition'] ?? item['status']),
                        ),
                      ),
                      DataCell(Text(item['issue_date'])),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 18),
                            onPressed: () => _editEquipment(context, item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => _deleteEquipment(context, item['id']),
                          ),
                          if (item['type'] == 'سلاح ناري') 
                            IconButton(
                              icon: Icon(Icons.bolt, size: 18, color: Colors.orange),
                              onPressed: () => _maintainWeapon(context, item),
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

  Widget _buildEquipmentList(BuildContext context) {
    return ListView.builder(
      itemCount: _equipmentList.length,
      itemBuilder: (context, index) {
        final item = _equipmentList[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _getEquipmentIcon(item['type']),
            title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item['type']} - ${item['serial_number'] ?? ''}'),
                Text('الإصدار: ${item['issue_date']}'),
                Row(
                  children: [
                    Chip(
                      label: Text(item['condition'] ?? item['status'], 
                              style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: _getConditionColor(item['condition'] ?? item['status']),
                    ),
                    if (item['quantity'] != null) ...[
                      SizedBox(width: 8),
                      Chip(
                        label: Text('${item['quantity']} قطعة', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.blue[100],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text('تعديل'), value: 'edit'),
                PopupMenuItem(child: Text('صيانة'), value: 'maintain'),
                PopupMenuItem(child: Text('إرجاع'), value: 'return'),
                PopupMenuItem(child: Text('حذف'), value: 'delete'),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editEquipment(context, item);
                } else if (value == 'maintain') {
                  _maintainWeapon(context, item);
                } else if (value == 'return') {
                  _returnEquipment(context, item);
                } else if (value == 'delete') {
                  _deleteEquipment(context, item['id']);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Icon _getEquipmentIcon(String type) {
    switch (type) {
      case 'سلاح ناري':
        return Icon(Icons.security, color: Colors.red);
      case 'معدات وقائية':
        return Icon(Icons.shield, color: Colors.orange);
      case 'ذخيرة':
        return Icon(Icons.bolt, color: Colors.yellow[700]);
      default:
        return Icon(Icons.inventory, color: Colors.blue);
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'جيدة':
      case 'مستلم':
        return Colors.green;
      case 'متوسطة':
        return Colors.orange;
      case 'سيئة':
      case 'تحت الصيانة':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addEquipment(BuildContext context) {
    _showEquipmentFormDialog(context, null);
  }

  void _editEquipment(BuildContext context, Map<String, dynamic> item) {
    _showEquipmentFormDialog(context, item);
  }

  void _maintainWeapon(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('طلب صيانة'),
        content: Text('هل تريد طلب صيانة لـ ${item['name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // طلب الصيانة
              Navigator.pop(context);
              _showSuccessMessage('تم طلب صيانة ${item['name']} بنجاح');
            },
            child: Text('طلب الصيانة'),
          ),
        ],
      ),
    );
  }

  void _returnEquipment(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إرجاع المعدات'),
        content: Text('هل تريد إرجاع ${item['name']} إلى المخزن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // إرجاع المعدات
              setState(() {
                _equipmentList.removeWhere((equip) => equip['id'] == item['id']);
              });
              Navigator.pop(context);
              _showSuccessMessage('تم إرجاع ${item['name']} بنجاح');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('إرجاع'),
          ),
        ],
      ),
    );
  }

  void _deleteEquipment(BuildContext context, int itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المعدات'),
        content: Text('هل أنت متأكد من حذف هذه القطعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _equipmentList.removeWhere((item) => item['id'] == itemId);
              });
              Navigator.pop(context);
              _showSuccessMessage('تم حذف القطعة بنجاح');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showEquipmentFormDialog(BuildContext context, Map<String, dynamic>? item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'إضافة معدات جديدة' : 'تعديل المعدات'),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: item?['name'] ?? '',
                  decoration: InputDecoration(labelText: 'اسم القطعة'),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: item?['type'] ?? 'سلاح ناري',
                  decoration: InputDecoration(labelText: 'نوع المعدات'),
                  items: ['سلاح ناري', 'معدات وقائية', 'ذخيرة', 'معدات اتصال', 'أخرى']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {},
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: item?['serial_number'] ?? '',
                  decoration: InputDecoration(labelText: 'الرقم التسلسلي'),
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
              _showSuccessMessage(item == null ? 'تم إضافة المعدات بنجاح' : 'تم تعديل المعدات بنجاح');
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