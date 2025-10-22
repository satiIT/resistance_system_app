// lib/presentation/pages/personnel/personnel_movements_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/services/movements_api.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelMovementsScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelMovementsScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelMovementsScreenState createState() => _PersonnelMovementsScreenState();
}

class _PersonnelMovementsScreenState extends State<PersonnelMovementsScreen> {
  List<dynamic> _movements = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMovementsData();
  }

  Future<void> _loadMovementsData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final movements = await MovementsApi.getMovementsByPersonnelId(widget.personnelId);
      
      setState(() {
        _movements = movements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحميل بيانات التحركات: $e';
      });
      _showErrorMessage('فشل في تحميل بيانات التحركات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
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
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMovementsData,
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
          Text('جاري تحميل بيانات التحركات...'),
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
            onPressed: _loadMovementsData,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
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
    final int completed = _movements.where((m) => 
        m['status'] == 'منتهي' || m['status'] == 'مكتمل' || m['status'] == 'completed').length;
    final int inProgress = _movements.where((m) => 
        m['status'] == 'قيد التنفيذ' || m['status'] == 'نشط' || m['status'] == 'active').length;
    final int transfers = _movements.where((m) => 
        m['movement_type'] == 'نقل' || m['movement_type'] == 'transfer').length;

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
                  Text('آخر تحرك: ${_movements.isNotEmpty ? _getMovementTypeText(_movements.last['movement_type']) : 'لا يوجد'}'),
                ],
              ),
            ),
            Chip(
              label: Text(
                _movements.isNotEmpty ? 'نشط' : 'غير نشط',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _movements.isNotEmpty ? Colors.green : Colors.grey,
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
                      DataCell(Text(_getMovementTypeText(movement['movement_type']))),
                      DataCell(Text(movement['from_location'] ?? '--')),
                      DataCell(Text(movement['to_location'] ?? '--')),
                      DataCell(Text(_formatDate(movement['movement_date']))),
                      DataCell(Text(_getDuration(movement))),
                      DataCell(
                        Chip(
                          label: Text(
                            _getStatusText(movement['status']),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(movement['status']),
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
                          if (_isMovementInProgress(movement))
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
            title: Text(_getMovementTypeText(movement['movement_type']), style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('من ${movement['from_location'] ?? '--'} إلى ${movement['to_location'] ?? '--'}'),
                Text('${_formatDate(movement['movement_date'])} - ${_getDuration(movement)}'),
                Row(
                  children: [
                    Chip(
                      label: Text(_getStatusText(movement['status']), style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: _getStatusColor(movement['status']),
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
                if (_isMovementInProgress(movement))
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

  // Helper methods
  String _getMovementTypeText(String? movementType) {
    switch (movementType?.toLowerCase()) {
      case 'transfer':
      case 'نقل':
        return 'نقل';
      case 'distribution':
      case 'توزيع':
        return 'توزيع';
      case 'mission':
      case 'مهمة':
        return 'مهمة';
      case 'leave':
      case 'إجازة':
        return 'إجازة';
      case 'treatment':
      case 'علاج':
        return 'علاج';
      default:
        return movementType ?? '--';
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'منتهي':
      case 'مكتمل':
        return 'منتهي';
      case 'active':
      case 'نشط':
      case 'قيد التنفيذ':
        return 'قيد التنفيذ';
      case 'pending':
      case 'معلق':
        return 'معلق';
      default:
        return status ?? '--';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'منتهي':
      case 'مكتمل':
        return Colors.green;
      case 'active':
      case 'نشط':
      case 'قيد التنفيذ':
        return Colors.orange;
      case 'pending':
      case 'معلق':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  bool _isMovementInProgress(Map<String, dynamic> movement) {
    final status = movement['status']?.toString().toLowerCase();
    return status == 'active' || status == 'نشط' || status == 'قيد التنفيذ';
  }

  String _formatDate(String? date) {
    if (date == null) return '--';
    return date;
  }

  String _getDuration(Map<String, dynamic> movement) {
    // يمكنك تحسين هذا المنطق بناءً على بياناتك
    if (movement['mission_description'] != null) {
      final desc = movement['mission_description'].toString();
      if (desc.contains('يوم')) {
        return desc;
      }
    }
    return 'مستمر';
  }

  void _addMovement(BuildContext context) {
    _showMovementFormDialog(context, null);
  }

  void _editMovement(BuildContext context, Map<String, dynamic> movement) {
    _showMovementFormDialog(context, movement);
  }

  Future<void> _completeMovement(BuildContext context, int movementId) async {
    try {
      final movement = _movements.firstWhere((m) => m['id'] == movementId);
      final updatedData = Map<String, dynamic>.from(movement);
      updatedData['status'] = 'منتهي';

      await MovementsApi.updateMovement(movementId, updatedData);
      
      setState(() {
        final index = _movements.indexWhere((m) => m['id'] == movementId);
        if (index != -1) {
          _movements[index]['status'] = 'منتهي';
        }
      });
      _showSuccessMessage('تم إنهاء التحرك بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في إنهاء التحرك: $e');
    }
  }

  Future<void> _deleteMovement(BuildContext context, int movementId) async {
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
            onPressed: () async {
              try {
                Navigator.pop(context);
                await MovementsApi.deleteMovement(movementId);
                setState(() {
                  _movements.removeWhere((m) => m['id'] == movementId);
                });
                _showSuccessMessage('تم حذف التحرك بنجاح');
              } catch (e) {
                _showErrorMessage('فشل في حذف التحرك: $e');
              }
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
                  initialValue: movement?['from_location'] ?? '',
                  decoration: InputDecoration(labelText: 'من الوحدة'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: movement?['to_location'] ?? '',
                  decoration: InputDecoration(labelText: 'إلى الوحدة'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: movement?['mission_description'] ?? '',
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
              _saveMovement(movement);
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMovement(Map<String, dynamic>? movement) async {
    try {
      final movementData = {
        'personnel_id': widget.personnelId,
        'movement_type': 'توزيع', // سيتم تحديثه من النموذج
        'from_location': 'من الوحدة', // سيتم تحديثه من النموذج
        'to_location': 'إلى الوحدة', // سيتم تحديثه من النموذج
        'movement_date': DateTime.now().toIso8601String().split('T')[0],
        'mission_description': 'السبب', // سيتم تحديثه من النموذج
        'status': 'قيد التنفيذ',
      };

      if (movement == null) {
        await MovementsApi.createMovement(movementData);
        _showSuccessMessage('تم إضافة التحرك بنجاح');
      } else {
        await MovementsApi.updateMovement(movement['id'], movementData);
        _showSuccessMessage('تم تعديل التحرك بنجاح');
      }
      _loadMovementsData(); // إعادة تحميل البيانات
    } catch (e) {
      _showErrorMessage('فشل في حفظ التحرك: $e');
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