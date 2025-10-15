import 'package:flutter/material.dart';
import '../../../core/models/casualty.dart';
import '../../../core/services/casualty_api.dart';
import 'casualty_form_screen.dart';
import 'casualty_detail_screen.dart';

class CasualtiesScreen extends StatefulWidget {
  @override
  _CasualtiesScreenState createState() => _CasualtiesScreenState();
}

class _CasualtiesScreenState extends State<CasualtiesScreen> {
  List<Casualty> _casualties = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: الكل, 1: شهداء فقط, 2: جرحى فقط

  @override
  void initState() {
    super.initState();
    _loadCasualties();
  }

  Future<void> _loadCasualties() async {
    try {
      final response = await CasualtyApi.getCasualties();
      setState(() {
        _casualties = response;
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

  List<Casualty> get _filteredCasualties {
    var filtered = _casualties;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((casualty) {
        return casualty.militaryNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               casualty.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               casualty.incidentLocation.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // تطبيق الفلتر
    if (_selectedFilter == 1) {
      filtered = filtered.where((casualty) => casualty.isMartyr).toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((casualty) => casualty.isInjured).toList();
    }

    return filtered;
  }

  Widget _buildCasualtyCard(Casualty casualty) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: casualty.typeColor,
          child: Icon(
            casualty.isMartyr ? Icons.flag : Icons.medical_services,
            color: Colors.white,
          ),
        ),
        title: Text(
          casualty.fullName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرقم العسكري: ${casualty.militaryNumber}'),
            Text('النوع: ${casualty.formType}'),
            Text('التاريخ: ${casualty.incidentDateFormatted}'),
            Text('المكان: ${casualty.incidentLocation}'),
            if (casualty.isInjured)
              Chip(
                label: Text(
                  casualty.injurySeverity,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: casualty.severityColor,
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
                _viewCasualtyDetails(casualty);
                break;
              case 'edit':
                _editCasualty(casualty);
                break;
              case 'delete':
                _deleteCasualty(casualty);
                break;
            }
          },
        ),
        onTap: () => _viewCasualtyDetails(casualty),
      ),
    );
  }

  void _viewCasualtyDetails(Casualty casualty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CasualtyDetailScreen(casualty: casualty),
      ),
    );
  }

  void _editCasualty(Casualty casualty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CasualtyFormScreen(existingCasualty: casualty),
      ),
    ).then((_) => _loadCasualties());
  }

  void _deleteCasualty(Casualty casualty) {
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
        content: Text('هل تريد حذف سجل ${casualty.formType} ${casualty.fullName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(casualty.id!);
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
      await CasualtyApi.deleteCasualty(id);
      setState(() {
        _casualties.removeWhere((casualty) => casualty.id == id);
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

  void _addNewCasualty() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CasualtyFormScreen()),
    ).then((_) => _loadCasualties());
  }

  void _showCasualtyStats() async {
    try {
      final stats = await CasualtyApi.getCasualtyStats();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue),
              SizedBox(width: 8),
              Text('إحصائيات الشهداء والجرحى'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('إجمالي السجلات', stats['total']?.toString() ?? '0', Icons.list),
              _buildStatItem('عدد الشهداء', stats['martyrs']?.toString() ?? '0', Icons.flag),
              _buildStatItem('عدد الجرحى', stats['injured']?.toString() ?? '0', Icons.medical_services),
              _buildStatItem('إصابات خطيرة', stats['critical']?.toString() ?? '0', Icons.warning),
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
            label: Text('الكل (${_casualties.length})'),
            selected: _selectedFilter == 0,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 0 : _selectedFilter;
              });
            },
          ),
          FilterChip(
            label: Text('شهداء فقط'),
            selected: _selectedFilter == 1,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 1 : 0;
              });
            },
          ),
          FilterChip(
            label: Text('جرحى فقط'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استمارة الجرحى والشهداء - استمارة رقم (4)'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewCasualty,
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
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('تحديث البيانات'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'stats':
                  _showCasualtyStats();
                  break;
                case 'refresh':
                  _loadCasualties();
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
                labelText: 'بحث في السجلات',
                hintText: 'ابحث بالاسم، الرقم العسكري، أو المكان...',
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
                : _filteredCasualties.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty && _selectedFilter == 0
                                  ? 'لا توجد سجلات'
                                  : 'لا توجد نتائج للبحث',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            if (_searchQuery.isEmpty && _selectedFilter == 0)
                              ElevatedButton.icon(
                                onPressed: _addNewCasualty,
                                icon: Icon(Icons.add),
                                label: Text('إضافة سجل جديد'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCasualties.length,
                        itemBuilder: (context, index) {
                          return _buildCasualtyCard(_filteredCasualties[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCasualty,
        child: Icon(Icons.add),
        tooltip: 'إضافة سجل جديد',
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}