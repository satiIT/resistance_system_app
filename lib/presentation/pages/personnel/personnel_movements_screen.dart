// lib/presentation/pages/personnel/personnel_movements_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelMovementsScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelMovementsScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelMovementsScreenState createState() => _PersonnelMovementsScreenState();
}

class _PersonnelMovementsScreenState extends State<PersonnelMovementsScreen> {
  List<Map<String, dynamic>> _movements = [];

  @override
  void initState() {
    super.initState();
    _loadMovementsData();
  }

  void _loadMovementsData() {
    // بيانات وهمية للتحركات
    setState(() {
      _movements = [
        {
          'id': 1,
          'movement_type': 'توزيع',
          'from_unit': 'مركز التجنيد',
          'to_unit': 'عهد الرجال 1',
          'date': '2024-01-15',
          'reason': 'توزيع أولي',
          'duration': 'مستمر',
          'status': 'منتهي',
          'notes': 'تم التوزيع بنجاح'
        },
        {
          'id': 2,
          'movement_type': 'نقل',
          'from_unit': 'عهد الرجال 1',
          'to_unit': 'عهد الرجال 2',
          'date': '2024-02-01',
          'reason': 'متطلبات operacyjne',
          'duration': '30 يوم',
          'status': 'منتهي',
          'notes': 'نقل مؤقت'
        },
        {
          'id': 3,
          'movement_type': 'مهمة',
          'from_unit': 'عهد الرجال 2',
          'to_unit': 'منطقة العمليات الشمالية',
          'date': '2024-03-01',
          'reason': 'مهمة قتالية',
          'duration': '45 يوم',
          'status': 'قيد التنفيذ',
          'notes': 'مهمة خاصة'
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
        title: Text('التحركات والتوزيعات - ${widget.personnelName}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addMovement(context),
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
                _buildMovementsSummary(),
                SizedBox(height: 16),
                Expanded(
                  child: _buildMovementsTable(context),
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
          _buildMovementsSummary(),
          SizedBox(height: 16),
          Expanded(
            child: _buildMovementsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel() {
    final int totalMovements = _movements.length;
    final int completed = _movements.where((m) => m['status'] == 'منتهي').length;
    final int inProgress = _movements.where((m) => m['status'] == 'قيد التنفيذ').length;
    final int transfers = _movements.where((m) => m['movement_type'] == 'نقل').length;

    return Container(
      width: 200,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إحصائيات التحركات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _buildMovementStat('إجمالي التحركات', totalMovements.toString(), Icons.directions, Colors.blue),
            _buildMovementStat('منتهية', completed.toString(), Icons.check_circle, Colors.green),
            _buildMovementStat('قيد التنفيذ', inProgress.toString(), Icons.schedule, Colors.orange),
            _buildMovementStat('عمليات نقل', transfers.toString(), Icons.swap_horiz, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementStat(String title, String value, IconData icon, Color color) {
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

  Widget _buildMovementsSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.directions, color: Colors.blue, size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سجل التحركات والتوزيعات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('إجمالي التحركات: ${_movements.length} حركة'),
                  Text('آخر تحرك: ${_movements.isNotEmpty ? _movements.last['movement_type'] : 'لا يوجد'}'),
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

  Widget _buildMovementsTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سجل التحركات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _addMovement(context),
                  icon: Icon(Icons.add),
                  label: Text('إضافة تحرك'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('نوع التحرك')),
                    DataColumn(label: Text('من')),
                    DataColumn(label: Text('إلى')),
                    DataColumn(label: Text('التاريخ')),
                    DataColumn(label: Text('المدة')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('الإجراءات')),
                  ],
                  rows: _movements.map((movement) {
                    return DataRow(cells: [
                      DataCell(Text(movement['movement_type'])),
                      DataCell(Text(movement['from_unit'])),
                      DataCell(Text(movement['to_unit'])),
                      DataCell(Text(movement['date'])),
                      DataCell(Text(movement['duration'])),
                      DataCell(
                        Chip(
                          label: Text(
                            movement['status'],
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: movement['status'] == 'منتهي' ? Colors.green : Colors.orange,
                        ),
                      ),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 18),
                            onPressed: () => _editMovement(context, movement),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () => _deleteMovement(context, movement['id']),
                          ),
                          if (movement['status'] == 'قيد التنفيذ')
                            IconButton(
                              icon: Icon(Icons.check, size: 18, color: Colors.green),
                              onPressed: () => _completeMovement(context, movement['id']),
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

  Widget _buildMovementsList(BuildContext context) {
    return ListView.builder(
      itemCount: _movements.length,
      itemBuilder: (context, index) {
        final movement = _movements[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.directions, color: Colors.blue),
            title: Text(movement['movement_type'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('من ${movement['from_unit']} إلى ${movement['to_unit']}'),
                Text('${movement['date']} - ${movement['duration']}'),
                Row(
                  children: [
                    Chip(
                      label: Text(movement['status'], style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: movement['status'] == 'منتهي' ? Colors.green : Colors.orange,
                    ),
                    if (movement['notes'] != null && movement['notes'].isNotEmpty) ...[
                      SizedBox(width: 8),
                      Icon(Icons.note, size: 16, color: Colors.grey),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (movement['status'] == 'قيد التنفيذ')
                  PopupMenuItem(child: Text('إنهاء'), value: 'complete'),
                PopupMenuItem(child: Text('تعديل'), value: 'edit'),
                PopupMenuItem(child: Text('حذف'), value: 'delete'),
              ],
              onSelected: (value) {
                if (value == 'complete') {
                  _completeMovement(context, movement['id']);
                } else if (value == 'edit') {
                  _editMovement(context, movement);
                } else if (value == 'delete') {
                  _deleteMovement(context, movement['id']);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _addMovement(BuildContext context) {
    _showMovementFormDialog(context, null);
  }

  void _editMovement(BuildContext context, Map<String, dynamic> movement) {
    _showMovementFormDialog(context, movement);
  }

  void _completeMovement(BuildContext context, int movementId) {
    setState(() {
      final index = _movements.indexWhere((m) => m['id'] == movementId);
      if (index != -1) {
        _movements[index]['status'] = 'منتهي';
      }
    });
    _showSuccessMessage('تم إنهاء التحرك بنجاح');
  }

  void _deleteMovement(BuildContext context, int movementId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف تحرك'),
        content: Text('هل أنت متأكد من حذف هذا التحرك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _movements.removeWhere((m) => m['id'] == movementId);
              });
              Navigator.pop(context);
              _showSuccessMessage('تم حذف التحرك بنجاح');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showMovementFormDialog(BuildContext context, Map<String, dynamic>? movement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(movement == null ? 'إضافة تحرك جديد' : 'تعديل التحرك'),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: movement?['movement_type'] ?? 'توزيع',
                  decoration: InputDecoration(labelText: 'نوع التحرك'),
                  items: ['توزيع', 'نقل', 'مهمة', 'إجازة', 'علاج']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {},
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: movement?['from_unit'] ?? '',
                  decoration: InputDecoration(labelText: 'من الوحدة'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: movement?['to_unit'] ?? '',
                  decoration: InputDecoration(labelText: 'إلى الوحدة'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: movement?['reason'] ?? '',
                  decoration: InputDecoration(labelText: 'السبب'),
                  maxLines: 2,
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
              _showSuccessMessage(movement == null ? 'تم إضافة التحرك بنجاح' : 'تم تعديل التحرك بنجاح');
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