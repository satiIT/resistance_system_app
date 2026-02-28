import 'package:flutter/material.dart';
import '../../../core/models/inventory_item.dart';
import '../../../core/services/inventory_api.dart';
import 'inventory_form_screen.dart';
import 'inventory_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: الكل, 1: وارد فقط, 2: منصرف فقط
  int _selectedView = 0; // 0: القائمة, 1: البطاقات

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    try {
      final response = await InventoryApi.getInventoryItems();
      setState(() {
        _inventoryItems = response;
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

  List<InventoryItem> get _filteredItems {
    var filtered = _inventoryItems;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return (item.itemName?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false) ||
            (item.entity.toLowerCase().contains(_searchQuery.toLowerCase())) ||
            (item.movementType.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ));
      }).toList();
    }

    // تطبيق الفلتر
    if (_selectedFilter == 1) {
      filtered = filtered.where((item) => item.movementType == 'وارد').toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered
          .where((item) => item.movementType == 'منصرف')
          .toList();
    }

    return filtered;
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.typeColor,
          child: Icon(item.typeIcon, color: Colors.white),
        ),
        title: Text(
          (item.itemName != null && item.itemName!.isNotEmpty)
              ? item.itemName!
              : 'غير معروف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الجهة: ${item.entity}'),
            Text('الكمية: ${item.quantity} ${item.packaging ?? ""}'),
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

  Widget _buildInventoryGrid() {
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
                        child: Icon(
                          item.typeIcon,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (item.itemName != null && item.itemName!.isNotEmpty)
                              ? item.itemName!
                              : 'غير معروف',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.entity,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.quantity} ${item.packaging ?? ""}',
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

  void _viewItemDetails(InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryDetailScreen(item: item),
      ),
    );
  }

  void _editItem(InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryFormScreen(existingItem: item),
      ),
    ).then((_) => _loadInventoryData());
  }

  void _deleteItem(InventoryItem item) {
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
        content: Text('هل تريد حذف سجل ${item.itemName ?? "هذا السجل"}؟'),
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
      await InventoryApi.deleteInventoryItem(id);
      _loadInventoryData(); // إعادة تحميل البيانات لتحديث الأرصدة والملخصات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم الحذف وتصحيح الأرصدة بنجاح'),
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
      MaterialPageRoute(builder: (context) => InventoryFormScreen()),
    ).then((_) => _loadInventoryData());
  }

  void _showInventoryStats() async {
    try {
      await InventoryApi.getInventoryStats();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue),
              SizedBox(width: 8),
              Text('إحصائيات المخزون'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem(
                'إجمالي الحركات',
                _inventoryItems.length.toString(),
                Icons.inventory,
              ),
              _buildStatItem(
                'حركات وارد',
                _inventoryItems
                    .where((item) => item.movementType == 'وارد')
                    .length
                    .toString(),
                Icons.input,
              ),
              _buildStatItem(
                'حركات منصرف',
                _inventoryItems
                    .where((item) => item.movementType == 'منصرف')
                    .length
                    .toString(),
                Icons.output,
              ),
              _buildStatItem(
                'منتهي الصلاحية',
                _inventoryItems
                    .where((item) => item.isExpired)
                    .length
                    .toString(),
                Icons.error,
              ),
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
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            label: Text('الكل (${_inventoryItems.length})'),
            selected: _selectedFilter == 0,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 0 : _selectedFilter;
              });
            },
          ),
          FilterChip(
            label: Text(
              'وارد فقط (${_inventoryItems.where((item) => item.movementType == 'وارد').length})',
            ),
            selected: _selectedFilter == 1,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 1 : 0;
              });
            },
          ),
          FilterChip(
            label: Text(
              'منصرف فقط (${_inventoryItems.where((item) => item.movementType == 'منصرف').length})',
            ),
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
            icon: Icon(
              _selectedView == 0 ? Icons.view_list : Icons.view_list_outlined,
            ),
            onPressed: () {
              setState(() {
                _selectedView = 0;
              });
            },
            color: _selectedView == 0 ? Colors.blue : Colors.grey,
          ),
          IconButton(
            icon: Icon(
              _selectedView == 1 ? Icons.grid_view : Icons.grid_view_outlined,
            ),
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

  Widget _buildSummaryCards() {
    double totalIncoming = 0;
    double totalOutgoing = 0;

    for (var item in _inventoryItems) {
      if (item.movementType == 'وارد') {
        totalIncoming += item.quantity;
      } else if (item.movementType == 'منصرف') {
        totalOutgoing += item.quantity;
      }
    }

    final netBalance = totalIncoming - totalOutgoing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'إجمالي الوارد',
              totalIncoming,
              Colors.green,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'إجمالي المنصرف',
              totalOutgoing,
              Colors.red,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'الرصيد الحالي',
              netBalance,
              Colors.blue,
              Icons.inventory_2,
              onTap: _showDetailedStockDialog,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedStockDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final stockData = await InventoryApi.getDetailedStock();
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.inventory, color: Colors.blue),
              SizedBox(width: 8),
              Text('تقرير المخزون التفصيلي'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: stockData.isEmpty
                ? const Center(child: Text('لا يوجد مخزون حالي'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: stockData.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = stockData[index];
                      return ListTile(
                        title: Text(
                          '${item['item_name']} (${item['item_code']})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('المكان: ${item['store_name']}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${item['quantity']} ${item['unit_of_measure'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في جلب التقرير: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.open_in_new,
                    size: 10,
                    color: color.withOpacity(0.5),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استمارة مخازن وارد أو منصرف - استمارة رقم (6)'),
        backgroundColor: Colors.teal,
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
                value: 'expiring',
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('المنتهي الصلاحية'),
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
                  _showInventoryStats();
                  break;
                case 'expiring':
                  _showExpiringItems();
                  break;
                case 'refresh':
                  _loadInventoryData();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'بحث في المخزون',
                hintText: 'ابحث بالصنف، الجهة، أو نوع الحركة...',
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
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedFilter == 0
                              ? 'لا توجد سجلات في المخزون'
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
                      return _buildInventoryCard(_filteredItems[index]);
                    },
                  )
                : _buildInventoryGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        child: Icon(Icons.add),
        tooltip: 'إضافة سجل جديد',
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showExpiringItems() async {
    try {
      final expiringItems = await InventoryApi.getExpiringItems();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('العناصر المنتهية الصلاحية'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: expiringItems.isEmpty
                ? Text('لا توجد عناصر منتهية الصلاحية')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var item in expiringItems.take(10))
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.error,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(item.itemName ?? 'غير محدد'),
                          subtitle: Text(
                            'ينتهي: ${_formatDate(item.expiryDate!)}',
                          ),
                          trailing: Text(item.packaging ?? ''),
                        ),
                      if (expiringItems.length > 10)
                        Text('و ${expiringItems.length - 10} عناصر أخرى...'),
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
      _showErrorSnackBar('خطأ في تحميل العناصر المنتهية: $e');
    }
  }
}
