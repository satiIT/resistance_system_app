// screens/finance/finance_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/financial_item.dart';
import '../../../core/services/financial_api.dart';
import 'finance_form_screen.dart';
import 'finance_detail_screen.dart';

class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<FinancialItem> _financialItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: الكل, 1: وارد فقط, 2: منصرف فقط
  int _selectedView = 0; // 0: القائمة, 1: البطاقات

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    try {
      final incoming = await FinancialApi.getIncomingFunds();
      final outgoing = await FinancialApi.getOutgoingFunds();
      
      setState(() {
        _financialItems = [...incoming, ...outgoing];
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

  List<FinancialItem> get _filteredItems {
    var filtered = _financialItems;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.source.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.method.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // تطبيق الفلتر
    if (_selectedFilter == 1) {
      filtered = filtered.where((item) => item.type == 'incoming').toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((item) => item.type == 'outgoing').toList();
    }

    return filtered;
  }

  Widget _buildFinancialCard(FinancialItem item) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.typeColor,
          child: Icon(item.typeIcon, color: Colors.white),
        ),
        title: Text(
          item.source,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.displayMethod),
            Text('المبلغ: ${item.amount} جنيه'),
            Text('التاريخ: ${_formatDate(item.entryDate)}'),
            Chip(
              label: Text(
                item.description,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: item.typeColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _buildFinancialGrid() {
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
                          item.source,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.method,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.amount} جنيه',
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
                      item.description,
                      style: TextStyle(fontSize: 10, color: item.typeColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _viewItemDetails(FinancialItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceDetailScreen(item: item),
      ),
    );
  }

  void _editItem(FinancialItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceFormScreen(existingItem: item),
      ),
    ).then((_) => _loadFinancialData());
  }

  void _deleteItem(FinancialItem item) {
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
        content: Text('هل تريد حذف سجل ${item.source}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(FinancialItem item) async {
    try {
      if (item.type == 'incoming') {
        await FinancialApi.deleteIncomingFund(item.id!);
      } else {
        await FinancialApi.deleteOutgoingFund(item.id!);
      }
      
      setState(() {
        _financialItems.removeWhere((i) => i.id == item.id);
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

  void _addNewItem(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceFormScreen(type: type),
      ),
    ).then((_) => _loadFinancialData());
  }

  void _showFinancialStats() async {
    try {
      final stats = await FinancialApi.getFinancialStats();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue),
              SizedBox(width: 8),
              Text('الإحصائيات المالية'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('إجمالي الوارد', '${stats['incoming']['total_incoming_amount']} جنيه', Icons.trending_up, Colors.green),
              _buildStatItem('إجمالي المنصرف', '${stats['outgoing']['total_outgoing_amount']} جنيه', Icons.trending_down, Colors.orange),
              _buildStatItem('صافي الرصيد', '${stats['summary']['net_balance']} جنيه', Icons.account_balance, 
                  stats['summary']['net_balance'] >= 0 ? Colors.green : Colors.red),
              _buildStatItem('حالة الميزانية', stats['summary']['balance_status'], Icons.bar_chart, 
                  stats['summary']['net_balance'] >= 0 ? Colors.green : Colors.red),
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
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
            label: Text('الكل (${_financialItems.length})'),
            selected: _selectedFilter == 0,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 0 : _selectedFilter;
              });
            },
          ),
          FilterChip(
            label: Text('وارد فقط (${_financialItems.where((item) => item.type == 'incoming').length})'),
            selected: _selectedFilter == 1,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 1 : 0;
              });
            },
          ),
          FilterChip(
            label: Text('منصرف فقط (${_financialItems.where((item) => item.type == 'outgoing').length})'),
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
        title: Text('استمارة الإدارة المالية - استمارة رقم (9)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.add),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'incoming',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green),
                    SizedBox(width: 8),
                    Text('إضافة وارد'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'outgoing',
                child: Row(
                  children: [
                    Icon(Icons.trending_down, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('إضافة منصرف'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              _addNewItem(value);
            },
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
                value: 'top_incoming',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green),
                    SizedBox(width: 8),
                    Text('أكبر الواردات'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'top_expenses',
                child: Row(
                  children: [
                    Icon(Icons.trending_down, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('أعلى المصروفات'),
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
                  _showFinancialStats();
                  break;
                case 'top_incoming':
                  _showTopIncoming();
                  break;
                case 'top_expenses':
                  _showTopExpenses();
                  break;
                case 'refresh':
                  _loadFinancialData();
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
                labelText: 'بحث في السجلات المالية',
                hintText: 'ابحث بالجهة، بند الصرف، المستلم...',
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
                            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty && _selectedFilter == 0
                                  ? 'لا توجد سجلات مالية'
                                  : 'لا توجد نتائج للبحث',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            if (_searchQuery.isEmpty && _selectedFilter == 0)
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _addNewItem('incoming'),
                                    icon: Icon(Icons.trending_up),
                                    label: Text('إضافة وارد جديد'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _addNewItem('outgoing'),
                                    icon: Icon(Icons.trending_down),
                                    label: Text('إضافة منصرف جديد'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      )
                    : _selectedView == 0
                        ? ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              return _buildFinancialCard(_filteredItems[index]);
                            },
                          )
                        : _buildFinancialGrid(),
          ),
        ],
      ),
    );
  }

  void _showTopIncoming() async {
    try {
      final topIncoming = await FinancialApi.getTopIncoming();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green),
              SizedBox(width: 8),
              Text('أكبر الواردات'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: topIncoming.isEmpty
                ? Text('لا توجد سجلات وارد')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var item in topIncoming.take(10))
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.trending_up, size: 16, color: Colors.white),
                          ),
                          title: Text(item.source),
                          subtitle: Text('${item.amount} جنيه'),
                          trailing: Text(_formatDate(item.entryDate)),
                        ),
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
      _showErrorSnackBar('خطأ في تحميل أكبر الواردات: $e');
    }
  }

  void _showTopExpenses() async {
    try {
      final topExpenses = await FinancialApi.getTopExpenses();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.trending_down, color: Colors.orange),
              SizedBox(width: 8),
              Text('أعلى المصروفات'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: topExpenses.isEmpty
                ? Text('لا توجد سجلات منصرف')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var item in topExpenses.take(10))
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.trending_down, size: 16, color: Colors.white),
                          ),
                          title: Text(item.source),
                          subtitle: Text('${item.amount} جنيه'),
                          trailing: Text(_formatDate(item.entryDate)),
                        ),
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
      _showErrorSnackBar('خطأ في تحميل أعلى المصروفات: $e');
    }
  }
}