// lib/presentation/pages/personnel/personnel_equipment_screen.dart
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/services/armament_api.dart';
import '../../../core/responsive/responsive_layout.dart';

class PersonnelEquipmentScreen extends StatefulWidget {
  final int personnelId;
  final String personnelName;

  const PersonnelEquipmentScreen({Key? key, required this.personnelId, required this.personnelName}) : super(key: key);

  @override
  _PersonnelEquipmentScreenState createState() => _PersonnelEquipmentScreenState();
}

class _PersonnelEquipmentScreenState extends State<PersonnelEquipmentScreen> {
  List<dynamic> _equipmentList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEquipmentData();
  }

  Future<void> _loadEquipmentData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final equipment = await ArmamentApi.getArmamentByPersonnelId(widget.personnelId);
      
      setState(() {
        _equipmentList = equipment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحميل بيانات المعدات: $e';
      });
      _showErrorMessage('فشل في تحميل بيانات المعدات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
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
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEquipmentData,
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
          Text('جاري تحميل بيانات المعدات...'),
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
            onPressed: _loadEquipmentData,
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
    final int weapons = _equipmentList.where((item) => 
        _isWeapon(item['weapon_type'])).length;
    final int protective = _equipmentList.where((item) => 
        _isProtective(item['weapon_type'])).length;
    final int serialized = _equipmentList.where((item) => 
        item['weapon_serial_number'] != null && item['weapon_serial_number'].isNotEmpty).length;

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
            _buildEquipmentStat('أسلحة', weapons.toString(), Icons.security, Colors.red),
            _buildEquipmentStat('وقائية', protective.toString(), Icons.shield, Colors.orange),
            _buildEquipmentStat('مسلسلة', serialized.toString(), Icons.confirmation_number, Colors.green),
          ],
        ),
      ),
    );
  }

  bool _isWeapon(String? type) {
    if (type == null) return false;
    final weaponTypes = ['assault_rifle', 'pistol', 'sniper_rifle', 'machine_gun', 'grenade',
                        'بندقية هجومية', 'مسدس', 'بندقية قنص', 'رشاش', 'قنبلة'];
    return weaponTypes.any((weapon) => type.toLowerCase().contains(weapon));
  }

  bool _isProtective(String? type) {
    if (type == null) return false;
    final protectiveTypes = ['protective_vest', 'helmet', 'سترة واقية', 'خوذة'];
    return protectiveTypes.any((protective) => type.toLowerCase().contains(protective));
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
                  Text('آخر تحديث: ${_getLastUpdateDate()}'),
                ],
              ),
            ),
            Chip(
              label: Text(
                _equipmentList.isNotEmpty ? 'مكتمل' : 'فارغ',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _equipmentList.isNotEmpty ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _getLastUpdateDate() {
    if (_equipmentList.isEmpty) return '--';
    final dates = _equipmentList.map((item) => item['issue_date']).where((date) => date != null).toList();
    if (dates.isEmpty) return '--';
    dates.sort((a, b) => b.compareTo(a));
    return dates.first;
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
                    DataColumn(label: Text('نوع السلاح')),
                    DataColumn(label: Text('الرقم التسلسلي')),
                    DataColumn(label: Text('ملحقات')),
                    DataColumn(label: Text('تاريخ الإصدار')),
                    DataColumn(label: Text('صادر من')),
                    DataColumn(label: Text('الإجراءات')),
                  ],
                  rows: _equipmentList.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(ArmamentApi.getWeaponTypeDisplay(item['weapon_type']))),
                      DataCell(Text(item['weapon_serial_number'] ?? '--')),
                      DataCell(Text(item['weapon_accessories'] ?? '--')),
                      DataCell(Text(_formatDate(item['issue_date']))),
                      DataCell(Text(item['issued_by'] ?? '--')),
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
                          if (_isWeapon(item['weapon_type'])) 
                            IconButton(
                              icon: Icon(Icons.build, size: 18, color: Colors.orange),
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
            leading: ArmamentApi.getEquipmentIcon(item['weapon_type']),
            title: Text(ArmamentApi.getWeaponTypeDisplay(item['weapon_type']), 
                       style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الرقم التسلسلي: ${item['weapon_serial_number'] ?? '--'}'),
                Text('التاريخ: ${_formatDate(item['issue_date'])}'),
                Text('صادر من: ${item['issued_by'] ?? '--'}'),
                if (item['weapon_accessories'] != null && item['weapon_accessories'].isNotEmpty)
                  Text('ملحقات: ${item['weapon_accessories']}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text('تعديل'), value: 'edit'),
                if (_isWeapon(item['weapon_type']))
                  PopupMenuItem(child: Text('صيانة'), value: 'maintain'),
                PopupMenuItem(child: Text('حذف'), value: 'delete'),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editEquipment(context, item);
                } else if (value == 'maintain') {
                  _maintainWeapon(context, item);
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

  String _formatDate(String? date) {
    if (date == null) return '--';
    return date;
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
        content: Text('هل تريد طلب صيانة لـ ${ArmamentApi.getWeaponTypeDisplay(item['weapon_type'])}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('تم طلب صيانة ${ArmamentApi.getWeaponTypeDisplay(item['weapon_type'])} بنجاح');
            },
            child: Text('طلب الصيانة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEquipment(BuildContext context, int itemId) async {
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
            onPressed: () async {
              try {
                Navigator.pop(context);
                await ArmamentApi.deleteArmament(itemId);
                setState(() {
                  _equipmentList.removeWhere((item) => item['id'] == itemId);
                });
                _showSuccessMessage('تم حذف القطعة بنجاح');
              } catch (e) {
                _showErrorMessage('فشل في حذف القطعة: $e');
              }
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
                DropdownButtonFormField<String>(
                  value: item?['weapon_type'] ?? 'assault_rifle',
                  decoration: InputDecoration(labelText: 'نوع السلاح'),
                  items: [
                    {'value': 'assault_rifle', 'display': 'بندقية هجومية'},
                    {'value': 'pistol', 'display': 'مسدس'},
                    {'value': 'sniper_rifle', 'display': 'بندقية قنص'},
                    {'value': 'machine_gun', 'display': 'رشاش'},
                    {'value': 'protective_vest', 'display': 'سترة واقية'},
                    {'value': 'helmet', 'display': 'خوذة'},
                    {'value': 'grenade', 'display': 'قنبلة'},
                    {'value': 'ammunition', 'display': 'ذخيرة'},
                  ].map((type) => DropdownMenuItem(value: type['value'], child: Text(type['display']!))).toList(),
                  onChanged: (value) {},
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: item?['weapon_serial_number'] ?? '',
                  decoration: InputDecoration(labelText: 'الرقم التسلسلي'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: item?['weapon_accessories'] ?? '',
                  decoration: InputDecoration(labelText: 'الملحقات'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: item?['issued_by'] ?? '',
                  decoration: InputDecoration(labelText: 'صادر من'),
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
              _saveEquipment(item);
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEquipment(Map<String, dynamic>? item) async {
    try {
      final equipmentData = {
        'personnel_id': widget.personnelId,
        'weapon_type': 'assault_rifle', // سيتم تحديثه من النموذج
        'weapon_serial_number': '', // سيتم تحديثه من النموذج
        'weapon_accessories': '', // سيتم تحديثه من النموذج
        'issue_date': DateTime.now().toIso8601String().split('T')[0],
        'issued_by': '', // سيتم تحديثه من النموذج
        'notes': 'تم الإضافة عبر النظام',
      };

      if (item == null) {
        await ArmamentApi.createArmament(equipmentData);
        _showSuccessMessage('تم إضافة المعدات بنجاح');
      } else {
        await ArmamentApi.updateArmament(item['id'], equipmentData);
        _showSuccessMessage('تم تعديل المعدات بنجاح');
      }
      _loadEquipmentData(); // إعادة تحميل البيانات
    } catch (e) {
      _showErrorMessage('فشل في حفظ المعدات: $e');
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