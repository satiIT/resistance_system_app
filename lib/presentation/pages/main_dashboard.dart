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
import '../../core/services/auth_service.dart';
import 'users_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'org/departments_screen.dart';
import 'org/reports_screen.dart';

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
  Map<String, dynamic>? _currentUser;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadCurrentUser();
    await _loadStats();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
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
        roles: ['admin', 'data_entry'],
      ),
      DashboardItem(
        l10n.training,
        Icons.school_rounded,
        AppColors.secondary,
        l10n.trainingSubtitle,
        roles: ['admin', 'data_entry', 'training'],
      ),
      DashboardItem(
        l10n.movements,
        Icons.map_rounded,
        AppColors.accent,
        l10n.movementsSubtitle,
        roles: ['admin', 'data_entry', 'operations'],
      ),
      DashboardItem(
        l10n.casualties,
        Icons.medical_services_rounded,
        AppColors.error,
        l10n.casualtiesSubtitle,
        roles: ['admin', 'medical'],
      ),
      DashboardItem(
        l10n.inventory,
        Icons.inventory_2_rounded,
        Colors.purple,
        l10n.inventorySubtitle,
        roles: ['admin', 'inventory'],
      ),
      DashboardItem(
        l10n.pharmacy,
        Icons.medication_rounded,
        Colors.teal,
        l10n.pharmacySubtitle,
        roles: ['admin', 'medical'],
      ),
      DashboardItem(
        l10n.finance,
        Icons.account_balance_wallet_rounded,
        Colors.blue,
        l10n.financeSubtitle,
        roles: ['admin', 'finance'],
      ),
      DashboardItem(
        l10n.reports,
        Icons.insert_chart_rounded,
        Colors.indigo,
        l10n.reportsSubtitle,
        roles: ['admin', 'finance'],
      ),
      DashboardItem(
        l10n.intelligence,
        Icons.admin_panel_settings_rounded,
        AppColors.slate800,
        l10n.intelligenceSubtitle,
        roles: ['admin'],
      ),
      DashboardItem(
        'المستخدمين',
        Icons.group_add_rounded,
        Colors.cyan,
        'إدارة مستخدمي النظام وصلاحياتهم',
        roles: ['admin'],
      ),
      DashboardItem(
        'أقسام الوحدة',
        Icons.account_tree_rounded,
        Colors.brown,
        'إدارة الأقسام (هندسة، برمجة، مسيرات) والمجموعات',
        roles: ['admin'],
      ),
      DashboardItem(
        'تقارير النظام',
        Icons.assignment_rounded,
        Colors.blueGrey,
        'استعراض تقارير الأفراد والمجموعات والأقسام',
        roles: ['admin', 'dept_governor', 'group_governor'],
      ),
      DashboardItem(
        'تغيير كلمة المرور',
        Icons.lock_reset_rounded,
        Colors.orange,
        'تحديث كلمة المرور الخاصة بك',
        roles: [
          'admin',
          'data_entry',
          'finance',
          'medical',
          'inventory',
          'training',
          'operations',
          'dept_governor',
          'group_governor',
        ],
      ),
    ];
  }

  List<DashboardItem> _getFilteredMenuItems(BuildContext context) {
    final allItems = _getMenuItems(context);
    if (_currentUser == null) return [];

    final role = _currentUser!['role'];

    // Define role-to-title mappings or use the DashboardItem.roles list
    return allItems.where((item) {
      if (item.roles == null) return true; // public
      return item.roles!.contains(role);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);
    final menuItems = _getFilteredMenuItems(context);

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
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, size: 20, color: AppColors.primary),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                _currentUser?['email'] ?? '',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              onTap: () {
                _authService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('تسجيل الخروج'),
              ),
            ),
          ],
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
      height: MediaQuery.of(context).size.height,
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
          const Center(child: TechUnitLogo(size: 100)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l10n.appTitle,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuItems
                  .map((item) => _buildSidebarItem(context, item))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _authService.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.logout,
                        style: GoogleFonts.tajawal(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
              style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 12),
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
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 32,
              bottom: 40,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeAdmin,
                  style: GoogleFonts.tajawal(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l10n.systemSummary,
                  style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _buildMobileStats(context, l10n),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quickManagementTools,
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildMobileGrid(context, menuItems),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStats(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleMobileStat(
            l10n.personnel,
            _isLoadingStats ? '...' : '$_totalPersonnel',
            Icons.people_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSimpleMobileStat(
            l10n.emergencyCases,
            _isLoadingStats ? '...' : '$_totalCasualties',
            Icons.emergency_rounded,
            AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSimpleMobileStat(
            l10n.pharmacy,
            _isLoadingStats ? '...' : '$_totalMedicineRequests',
            Icons.medication_rounded,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleMobileStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.tajawal(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
        childAspectRatio: 0.95, // Adjusted for better text fitting
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) =>
          _buildDashboardCard(context, menuItems[index]),
    );
  }

  Widget _buildDashboardCard(BuildContext context, DashboardItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToScreen(item.title, context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: isMobile ? 28 : 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 15 : 18,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: GoogleFonts.tajawal(
                    color: Colors.grey,
                    fontSize: isMobile ? 10 : 12,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
                  const TechUnitLogo(size: 80),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
    } else if (title == 'المستخدمين') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UsersScreen()),
      );
    } else if (title == 'تغيير كلمة المرور') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
      );
    } else if (title == 'أقسام الوحدة') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DepartmentsScreen()),
      ).then((_) => _loadStats());
    } else if (title == 'تقارير النظام') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrgReportsScreen(
            userId: _currentUser?['id'] ?? 0,
            role: _currentUser?['role'] ?? 'admin',
            personnelId: _currentUser?['personnel_id'],
          ),
        ),
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
  final List<String>? roles;

  DashboardItem(
    this.title,
    this.icon,
    this.color,
    this.description, {
    this.roles,
  });
}
