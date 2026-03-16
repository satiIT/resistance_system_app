import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/core/services/personnel_service.dart';
import 'package:resistance_system_app/core/services/intelligence_service.dart';

class IntelligenceArchiveScreen extends StatefulWidget {
  final String title;
  final String type;
  final IconData icon;

  const IntelligenceArchiveScreen({
    Key? key,
    required this.title,
    required this.type,
    required this.icon,
  }) : super(key: key);

  @override
  State<IntelligenceArchiveScreen> createState() =>
      _IntelligenceArchiveScreenState();
}

class _IntelligenceArchiveScreenState extends State<IntelligenceArchiveScreen> {
  List<dynamic> _records = [];
  List<dynamic> _allPersonnel = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final personnel = await PersonnelService.getAllPersonnel();
      final records = await IntelligenceService.getRecords(widget.type);

      setState(() {
        _allPersonnel = personnel;
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() => _isLoading = false);
      if (e.toString().contains('AUTH_REQUIRED')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('انتهت الجلسة، يرجى إعادة تسجيل الدخول'),
          ),
        );
      }
    }
  }

  Future<void> _saveRecord(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    final success = await IntelligenceService.saveRecord(widget.type, data);
    if (success) {
      await _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل الحفظ')));
    }
  }

  void _showAddDialog() {
    final Map<String, dynamic> formData = {};
    final controllers = <String, TextEditingController>{};

    List<Widget> fields = [];

    if (widget.type == 'proactive') {
      controllers['text'] = TextEditingController();
      controllers['location'] = TextEditingController();
      fields = [
        _buildTextField(
          controllers['text']!,
          'نص المعلومة',
          Icons.text_snippet,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controllers['location']!,
          'مكان المعلومة',
          Icons.location_on,
        ),
      ];
    } else if (widget.type == 'weapons') {
      controllers['type'] = TextEditingController();
      controllers['name'] = TextEditingController();
      controllers['number'] = TextEditingController();
      int? selectedPersonnelId;

      fields = [
        _buildTextField(controllers['type']!, 'نوع السلاح', Icons.category),
        const SizedBox(height: 16),
        _buildTextField(controllers['name']!, 'اسم السلاح', Icons.label),
        const SizedBox(height: 16),
        _buildTextField(controllers['number']!, 'رقم السلاح', Icons.numbers),
        const SizedBox(height: 16),
        _buildPersonnelDropdown((val) => selectedPersonnelId = val),
      ];
      formData['personnel_id'] = () => selectedPersonnelId;
    } else if (widget.type == 'statements') {
      controllers['statement'] = TextEditingController();
      int? selectedPersonnelId;
      DateTime selectedDate = DateTime.now();

      fields = [
        _buildPersonnelDropdown((val) => selectedPersonnelId = val),
        const SizedBox(height: 16),
        _buildDatePicker(
          'تاريخ الانضمام',
          selectedDate,
          (date) => selectedDate = date,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controllers['statement']!,
          'نص الإفادة',
          Icons.assignment,
          maxLines: 3,
        ),
      ];
      formData['personnel_id'] = () => selectedPersonnelId;
      formData['date'] = () => selectedDate;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.slate800,
          title: Text(
            widget.title,
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: fields),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final Map<String, dynamic> recordData = {};
                if (widget.type == 'proactive') {
                  recordData['text'] = controllers['text']!.text;
                  recordData['location'] = controllers['location']!.text;
                } else if (widget.type == 'weapons') {
                  recordData['weapon_type'] = controllers['type']!.text;
                  recordData['weapon_name'] = controllers['name']!.text;
                  recordData['weapon_serial_number'] =
                      controllers['number']!.text;
                  recordData['personnel_id'] = formData['personnel_id']();
                } else if (widget.type == 'statements') {
                  recordData['personnel_id'] = formData['personnel_id']();
                  recordData['statement'] = controllers['statement']!.text;
                  recordData['date'] = formData['date']().toIso8601String();
                }

                Navigator.pop(context);
                _saveRecord(recordData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('حفظ', style: GoogleFonts.tajawal()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  String _getPersonnelFullName(Map p, {String fallback = 'بدون اسم'}) {
    if (p['full_name'] != null && p['full_name'].toString().trim().isNotEmpty) {
      return p['full_name'].toString();
    }
    if (p['name'] != null && p['name'].toString().trim().isNotEmpty) {
      return p['name'].toString();
    }

    final p1 = p['first_name']?.toString() ?? '';
    final p2 = p['second_name']?.toString() ?? '';
    final p3 = p['third_name']?.toString() ?? '';
    final p4 = p['fourth_name']?.toString() ?? '';

    final combined = [p1, p2, p3, p4].where((e) => e.trim().isNotEmpty).join(' ');

    if (combined.isNotEmpty) return combined;
    return fallback;
  }

  String _getPersonnelNameFromId(int? id, {String fallback = 'غير معروف'}) {
    if (id == null) return fallback;
    try {
      final person = _allPersonnel.firstWhere(
        (p) => p['id'] == id || p['id'].toString() == id.toString(),
      );
      return _getPersonnelFullName(person as Map, fallback: fallback);
    } catch (e) {
      return fallback;
    }
  }

  Widget _buildPersonnelDropdown(void Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      dropdownColor: AppColors.slate800,
      decoration: InputDecoration(
        labelText: 'الفرد المستلم/المعني',
        labelStyle: const TextStyle(color: Colors.white60),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
      ),
      items: _allPersonnel
          .map(
            (p) => DropdownMenuItem<int>(
              value: p['id'],
              child: Text(
                _getPersonnelFullName(p as Map),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime initialDate,
    void Function(DateTime) onPicked,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) onPicked(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${initialDate.day}/${initialDate.month}/${initialDate.year}',
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.tajawal()),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 80, color: Colors.white10),
                  const SizedBox(height: 24),
                  Text(
                    'لا توجد سجلات حالياً',
                    style: GoogleFonts.tajawal(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return _buildRecordCard(record);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    String title = '';
    String subtitle = '';

    if (widget.type == 'proactive') {
      title = record['info_text'] ?? '';
      subtitle = 'الموقع: ${record['location'] ?? ''}';
    } else if (widget.type == 'weapons') {
      title =
          '${record['weapon_name'] ?? ''} (${record['weapon_serial_number'] ?? ''})';
      subtitle = 'النوع: ${record['weapon_type'] ?? ''}';
      if (record['personnel_id'] != null) {
        String pName = record['personnel_name']?.toString() ?? '';
        if (pName.isEmpty || pName == 'null' || pName.contains('Ø')) { // Fallback if name is empty or garbled utf8
           pName = _getPersonnelNameFromId(int.tryParse(record['personnel_id'].toString()));
        }
        subtitle += ' | المستلم: $pName';
      }
    } else if (widget.type == 'statements') {
      String pName = record['personnel_name']?.toString() ?? '';
      if (pName.isEmpty || pName == 'null' || pName.contains('Ø')) {
         pName = _getPersonnelNameFromId(int.tryParse(record['personnel_id']?.toString() ?? ''));
      }
      title = 'إفادة عن $pName';
      subtitle =
          'تاريخ الانضمام: ${record['joining_date'] ?? ''} | الإفادة: ${record['statement_text'] ?? ''}';
    }

    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: Text(
          record['created_at'] != null
              ? '${DateTime.parse(record['created_at'].toString()).day}/${DateTime.parse(record['created_at'].toString()).month}'
              : '',
          style: const TextStyle(color: Colors.white24, fontSize: 12),
        ),
      ),
    );
  }
}
