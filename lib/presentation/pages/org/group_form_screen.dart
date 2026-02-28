import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/modern_widgets.dart';
import '../../../core/services/org_service.dart';

class GroupFormScreen extends StatefulWidget {
  final int deptId;
  const GroupFormScreen({Key? key, required this.deptId}) : super(key: key);

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _selectedGovernorId;
  List<dynamic> _availablePersonnel = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailablePersonnel();
  }

  Future<void> _loadAvailablePersonnel() async {
    try {
      final personnel = await OrgService.getAvailablePersonnel();
      setState(() {
        _availablePersonnel = personnel;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الأفراد: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await OrgService.createGroup(
        widget.deptId,
        _nameController.text,
        _selectedGovernorId,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء المجموعة بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في حفظ المجموعة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة مجموعة جديدة',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ModernSectionCard(
                      title: 'بيانات المجموعة',
                      icon: Icons.edit_rounded,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم المجموعة',
                                hintText: 'مثال: مجموعة 1 - هندسة',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'يرجى إدخال اسم المجموعة'
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: 24.0,
                            ),
                            child: DropdownButtonFormField<int>(
                              value: _selectedGovernorId,
                              decoration: const InputDecoration(
                                labelText: 'حكمدار المجموعة',
                                border: OutlineInputBorder(),
                              ),
                              items: _availablePersonnel.map((p) {
                                return DropdownMenuItem<int>(
                                  value: p['id'],
                                  child: Text(p['full_name'] ?? 'بدون اسم'),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedGovernorId = val),
                              hint: const Text(
                                'اختر حكمدار المجموعة (اختياري)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ModernGradientButton(
                      text: 'حفظ المجموعة',
                      onPressed: _save,
                      icon: Icons.save_rounded,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
