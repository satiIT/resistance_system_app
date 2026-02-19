// lib/presentation/pages/casualties/casualties_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/models/casualty.dart';
import '../../../core/services/casualty_api.dart';
import 'casualty_form_screen.dart';
import 'casualty_detail_screen.dart';

class CasualtiesScreen extends StatefulWidget {
  const CasualtiesScreen({Key? key}) : super(key: key);

  @override
  _CasualtiesScreenState createState() => _CasualtiesScreenState();
}

class _CasualtiesScreenState extends State<CasualtiesScreen> {
  List<Casualty> _casualties = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: الكل, 1: شهداء فقط, 2: جرحى فقط

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCasualties();
  }

  Future<void> _loadCasualties() async {
    try {
      final casualties = await CasualtyApi.getCasualties();
      setState(() {
        _casualties = casualties;
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
        content: Text(message, style: GoogleFonts.tajawal()),
        backgroundColor: AppColors.error,
      ),
    );
  }

  List<Casualty> get _filteredCasualties {
    var filtered = _casualties;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((casualty) {
        return (casualty.militaryNumber ?? '').toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (casualty.fullName ?? '').toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (casualty.incidentLocation ?? '').toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }
    if (_selectedFilter == 1) {
      filtered = filtered.where((casualty) => casualty.isMartyr).toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((casualty) => casualty.isInjured).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: 'الجرحى والشهداء',
      actions: [
        IconButton(
          icon: const Icon(Icons.analytics_outlined, color: Colors.white),
          onPressed: () => _showCasualtyStats(context),
        ),
      ],
      children: [
        _buildTopHeader(),
        _buildSearchAndFilter(),
        const SizedBox(height: 16),
        _isLoading ? _buildLoading() : _buildList(),
      ],
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.error, Color(0xFFD32F2F)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addNewCasualty,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ModernScreenHeader(
        title: 'سجل التضحيات',
        subtitle: 'توثيق بيانات الشهداء والجرحى في استمارة رقم (4).',
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          ModernSearchField(
            controller: _searchController,
            hint: 'ابحث بالاسم، الرقم العسكري...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('الكل', 0),
                const SizedBox(width: 12),
                _buildFilterChip('الشهداء', 1, color: AppColors.error),
                const SizedBox(width: 12),
                _buildFilterChip('الجرحى', 2, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, {Color? color}) {
    final isSelected = _selectedFilter == index;
    final activeColor = color ?? AppColors.primary;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (color?.withOpacity(0.5) ?? AppColors.slate200),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : (color ?? AppColors.slate600),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.error),
    );
  }

  Widget _buildList() {
    final filtered = _filteredCasualties;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColors.slate300),
            const SizedBox(height: 16),
            Text(
              'لا توجد سجلات مطابقة',
              style: GoogleFonts.tajawal(
                color: AppColors.slate500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildCasualtyCard(filtered[index]),
    );
  }

  Widget _buildCasualtyCard(Casualty casualty) {
    final isMartyr = casualty.isMartyr;
    final color = isMartyr ? AppColors.error : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ModernGlassCard(
        onTap: () => _viewCasualtyDetails(casualty),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(
                isMartyr ? Icons.flag_rounded : Icons.medical_services_rounded,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    casualty.fullName ?? 'غير مسمى',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${casualty.militaryNumber ?? "-"}',
                        style: GoogleFonts.tajawal(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                isMartyr ? 'شهيد' : 'جريح',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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

  void _addNewCasualty() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CasualtyFormScreen()),
    ).then((_) => _loadCasualties());
  }

  void _showCasualtyStats(BuildContext context) async {
    try {
      final stats = await CasualtyApi.getCasualtyStats();
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملخص الإحصائيات',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatRow(
                'إجمالي السجلات',
                stats['total']?.toString() ?? '0',
                Icons.analytics_rounded,
              ),
              _buildStatRow(
                'عدد الشهداء',
                stats['martyrs']?.toString() ?? '0',
                Icons.flag_rounded,
                color: AppColors.error,
              ),
              _buildStatRow(
                'عدد الجرحى',
                stats['injured']?.toString() ?? '0',
                Icons.medical_services_rounded,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              ModernGradientButton(
                text: 'إغلاق',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('فشل تحميل الإحصائيات');
    }
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
