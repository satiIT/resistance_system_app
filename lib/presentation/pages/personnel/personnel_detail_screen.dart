// lib/presentation/pages/personnel/personnel_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'dart:math' as math;
import 'package:universal_platform/universal_platform.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/services/personnel_service.dart';
import '../../../core/utils/data_parser.dart';
import 'personnel_form_screen.dart';
import 'personnel_training_screen.dart';
import 'personnel_movements_screen.dart';
import 'personnel_equipment_screen.dart';
import 'personnel_entitlements_screen.dart';
import 'personnel_reports_screen.dart';

class PersonnelDetailScreen extends StatefulWidget {
  final int personnelId;

  const PersonnelDetailScreen({Key? key, required this.personnelId})
    : super(key: key);

  @override
  _PersonnelDetailScreenState createState() => _PersonnelDetailScreenState();
}

class _PersonnelDetailScreenState extends State<PersonnelDetailScreen> {
  Map<String, dynamic> _personnelDetails = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPersonnelDetails();
  }

  Future<void> _loadPersonnelDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await PersonnelService.getPersonnelById(
        widget.personnelId.toString(),
      );

      if (mounted) {
        setState(() {
          if (result != null) {
            _personnelDetails = Map<String, dynamic>.from(result);
          } else {
            _errorMessage =
                AppLocalizations.of(context)?.noDataFound ?? 'No Data Found';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Robust field getter that handles:
  /// 1. Missing keys
  /// 2. Key variations (e.g. 'rank_name' instead of 'rank')
  /// 3. Nested objects (e.g. rank: {'name': '...'})
  /// 4. Case sensitivity
  String _getField(String key, {String? defaultValue}) {
    final localizedNoData = AppLocalizations.of(context)?.noDataFound ?? '-';
    return DataParser.smartGetString(
      _personnelDetails,
      key,
      defaultValue: defaultValue ?? localizedNoData,
    );
  }

  String _fullName() {
    final first = _getField('first_name', defaultValue: '');
    final second = _getField('second_name', defaultValue: '');
    final third = _getField('third_name', defaultValue: '');
    final fourth = _getField('fourth_name', defaultValue: '');

    final parts = [
      first,
      second,
      third,
      fourth,
    ].where((p) => p.isNotEmpty).toList();

    if (parts.isEmpty) {
      // Try fallback to a combined name field
      final fallback = _getField(
        'name',
        defaultValue: _getField('full_name', defaultValue: ''),
      );
      if (fallback.isNotEmpty) return fallback;

      return AppLocalizations.of(context)?.noDataFound ?? '-';
    }
    return parts.join(' ');
  }

  void _editPersonnel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelFormScreen(
          personnelId: widget.personnelId.toString(),
          initialData: _personnelDetails,
        ),
      ),
    ).then((_) => _loadPersonnelDetails());
  }

  void _showTrainingHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelTrainingScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showMovements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelMovementsScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showEntitlements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelEntitlementsScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showEquipment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelEquipmentScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  void _showReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonnelReportsScreen(
          personnelId: widget.personnelId,
          personnelName: _fullName(),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          textAlign: TextAlign.start,
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : AppColors.slate800,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          alignment: Alignment.centerLeft,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isDark ? AppColors.slate800 : Colors.grey[300]!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsPanel() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.grey[50],
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.slate800 : Colors.grey[300]!,
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? []
            : [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 0),
                ),
              ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(Icons.dashboard, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.quickActions,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              _buildActionButton(
                l10n.updateData,
                Icons.update,
                Colors.blue,
                _editPersonnel,
              ),
              _buildActionButton(
                l10n.trainingHistory,
                Icons.school,
                Colors.green,
                _showTrainingHistory,
              ),
              _buildActionButton(
                l10n.movements,
                Icons.directions,
                Colors.orange,
                _showMovements,
              ),
              _buildActionButton(
                l10n.entitlements,
                Icons.attach_money,
                Colors.purple,
                _showEntitlements,
              ),
              _buildActionButton(
                l10n.equipment,
                Icons.security,
                Colors.red,
                _showEquipment,
              ),
              _buildActionButton(
                l10n.reports,
                Icons.assessment,
                Colors.teal,
                _showReports,
              ),

              Divider(
                height: 30,
                thickness: 1,
                color: isDark ? AppColors.slate800 : Colors.grey[300],
              ),
              _buildQuickInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickInfo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.slate400 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickInfoItem(l10n.status, _getField('status'), Colors.green),
        _buildQuickInfoItem(l10n.rank, _getField('rank'), Colors.blue),
        _buildQuickInfoItem(l10n.unit, _getField('unit'), Colors.orange),
        _buildQuickInfoItem(
          l10n.lastUpdate,
          _getField('updated_at'),
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildQuickInfoItem(String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.slate400 : Colors.grey[600],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonnelHeader() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idText = widget.personnelId.toString();
    final name = _fullName();
    final status = _getField('status');

    return Card(
      elevation: 2,
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primary,
              child: Text(
                idText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.militaryId}: ${_getField('military_id')}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.slate400 : AppColors.slate700,
                    ),
                  ),
                  Text(
                    '${l10n.nationalId}: ${_getField('national_id')}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.slate400 : AppColors.slate700,
                    ),
                  ),
                  Text(
                    '${l10n.status}: $status',
                    style: TextStyle(
                      color:
                          status.toLowerCase().contains('نشط') ||
                              status.toLowerCase().contains('active')
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Chip(
                  label: Text(
                    _getField('rank'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    _getField('unit'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTabs() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTabController(
          length: 5,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? AppColors.slate400
                      : Colors.grey[600],
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isDark
                        ? []
                        : [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                  tabs: [
                    Tab(text: l10n.basicInfo),
                    Tab(text: l10n.geographicalInfo),
                    Tab(text: l10n.militaryInfo),
                    Tab(text: l10n.familyInfo),
                    Tab(text: l10n.medicalInfo),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: math.min(
                  400,
                  MediaQuery.of(context).size.height * 0.55,
                ),
                child: TabBarView(
                  children: [
                    _wrapTabWithScrollbar(_buildBasicInfoTab()),
                    _wrapTabWithScrollbar(_buildGeographicalInfoTab()),
                    _wrapTabWithScrollbar(_buildMilitaryInfoTab()),
                    _wrapTabWithScrollbar(_buildFamilyInfoTab()),
                    _wrapTabWithScrollbar(_buildMedicalInfoTab()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrapTabWithScrollbar(Widget tab) {
    return Scrollbar(thumbVisibility: true, child: tab);
  }

  Widget _buildBasicInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildInfoRow(l10n.fullName, _fullName()),
        _buildInfoRow(l10n.birthDate, _getField('birth_date')),
        _buildInfoRow(l10n.gender, _getField('gender')),
        _buildInfoRow(l10n.maritalStatus, _getField('marital_status')),
        _buildInfoRow(l10n.educationLevel, _getField('education_level')),
        _buildInfoRow(l10n.occupation, _getField('occupation')),
        _buildInfoRow(l10n.skills, _getField('skills')),
      ],
    );
  }

  Widget _buildGeographicalInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildInfoRow(l10n.state, _getField('state')),
        _buildInfoRow(l10n.locality, _getField('locality')),
        _buildInfoRow(
          l10n.administrativeUnit,
          _getField('administrative_unit'),
        ),
        _buildInfoRow(l10n.cityVillage, _getField('city_village')),
        _buildInfoRow(l10n.currentResidence, _getField('current_residence')),
        _buildInfoRow(l10n.prewarResidence, _getField('prewar_residence')),
        _buildInfoRow(l10n.placeOfOrigin, _getField('place_of_origin')),
      ],
    );
  }

  Widget _buildMilitaryInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildInfoRow(l10n.rank, _getField('rank')),
        _buildInfoRow(l10n.unit, _getField('unit')),
        _buildInfoRow(l10n.enlistmentDate, _getField('enlistment_date')),
        _buildInfoRow(
          l10n.militaryBackground,
          _getField('military_background'),
        ),
        _buildInfoRow(l10n.basicTraining, _getField('basic_training')),
        _buildInfoRow(l10n.weaponType, _getField('weapon_type')),
        _buildInfoRow(l10n.lastTrainingDate, _getField('last_training_date')),
      ],
    );
  }

  Widget _buildFamilyInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildInfoRow(l10n.wivesCount, _getField('wives_count')),
        _buildInfoRow(l10n.childrenCount, _getField('children_count')),
        _buildInfoRow(l10n.dependentsCount, _getField('dependents_count')),
        _buildInfoRow(l10n.motherName, _getField('mother_full_name')),
        _buildInfoRow(l10n.motherPhone, _getField('mother_phone')),
        _buildInfoRow(l10n.nextOfKin, _getField('next_of_kin')),
        _buildInfoRow(l10n.nextOfKinPhone, _getField('next_of_kin_phone')),
      ],
    );
  }

  Widget _buildMedicalInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildInfoRow(l10n.healthStatus, _getField('health_status')),
        _buildInfoRow(l10n.chronicConditions, _getField('chronic_conditions')),
        _buildInfoRow(l10n.allergies, _getField('allergies')),
        _buildInfoRow(l10n.medicalNotes, _getField('medical_notes')),
        _buildInfoRow(l10n.bloodType, _getField('blood_type')),
        _buildInfoRow(
          l10n.emergencyContactPhone,
          _getField('emergency_contact_phone'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.slate800 : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white : AppColors.slate900,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.slate400 : Colors.grey[700],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;
    final bool isMobile = ResponsiveLayout.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    Widget bodyContent;
    if (_isLoading) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loading),
          ],
        ),
      );
    } else if (_errorMessage.isNotEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.errorOccurred),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPersonnelDetails,
              child: Text(l10n.refresh),
            ),
          ],
        ),
      );
    } else {
      bodyContent = isWeb
          ? _buildWebLayout(context)
          : _buildMobileLayout(context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.viewDetails),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editPersonnel),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showComingSoonDialog(l10n.share),
          ),
        ],
      ),
      body: SafeArea(child: bodyContent),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActionsPanel(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonnelHeader(),
                      const SizedBox(height: 20),
                      _buildInfoTabs(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildPersonnelHeader(),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(),
          const SizedBox(height: 16),
          _buildInfoTabs(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              l10n.quickActions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.slate900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMobileActionButton(
                  l10n.updateData,
                  Icons.update,
                  Colors.blue,
                  _editPersonnel,
                ),
                _buildMobileActionButton(
                  l10n.trainingHistory,
                  Icons.school,
                  Colors.green,
                  _showTrainingHistory,
                ),
                _buildMobileActionButton(
                  l10n.movements,
                  Icons.directions,
                  Colors.orange,
                  _showMovements,
                ),
                _buildMobileActionButton(
                  l10n.entitlements,
                  Icons.attach_money,
                  Colors.purple,
                  _showEntitlements,
                ),
                _buildMobileActionButton(
                  l10n.equipment,
                  Icons.security,
                  Colors.red,
                  _showEquipment,
                ),
                _buildMobileActionButton(
                  l10n.reports,
                  Icons.assessment,
                  Colors.teal,
                  _showReports,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.comingSoon),
        content: Text('${l10n.inDevelopment}: $feature'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
