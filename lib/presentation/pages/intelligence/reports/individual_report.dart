import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/core/services/personnel_service.dart';

class IndividualIntelligenceReport extends StatefulWidget {
  const IndividualIntelligenceReport({Key? key}) : super(key: key);

  @override
  State<IndividualIntelligenceReport> createState() =>
      _IndividualIntelligenceReportState();
}

class _IndividualIntelligenceReportState
    extends State<IndividualIntelligenceReport> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _personnel = [];
  List<dynamic> _filteredPersonnel = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPersonnel();
  }

  Future<void> _loadPersonnel() async {
    try {
      final data = await PersonnelService.getAllPersonnel();
      setState(() {
        _personnel = data;
        _filteredPersonnel = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterPersonnel(String query) {
    setState(() {
      _filteredPersonnel = _personnel.where((p) {
        final name = (p['full_name'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(
        title: Text('تقرير عن فرد', style: GoogleFonts.tajawal()),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPersonnel,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن فرد...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredPersonnel.length,
                    itemBuilder: (context, index) {
                      final p = _filteredPersonnel[index];
                      return ListTile(
                        title: Text(
                          p['full_name'] ?? 'بدون اسم',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          p['military_id'] ?? '',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 16,
                        ),
                        onTap: () => _showReportDetails(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(Map p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate800,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تقرير استخباراتي: ${p['full_name']}',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailTile(
                'الرقم العسكري',
                p['military_id'] ?? 'غير متوفر',
              ),
              _buildDetailTile('التخصص', p['specialization'] ?? 'غير متوفر'),
              _buildDetailTile('الرتبة', p['rank'] ?? 'غير متوفر'),
              const Divider(color: Colors.white12, height: 32),
              _buildDetailTile('ملاحظات أمنية', 'لا توجد ملاحظات حالياً'),
              _buildDetailTile('المسار الحركي', 'قيد التحليل'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text('إغلاق', style: GoogleFonts.tajawal()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
