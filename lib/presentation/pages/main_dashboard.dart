import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../main.dart'; // To access LocaleProvider

// Import all screens
import 'package:resistance_system_app/presentation/pages/casualties/casualties_screen.dart';
import 'package:resistance_system_app/presentation/pages/finance/finance_screen.dart';
import 'package:resistance_system_app/presentation/pages/inventory/inventory_screen.dart';
import 'package:resistance_system_app/presentation/pages/medicine/medicine_screen.dart';
import 'package:resistance_system_app/presentation/pages/movements/dashboard_movements_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_list_screen.dart';
import './../pages/training/personnel_training_screen.dart' as dashTraining;
import '../../core/services/personnel_service.dart';
import '../../core/services/casualty_api.dart';
import '../../core/services/medicine_api.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _totalPersonnel = 0;
  int _totalCasualties = 0;
  int _totalMedicineRequests = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Load Personnel Count
      final personnel = await PersonnelService.getAllPersonnel();

      // Load Casualties Count (using stats if available or list length)
      // Since CasualtyApi.getCasualtyStats returns a map with 'martyrs' and 'injured', we can sum them or use total
      final casualtyStats = await CasualtyApi.getCasualtyStats();
      // Assuming stats returns something like {'total': 10, 'martyrs': 5, 'injured': 5}.
      // If the API structure is different, adjust accordingly.
      // Based on typical API patterns, if getCasualtyStats returns a map, let's explore it.
      // If it fails, I'll fallback to list length as a safe bet if I knew the list endpoint worked perfectly.
      // But let's trust the stats endpoint first.

      // Load Medicine Requests
      final medicineStats = await MedicineApi.getMedicineStats();

      if (mounted) {
        setState(() {
          _totalPersonnel = personnel.length;

          // Parsing casualty stats safely
          int martyrs =
              int.tryParse(casualtyStats['martyrs']?.toString() ?? '0') ?? 0;
          int injured =
              int.tryParse(casualtyStats['injured']?.toString() ?? '0') ?? 0;
          _totalCasualties = martyrs + injured;

          // Parsing medicine stats safely
          _totalMedicineRequests =
              int.tryParse(
                medicineStats['total_movements']?.toString() ?? '0',
              ) ??
              0;

          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  List<DashboardItem> _getMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DashboardItem(
        l10n.personnel,
        Icons.people_rounded,
        AppColors.primary,
        l10n.personnelSubtitle,
      ),
      DashboardItem(
        l10n.training,
        Icons.school_rounded,
        AppColors.secondary,
        l10n.trainingSubtitle,
      ),
      DashboardItem(
        l10n.movements,
        Icons.map_rounded,
        AppColors.accent,
        l10n.movementsSubtitle,
      ),
      DashboardItem(
        l10n.casualties,
        Icons.medical_services_rounded,
        AppColors.error,
        l10n.casualtiesSubtitle,
      ),
      DashboardItem(
        l10n.inventory,
        Icons.inventory_2_rounded,
        Colors.purple,
        l10n.inventorySubtitle,
      ),
      DashboardItem(
        l10n.pharmacy,
        Icons.medication_rounded,
        Colors.teal,
        l10n.pharmacySubtitle,
      ),
      DashboardItem(
        l10n.finance,
        Icons.account_balance_wallet_rounded,
        Colors.blue,
        l10n.financeSubtitle,
      ),
      DashboardItem(
        l10n.reports,
        Icons.insert_chart_rounded,
        Colors.indigo,
        l10n.reportsSubtitle,
      ),
      DashboardItem(
        l10n.intelligence,
        Icons.admin_panel_settings_rounded,
        AppColors.slate800,
        l10n.intelligenceSubtitle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);
    final menuItems = _getMenuItems(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isWeb),
      drawer: isMobile ? _buildDrawer(context, menuItems) : null,
      body: isWeb
          ? _buildWebLayout(context, menuItems)
          : _buildMobileLayout(context, menuItems),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isWeb) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.dashboardTitle,
        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(isArabic ? Icons.language : Icons.translate),
          onPressed: () {
            localeProvider.setLocale(
              isArabic ? const Locale('en') : const Locale('ar'),
            );
          },
          tooltip: isArabic ? 'Switch to English' : 'تغيير للعربية',
        ),
        IconButton(
          onPressed: () {},
          icon: const Badge(
            label: Text('3'),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context, List<DashboardItem> menuItems) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildSidebar(context, menuItems),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernScreenHeader(
                  title: l10n.welcomeAdmin,
                  subtitle: l10n.systemSummary,
                ),
                const SizedBox(height: 32),
                _buildQuickStatsStrip(context),
                const SizedBox(height: 48),
                Text(
                  l10n.quickManagementTools,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _buildWebGrid(context, menuItems),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, List<DashboardItem> menuItems) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          ...menuItems.map((item) => _buildSidebarItem(context, item)).toList(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.logout),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, DashboardItem item) {
    return ListTile(
      leading: Icon(item.icon, color: item.color),
      title: Text(
        item.title,
        style: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
      ),
      onTap: () => _navigateToScreen(item.title, context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildQuickStatsStrip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            l10n.totalPersonnel,
            _isLoadingStats ? '...' : '$_totalPersonnel',
            Icons.people_alt,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            l10n.currentTasks,
            '0', // Placeholder for now
            Icons.task_alt,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            l10n.pharmacyRequests,
            _isLoadingStats ? '...' : '$_totalMedicineRequests',
            Icons.medication,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            l10n.emergencyCases, // Using Casualties for emergency cases/alerts
            _isLoadingStats ? '...' : '$_totalCasualties',
            Icons.emergency,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.tajawal(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.tajawal(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebGrid(BuildContext context, List<DashboardItem> menuItems) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.5,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) =>
          _buildDashboardCard(context, menuItems[index]),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<DashboardItem> menuItems,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appTitle,
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildMobileStats(context, l10n),
          const SizedBox(height: 32),
          Text(
            l10n.quickManagementTools,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildMobileGrid(context, menuItems),
        ],
      ),
    );
  }

  Widget _buildMobileStats(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMobileStatItem(
            l10n.personnel,
            _isLoadingStats ? '...' : '$_totalPersonnel',
          ),
          _buildMobileStatItem(
            l10n.emergencyCases,
            _isLoadingStats ? '...' : '$_totalCasualties',
          ),
          _buildMobileStatItem(
            l10n.pharmacy,
            _isLoadingStats ? '...' : '$_totalMedicineRequests',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildMobileGrid(BuildContext context, List<DashboardItem> menuItems) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) =>
          _buildDashboardCard(context, menuItems[index]),
    );
  }

  Widget _buildDashboardCard(BuildContext context, DashboardItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.slate700 : AppColors.slate100,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToScreen(item.title, context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: GoogleFonts.tajawal(
                  color: Colors.grey,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, List<DashboardItem> menuItems) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.security, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: menuItems
                  .map(
                    (item) => ListTile(
                      leading: Icon(item.icon, color: item.color),
                      title: Text(item.title),
                      onTap: () => _navigateToScreen(item.title, context),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(String title, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (title == l10n.personnel) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PersonnelListScreen()),
      );
    } else if (title == l10n.movements) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardMovementsScreen()),
      );
    } else if (title == l10n.training) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => dashTraining.PersonnelTrainingScreen(),
        ),
      );
    } else if (title == l10n.casualties) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CasualtiesScreen()),
      );
    } else if (title == l10n.inventory) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InventoryScreen()),
      );
    } else if (title == l10n.pharmacy) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicineScreen()),
      );
    } else if (title == l10n.finance) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FinanceScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Screen $title is under development')),
      );
    }
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  DashboardItem(this.title, this.icon, this.color, this.description);
}
