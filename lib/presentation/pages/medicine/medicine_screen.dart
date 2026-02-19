// lib/presentation/pages/medicine/medicine_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import '../../../core/models/medicine_item.dart';
import '../../../core/services/medicine_api.dart';
import 'medicine_form_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({Key? key}) : super(key: key);

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
      if (mounted) {
        setState(() {
          _medicineItems = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          '${AppLocalizations.of(context)!.errorOccurred}: $e',
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<MedicineItem> get _filteredItems {
    var filtered = _medicineItems;
    final l10n = AppLocalizations.of(context)!;

    // تطبيق البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return (item.itemName?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false) ||
            (item.medicineType?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false) ||
            (item.movementType.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ));
      }).toList();
    }

    // تطبيق الفلتر
    if (_selectedFilter == 1) {
      filtered = filtered
          .where(
            (item) =>
                item.movementType == 'وارد' ||
                item.movementType == l10n.incoming,
          )
          .toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered
          .where(
            (item) =>
                item.movementType == 'منصرف' ||
                item.movementType == l10n.outgoing,
          )
          .toList();
    }

    return filtered;
  }

  Widget _buildMedicineCard(MedicineItem item) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.typeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(item.typeIcon, color: item.typeColor),
        ),
        title: Text(
          item.itemName ?? l10n.noDataFound,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.slate900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${l10n.medicineType}: ${item.medicineType ?? l10n.noDataFound}',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            Text(
              '${l10n.quantity}: ${item.quantity} ${item.unit ?? ""}',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            Text(
              '${l10n.date}: ${_formatDate(item.movementDate)}',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.movementType == 'وارد'
                        ? l10n.incoming
                        : (item.movementType == 'منصرف'
                              ? l10n.outgoing
                              : item.movementType),
                    style: TextStyle(
                      fontSize: 12,
                      color: item.typeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.expired,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? AppColors.slate400 : AppColors.slate600,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.viewDetails),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDark ? AppColors.darkSurface : Colors.white,
          child: InkWell(
            onTap: () => _viewItemDetails(item),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: item.typeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.typeIcon,
                          size: 18,
                          color: item.typeColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.itemName ?? l10n.noDataFound,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.slate900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.medicineType}:',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.slate500 : AppColors.slate500,
                    ),
                  ),
                  Text(
                    item.medicineType ?? l10n.noDataFound,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.quantity} ${item.unit ?? ""}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.typeColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          item.movementType == 'وارد'
                              ? l10n.incoming
                              : (item.movementType == 'منصرف'
                                    ? l10n.outgoing
                                    : item.movementType),
                          style: TextStyle(
                            fontSize: 10,
                            color: item.typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (item.isExpired)
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                    ],
                  ),
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
      MaterialPageRoute(builder: (context) => MedicineDetailScreen(item: item)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.confirmDelete),
          ],
        ),
        content: Text('${l10n.deleteMessage} (${item.itemName ?? ""})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(item.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await MedicineApi.deleteMedicineItem(id);
      if (mounted) {
        setState(() {
          _medicineItems.removeWhere((item) => item.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('${l10n.error}: $e');
    }
  }

  void _addNewItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicineFormScreen()),
    ).then((_) => _loadMedicineData());
  }

  void _showMedicineStats() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // final stats = await MedicineApi.getMedicineStats(); // Use if needed
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(l10n.stats),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem(
                l10n.all,
                _medicineItems.length.toString(),
                Icons.medication,
                AppColors.primary,
              ),
              _buildStatItem(
                l10n.incoming,
                _medicineItems
                    .where((item) => item.movementType == 'وارد')
                    .length
                    .toString(),
                Icons.input,
                Colors.green,
              ),
              _buildStatItem(
                l10n.outgoing,
                _medicineItems
                    .where((item) => item.movementType == 'منصرف')
                    .length
                    .toString(),
                Icons.output,
                Colors.orange,
              ),
              _buildStatItem(
                l10n.expired,
                _medicineItems
                    .where((item) => item.isExpired)
                    .length
                    .toString(),
                Icons.error,
                AppColors.error,
              ),
            ],
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
      if (mounted) _showErrorSnackBar('${l10n.error}: $e');
    }
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text('${l10n.all} (${_medicineItems.length})'),
            selected: _selectedFilter == 0,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 0 : _selectedFilter;
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              '${l10n.incoming} (${_medicineItems.where((item) => item.movementType == 'وارد' || item.movementType == l10n.incoming).length})',
            ),
            selected: _selectedFilter == 1,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 1 : 0;
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              '${l10n.outgoing} (${_medicineItems.where((item) => item.movementType == 'منصرف' || item.movementType == l10n.outgoing).length})',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            color: _selectedView == 0 ? AppColors.primary : Colors.grey,
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
            color: _selectedView == 1 ? AppColors.primary : Colors.grey,
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.pharmacyTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewItem,
            tooltip: l10n.add,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.stats),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'expired',
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.expired),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'near_expiry',
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.nearExpiry),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.refresh),
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
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchMedicine,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.slate100,
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
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري التحميل...'),
                      ],
                    ),
                  )
                : _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication,
                          size: 64,
                          color: isDark
                              ? AppColors.slate700
                              : AppColors.slate300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedFilter == 0
                              ? l10n.noDataFound
                              : l10n.noDataFound,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark
                                ? AppColors.slate500
                                : AppColors.slate500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_searchQuery.isEmpty && _selectedFilter == 0)
                          ElevatedButton.icon(
                            onPressed: _addNewItem,
                            icon: const Icon(Icons.add),
                            label: Text(l10n.add),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : _selectedView == 0
                ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
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
        child: const Icon(Icons.add),
        tooltip: l10n.add,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showExpiredMedicines() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final expiredMedicines = await MedicineApi.getExpiringMedicines();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: AppColors.error),
              const SizedBox(width: 8),
              Text(l10n.expired),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: expiredMedicines.isEmpty
                ? Text(l10n.noDataFound)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: expiredMedicines.length > 5
                        ? 5
                        : expiredMedicines.length,
                    itemBuilder: (context, index) {
                      final item = expiredMedicines[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                        ),
                        title: Text(item.itemName ?? ""),
                        subtitle: Text(
                          '${l10n.expiryDate}: ${_formatDate(item.expiryDate!)}',
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
      if (mounted) _showErrorSnackBar('${l10n.error}: $e');
    }
  }

  void _showNearExpiryMedicines() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final nearExpiryMedicines = await MedicineApi.getNearExpiryMedicines();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Text(l10n.nearExpiry),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: nearExpiryMedicines.isEmpty
                ? Text(l10n.noDataFound)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: nearExpiryMedicines.length > 5
                        ? 5
                        : nearExpiryMedicines.length,
                    itemBuilder: (context, index) {
                      final item = nearExpiryMedicines[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        ),
                        title: Text(item.itemName ?? ""),
                        subtitle: Text(
                          '${l10n.expiryDate}: ${_formatDate(item.expiryDate!)}',
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
      if (mounted) _showErrorSnackBar('${l10n.error}: $e');
    }
  }
}
