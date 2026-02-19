// lib/presentation/pages/finance/finance_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import '../../../core/models/financial_item.dart';
import '../../../core/services/financial_api.dart';
import 'finance_form_screen.dart';
import 'finance_detail_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({Key? key}) : super(key: key);

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

      if (mounted) {
        setState(() {
          _financialItems = [...incoming, ...outgoing];
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

  List<FinancialItem> get _filteredItems {
    var filtered = _financialItems;
    final l10n = AppLocalizations.of(context)!;

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
      filtered = filtered
          .where(
            (item) => item.type == 'incoming' || item.type == l10n.incoming,
          )
          .toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered
          .where(
            (item) => item.type == 'outgoing' || item.type == l10n.outgoing,
          )
          .toList();
    }

    return filtered;
  }

  Widget _buildFinancialCard(FinancialItem item) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.typeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(item.typeIcon, color: item.typeColor),
        ),
        title: Text(
          item.source,
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
              item.displayMethod,
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            Text(
              '${l10n.amount}: ${item.amount} ${l10n.currency}',
              style: TextStyle(
                color: item.type == 'incoming' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${l10n.date}: ${_formatDate(item.entryDate)}',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.typeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.description,
                style: TextStyle(
                  fontSize: 12,
                  color: item.typeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  Widget _buildFinancialGrid() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
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
                          item.source,
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
                    item.method,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.amount} ${l10n.currency}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: item.type == 'incoming'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.typeColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: item.typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildSummaryCards() {
    final l10n = AppLocalizations.of(context)!;

    double totalIncoming = 0;
    double totalOutgoing = 0;

    for (var item in _financialItems) {
      if (item.type == 'incoming') {
        totalIncoming += item.amount;
      } else {
        totalOutgoing += item.amount;
      }
    }

    final netBalance = totalIncoming - totalOutgoing;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: l10n.incoming,
              amount: totalIncoming,
              color: Colors.green,
              icon: Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              title: l10n.outgoing,
              amount: totalOutgoing,
              color: Colors.orange,
              icon: Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              title: l10n.netBalance,
              amount: netBalance,
              color: netBalance >= 0 ? Colors.blue : Colors.red,
              icon: Icons.account_balance_wallet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(0)} ${l10n.currency}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.slate900,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _viewItemDetails(FinancialItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceDetailScreen(item: item)),
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
        content: Text('${l10n.deleteMessage} (${item.source})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDelete(item);
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

  Future<void> _confirmDelete(FinancialItem item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (item.type == 'incoming') {
        await FinancialApi.deleteIncomingFund(item.id!);
      } else {
        await FinancialApi.deleteOutgoingFund(item.id!);
      }

      if (mounted) {
        setState(() {
          _financialItems.removeWhere((i) => i.id == item.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('${l10n.error}: $e');
    }
  }

  void _addNewItem(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceFormScreen(
          type: type,
          currentBalance: _calculateNetBalance(),
        ),
      ),
    ).then((_) => _loadFinancialData());
  }

  double _calculateNetBalance() {
    double incoming = 0;
    double outgoing = 0;
    for (var item in _financialItems) {
      if (item.type == 'incoming') {
        incoming += item.amount;
      } else {
        outgoing += item.amount;
      }
    }
    return incoming - outgoing;
  }

  void _showFinancialStats() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final stats = await FinancialApi.getFinancialStats();
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
                l10n.incoming,
                '${stats['incoming']['total_incoming_amount']} ${l10n.currency}',
                Icons.trending_up,
                Colors.green,
              ),
              _buildStatItem(
                l10n.outgoing,
                '${stats['outgoing']['total_outgoing_amount']} ${l10n.currency}',
                Icons.trending_down,
                Colors.orange,
              ),
              _buildStatItem(
                l10n.netBalance,
                '${stats['summary']['net_balance']} ${l10n.currency}',
                Icons.account_balance,
                stats['summary']['net_balance'] >= 0
                    ? Colors.green
                    : AppColors.error,
              ),
              _buildStatItem(
                l10n.budgetStatus,
                stats['summary']['balance_status'],
                Icons.bar_chart,
                stats['summary']['net_balance'] >= 0
                    ? Colors.green
                    : AppColors.error,
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
                fontSize: 14,
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
            label: Text('${l10n.all} (${_financialItems.length})'),
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
              '${l10n.incoming} (${_financialItems.where((item) => item.type == 'incoming').length})',
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
              '${l10n.outgoing} (${_financialItems.where((item) => item.type == 'outgoing').length})',
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
        title: Text(l10n.financeTitle),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            tooltip: l10n.add,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'incoming',
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.addIncoming),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'outgoing',
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_down,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.addOutgoing),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              _addNewItem(value);
            },
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
                value: 'top_incoming',
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.incoming),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'top_expenses',
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_down,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.outgoing),
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
          _buildSummaryCards(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchFinance,
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
                          Icons.account_balance_wallet,
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
                          Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _addNewItem('incoming'),
                                icon: const Icon(Icons.trending_up),
                                label: Text(l10n.addIncoming),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => _addNewItem('outgoing'),
                                icon: const Icon(Icons.trending_down),
                                label: Text(l10n.addOutgoing),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
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
                      ],
                    ),
                  )
                : _selectedView == 0
                ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final topIncoming = await FinancialApi.getTopIncoming();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.incoming),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: topIncoming.isEmpty
                ? Text(l10n.noDataFound)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: topIncoming.length > 5 ? 5 : topIncoming.length,
                    itemBuilder: (context, index) {
                      final item = topIncoming[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.trending_up,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(item.source),
                        subtitle: Text('${item.amount} ${l10n.currency}'),
                        trailing: Text(_formatDate(item.entryDate)),
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

  void _showTopExpenses() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final topExpenses = await FinancialApi.getTopExpenses();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.trending_down, color: Colors.orange),
              const SizedBox(width: 8),
              Text(l10n.outgoing),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: topExpenses.isEmpty
                ? Text(l10n.noDataFound)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: topExpenses.length > 5 ? 5 : topExpenses.length,
                    itemBuilder: (context, index) {
                      final item = topExpenses[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(
                            Icons.trending_down,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(item.source),
                        subtitle: Text('${item.amount} ${l10n.currency}'),
                        trailing: Text(_formatDate(item.entryDate)),
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
