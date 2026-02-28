import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/org_service.dart';
import '../../../core/models/organization.dart';

class GroupDetailScreen extends StatefulWidget {
  final OrgGroup group;
  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  List<dynamic> _personnel = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPersonnel();
  }

  Future<void> _loadPersonnel() async {
    try {
      final personnel = await OrgService.getGroupPersonnel(widget.group.id);
      setState(() {
        _personnel = personnel;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الأفراد: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPersonnel() async {
    final available = await OrgService.getAvailablePersonnel();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'إضافة أفراد للمجموعة',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final p = available[index];
                    return ListTile(
                      title: Text(p['full_name'] ?? 'بدون اسم'),
                      subtitle: Text('رقم عسكري: ${p['military_id']}'),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                      onTap: () async {
                        try {
                          await OrgService.addPersonnelToGroup(
                            p['id'],
                            widget.group.id,
                          );
                          Navigator.pop(context);
                          _loadPersonnel();
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removePersonnel(int id) async {
    try {
      await OrgService.removePersonnelFromGroup(id);
      _loadPersonnel();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'أفراد ${widget.group.name}',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPersonnel,
        label: const Text('إضافة فرد'),
        icon: const Icon(Icons.person_add_rounded),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _personnel.length,
              itemBuilder: (context, index) {
                final p = _personnel[index];
                final isGovernor = p['id'] == widget.group.governorId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isGovernor
                          ? AppColors.accent
                          : AppColors.secondary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      p['full_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رقم عسكري: ${p['military_id']}'),
                        if (isGovernor)
                          const Text(
                            'حكمدار المجموعة',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => _removePersonnel(p['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
