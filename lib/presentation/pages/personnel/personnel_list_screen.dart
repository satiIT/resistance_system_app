// lib/presentation/pages/personnel/personnel_list_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_detail_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_form_screen.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../widgets/modern_widgets.dart';
import '../../../core/services/personnel_service.dart';
import '../../../core/utils/data_parser.dart'; // Import DataParser
// import '../../../core/services/debug_personnel_service.dart';

class PersonnelListScreen extends StatefulWidget {
  const PersonnelListScreen({Key? key}) : super(key: key);

  @override
  _PersonnelListScreenState createState() => _PersonnelListScreenState();
}

class _PersonnelListScreenState extends State<PersonnelListScreen> {
  List<dynamic> _personnelList = [];
  List<dynamic> _filteredPersonnelList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  // Geographical Data from API
  List<dynamic> _states = [];
  List<dynamic> _localities = [];

  // Filter Values
  String? _selectedState;
  String? _selectedLocality;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadGeographicalData();
    await _loadPersonnel();
  }

  // Load Geographical Data
  Future<void> _loadGeographicalData() async {
    try {
      debugPrint('🗺️ Fetching geographical data...');
      final statesData = await PersonnelService.getStates();
      final localitiesData = await PersonnelService.getLocalities();

      setState(() {
        _states = statesData;
        _localities = localitiesData;
      });
    } catch (e) {
      debugPrint('! Failed to fetch geographical data: $e');
    }
  }

  // Load Personnel Data
  Future<void> _loadPersonnel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      debugPrint('📡 Fetching data from API...');
      final data = await PersonnelService.getAllPersonnel();
      debugPrint('✅ Data received: ${data.length} items');

      setState(() {
        _personnelList = data;
        _filteredPersonnelList = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to fetch data: $e');
      setState(() {
        _errorMessage =
            'فشل في تحميل البيانات. يرجى التأكد من اتصال السيرفر.\n$e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _filteredPersonnelList = _personnelList.where((p) {
        final state = p['state']?.toString();
        final locality = p['locality']?.toString();
        final status = _getField(p, 'status'); // Used helper for consistency
        final query = _searchController.text.toLowerCase();

        // Search by Name or Military ID
        final firstName = _getField(p, 'first_name');
        final secondName = _getField(p, 'second_name');
        final thirdName = _getField(p, 'third_name');
        final fourthName = _getField(p, 'fourth_name');

        final fullName = '$firstName $secondName $thirdName $fourthName'
            .toLowerCase();
        final militaryId = _getField(p, 'military_id').toLowerCase();

        final matchesSearch =
            fullName.contains(query) || militaryId.contains(query);

        final matchesState =
            _selectedState == null ||
            _selectedState == l10n.allStates ||
            state == _selectedState;
        final matchesLocality =
            _selectedLocality == null ||
            _selectedLocality == l10n.allLocalities ||
            locality == _selectedLocality;

        bool matchesStatus =
            _selectedStatus == null || _selectedStatus == l10n.allStatus;

        if (!matchesStatus) {
          // Normalize status check
          final activeStrings = ['نشط', 'Active', 'active'];
          final inactiveStrings = ['غير نشط', 'Inactive', 'inactive'];
          final martyrStrings = ['شهيد', 'Martyr', 'martyr'];
          final woundedStrings = ['جريح', 'Wounded', 'wounded'];

          if (_selectedStatus == l10n.active)
            matchesStatus = activeStrings.contains(status);
          else if (_selectedStatus == l10n.inactive)
            matchesStatus = inactiveStrings.contains(status);
          else if (_selectedStatus == l10n.martyr)
            matchesStatus = martyrStrings.contains(status);
          else if (_selectedStatus == l10n.wounded)
            matchesStatus = woundedStrings.contains(status);
        }

        return matchesSearch &&
            matchesState &&
            matchesLocality &&
            matchesStatus;
      }).toList();
    });
  }

  // Updated _getField using DataParser
  String _getField(dynamic personnel, String fieldName) {
    if (personnel is Map) {
      // Use DataParser to handle snake_case / camelCase variations automatically
      return DataParser.smartGetString(
        personnel,
        fieldName,
        defaultValue: 'غير محدد',
      );
    }
    return 'غير محدد';
  }

  // Build Web Layout
  Widget _buildWebLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSidebar(context, l10n),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernScreenHeader(
                  title: l10n.personnelManagement,
                  subtitle: l10n.personnelSubtitle,
                ),
                const SizedBox(height: 32),
                _buildSearchBar(context),
                const SizedBox(height: 32),
                _buildPersonnelGrid(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModernScreenHeader(
                title: l10n.personnelManagement,
                subtitle: l10n.personnelSubtitle,
              ),
              const SizedBox(height: 20),
              _buildSearchBar(context),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, textAlign: TextAlign.center))
              : _buildPersonnelList(context),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ModernSearchField(
      controller: _searchController,
      hint: l10n.searchHint,
      onChanged: (_) => _applyFilters(),
    );
  }

  Widget _buildFilterSidebar(BuildContext context, dynamic l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.slate800 : Colors.grey[200]!,
          ),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.state,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilterDropdown(
            l10n.state,
            _selectedState ?? l10n.allStates,
            [
              l10n.allStates,
              ..._states.map(
                (s) => s is Map ? s['state_name'].toString() : s.toString(),
              ),
            ],
            (value) {
              setState(() => _selectedState = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            l10n.locality,
            _selectedLocality ?? l10n.allLocalities,
            [
              l10n.allLocalities,
              ..._localities.map(
                (l) => l is Map ? l['locality_name'].toString() : l.toString(),
              ),
            ],
            (value) {
              setState(() => _selectedLocality = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            l10n.status,
            _selectedStatus ?? l10n.allStatus,
            [
              l10n.allStatus,
              l10n.active,
              l10n.inactive,
              l10n.martyr,
              l10n.wounded,
            ],
            (value) {
              setState(() => _selectedStatus = value);
              _applyFilters();
            },
          ),
          const Spacer(),
          ModernGradientButton(
            text: l10n.add,
            icon: Icons.add_rounded,
            onPressed: () => _navigateToForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String title,
    String selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : AppColors.slate50,
            border: Border.all(
              color: isDark ? AppColors.slate700 : AppColors.slate200,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(selectedValue)
                  ? selectedValue
                  : options.first,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
                fontSize: 14,
                fontFamily: 'Tajawal', // Ensure font consistency
              ),
              items: options
                  .map(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonnelGrid(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage));

    if (_filteredPersonnelList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColors.slate300),
            SizedBox(height: 16),
            Text(
              "لا توجد نتائج مطابقة", // No results
              style: TextStyle(fontSize: 18, color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.5, // Improved aspect ratio
      ),
      itemCount: _filteredPersonnelList.length,
      itemBuilder: (context, index) => _buildPersonnelCard(
        context,
        _filteredPersonnelList[index],
        isGrid: true,
      ),
    );
  }

  Widget _buildPersonnelList(BuildContext context) {
    if (_filteredPersonnelList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColors.slate300),
            SizedBox(height: 16),
            Text(
              "لا توجد نتائج مطابقة",
              style: TextStyle(fontSize: 18, color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredPersonnelList.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildPersonnelCard(
        context,
        _filteredPersonnelList[index],
        isList: true,
      ),
    );
  }

  Widget _buildPersonnelCard(
    BuildContext context,
    dynamic personnel, {
    bool isList = false,
    bool isGrid = false,
  }) {
    // IMPORTANT: Using helper method to ensure we get data even if keys vary (snake vs camel)
    final firstName = _getField(personnel, 'first_name');
    final secondName = _getField(personnel, 'second_name');
    final militaryId = _getField(personnel, 'military_id');
    final status = _getField(personnel, 'status');

    final l10n = AppLocalizations.of(context)!;

    return ModernGlassCard(
      onTap: () => _navigateToDetails(context, personnel),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(personnel),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$firstName $secondName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Larger font
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: AppColors.slate500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${l10n.militaryId}: $militaryId',
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontSize: 13,
                        fontFamily: 'Roboto', // Numbers look better in Roboto
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatusBadge(status, l10n),
              ],
            ),
          ),
          if (isList)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.slate300,
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic personnel) {
    // We could add an image URL field later if available
    return Container(
      width: 56, // Larger avatar
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: const Center(
        child: Icon(Icons.person, color: AppColors.primary, size: 28),
      ),
    );
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    Color color = AppColors.slate500;
    String label = status;

    // Normalizing status check because API might return varied casing or language
    final s = status.toLowerCase();

    if (s == 'نشط' || s == 'active') {
      color = AppColors.secondary; // Emerald
      label = l10n.active;
    } else if (s == 'غير نشط' || s == 'inactive') {
      color = AppColors.accent; // Amber
      label = l10n.inactive;
    } else if (s == 'شهيد' || s == 'martyr') {
      color = AppColors.error; // Red
      label = l10n.martyr;
    } else if (s == 'جريح' || s == 'wounded') {
      color = Colors.blue;
      label = l10n.wounded;
    }

    return ModernStatusBadge(text: label, color: color);
  }

  void _navigateToDetails(BuildContext context, dynamic personnel) {
    String idString = personnel['id'].toString();
    // Safety check if ID is not a number
    int? id = int.tryParse(idString);
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid ID: $idString")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelDetailScreen(personnelId: id),
      ),
    );
  }

  void _navigateToForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonnelFormScreen()),
    );
    if (result == true) _loadPersonnel();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Only show AppBar on mobile if we desire standard navigation,
      // but to be modern, we might want to hide it or style it differently.
      // Keeping it simple for now but elevating the style.
      appBar: isWeb
          ? null
          : AppBar(
              title: Text(AppLocalizations.of(context)!.personnelManagement),
              elevation: 0,
              backgroundColor: Colors.transparent, // Modern transparent app bar
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              actions: [
                IconButton(
                  onPressed: _initializeData,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: AppLocalizations.of(context)!.refresh,
                ),
              ],
            ),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
      floatingActionButton: !isWeb
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _navigateToForm(context),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }
}
