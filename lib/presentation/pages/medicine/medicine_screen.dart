// screens/medicine/medicine_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/medicine_item.dart';
import '../../../core/services/medicine_api.dart';
import 'medicine_form_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineScreen extends StatefulWidget {
  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  List<MedicineItem> _medicineItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: الكل, 1: وارد فقط, 2: منصرف فقط
  int _selectedView = 0; // 0: القائمة, 1: البطاقات

  @override
  void initState() {
    super.initState();
    _loadMedicineData();
  }

  Future<void> _loadMedicineData() async {
    try {
      final response = await MedicineApi.getMedicineItems();
      setState(() {
        _medicineItems = response;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<MedicineItem> get _filteredItems {
    var filtered = _medicineItems;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return (item.itemName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (item.medicineType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (item.movementType.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // تطبيق الفلتر
    if (_selectedFilter == 1) {
      filtered = filtered.where((item) => item.movementType == 'وارد').toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((item) => item.movementType == 'منصرف').toList();
    }

    return filtered;
  }

  Widget _buildMedicineCard(MedicineItem item) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.typeColor,
          child: Icon(item.typeIcon, color: Colors.white),
        ),
        title: Text(
          item.itemName ?? 'غير محدد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('النوع: ${item.medicineType ?? "غير محدد"}'),
            Text('الكمية: ${item.quantity} ${item.unit ?? ""}'),
            Text('التاريخ: ${_formatDate(item.movementDate)}'),
            Row(
              children: [
                Chip(
                  label: Text(
                    item.movementType,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: item.typeColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                SizedBox(width: 4),
                if (item.isExpired)
                  Chip(
                    label: Text(
                      'منتهي',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('عرض التفاصيل'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewItemDetails(item);
                break;
              case 'edit':
                _editItem(item);
                break;
              case 'delete':
                _deleteItem(item);
                break;
            }
          },
        ),
        onTap: () => _viewItemDetails(item),
      ),
    );
  }

  Widget _buildMedicineGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Card(
          elevation: 3,
          child: InkWell(
            onTap: () => _viewItemDetails(item),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: item.typeColor,
                        radius: 16,
                        child: Icon(item.typeIcon, size: 16, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.itemName ?? 'غير محدد',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.medicineType ?? "غير محدد",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.quantity} ${item.unit ?? ""}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: item.typeColor),
                    ),
                    child: Text(
                      item.movementType,
                      style: TextStyle(fontSize: 10, color: item.typeColor),
                    ),
                  ),
                  if (item.isExpired) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.error, size: 12, color: Colors.red),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'منتهي',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _viewItemDetails(MedicineItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailScreen(item: item),
      ),
    );
  }

  void _editItem(MedicineItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineFormScreen(existingItem: item),
      ),
    ).then((_) => _loadMedicineData());
  }

  void _deleteItem(MedicineItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text('هل تريد حذف سجل ${item.itemName ?? "هذا الدواء"}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(item.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    try {
      await MedicineApi.deleteMedicineItem(id);
      setState(() {
        _medicineItems.removeWhere((item) => item.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم الحذف بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في الحذف: $e');
    }
  }

  void _addNewItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicineFormScreen()),
    ).then((_) => _loadMedicineData());
  }

  void _showMedicineStats() async {
    try {
      final stats = await MedicineApi.getMedicineStats();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue),
              SizedBox(width: 8),
              Text('إحصائيات الأدوية'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('إجمالي الأدوية', _medicineItems.length.toString(), Icons.medication),
              _buildStatItem('حركات وارد', _medicineItems.where((item) => item.movementType == 'وارد').length.toString(), Icons.input),
              _buildStatItem('حركات منصرف', _medicineItems.where((item) => item.movementType == 'منصرف').length.toString(), Icons.output),
              _buildStatItem('منتهي الصلاحية', _medicineItems.where((item) => item.isExpired).length.toString(), Icons.error),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الإحصائيات: $e');
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(value, style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: Text('الكل (${_medicineItems.length})'),
            selected: _selectedFilter == 0,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 0 : _selectedFilter;
              });
            },
          ),
          FilterChip(
            label: Text('وارد فقط (${_medicineItems.where((item) => item.movementType == 'وارد').length})'),
            selected: _selectedFilter == 1,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 1 : 0;
              });
            },
          ),
          FilterChip(
            label: Text('منصرف فقط (${_medicineItems.where((item) => item.movementType == 'منصرف').length})'),
            selected: _selectedFilter == 2,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 2 : 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(_selectedView == 0 ? Icons.view_list : Icons.view_list_outlined),
            onPressed: () {
              setState(() {
                _selectedView = 0;
              });
            },
            color: _selectedView == 0 ? Colors.blue : Colors.grey,
          ),
          IconButton(
            icon: Icon(_selectedView == 1 ? Icons.grid_view : Icons.grid_view_outlined),
            onPressed: () {
              setState(() {
                _selectedView = 1;
              });
            },
            color: _selectedView == 1 ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استمارة صيدلية وارد ومنصرف الأدوية - استمارة رقم (7)'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewItem,
            tooltip: 'إضافة سجل جديد',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('الإحصائيات'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'expired',
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('المنتهي الصلاحية'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'near_expiry',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('قريب الانتهاء'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.green),
                    SizedBox(width: 8),
                    Text('تحديث البيانات'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'stats':
                  _showMedicineStats();
                  break;
                case 'expired':
                  _showExpiredMedicines();
                  break;
                case 'near_expiry':
                  _showNearExpiryMedicines();
                  break;
                case 'refresh':
                  _loadMedicineData();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'بحث في الأدوية',
                hintText: 'ابحث باسم الدواء، النوع، أو حركة...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          _buildViewToggle(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري تحميل البيانات...'),
                      ],
                    ),
                  )
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty && _selectedFilter == 0
                                  ? 'لا توجد سجلات للأدوية'
                                  : 'لا توجد نتائج للبحث',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            if (_searchQuery.isEmpty && _selectedFilter == 0)
                              ElevatedButton.icon(
                                onPressed: _addNewItem,
                                icon: Icon(Icons.add),
                                label: Text('إضافة سجل جديد'),
                              ),
                          ],
                        ),
                      )
                    : _selectedView == 0
                        ? ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              return _buildMedicineCard(_filteredItems[index]);
                            },
                          )
                        : _buildMedicineGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        child: Icon(Icons.add),
        tooltip: 'إضافة سجل جديد',
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showExpiredMedicines() async {
    try {
      final expiredMedicines = await MedicineApi.getExpiringMedicines();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('الأدوية المنتهية الصلاحية'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: expiredMedicines.isEmpty
                ? Text('لا توجد أدوية منتهية الصلاحية')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var item in expiredMedicines.take(10))
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.error, size: 16, color: Colors.white),
                          ),
                          title: Text(item.itemName ?? 'غير محدد'),
                          subtitle: Text('انتهى: ${_formatDate(item.expiryDate!)}'),
                          trailing: Text(item.unit ?? ''),
                        ),
                      if (expiredMedicines.length > 10)
                        Text('و ${expiredMedicines.length - 10} دواء آخر...'),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الأدوية المنتهية: $e');
    }
  }

  void _showNearExpiryMedicines() async {
    try {
      final nearExpiryMedicines = await MedicineApi.getNearExpiryMedicines();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('الأدوية قريبة الانتهاء'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: nearExpiryMedicines.isEmpty
                ? Text('لا توجد أدوية قريبة الانتهاء')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var item in nearExpiryMedicines.take(10))
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.warning, size: 16, color: Colors.white),
                          ),
                          title: Text(item.itemName ?? 'غير محدد'),
                          subtitle: Text('ينتهي: ${_formatDate(item.expiryDate!)}'),
                          trailing: Text(item.unit ?? ''),
                        ),
                      if (nearExpiryMedicines.length > 10)
                        Text('و ${nearExpiryMedicines.length - 10} دواء آخر...'),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الأدوية قريبة الانتهاء: $e');
    }
  }
}