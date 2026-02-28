import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/modern_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/org_service.dart';
import '../../../core/models/organization.dart';
import 'group_form_screen.dart';
import 'group_detail_screen.dart';

class DeptDetailScreen extends StatefulWidget {
  final Department department;
  const DeptDetailScreen({Key? key, required this.department})
    : super(key: key);

  @override
  State<DeptDetailScreen> createState() => _DeptDetailScreenState();
}

class _DeptDetailScreenState extends State<DeptDetailScreen> {
  List<OrgGroup> _groups = [];
  bool _isLoading = true;
  String? _currentGovernorName;

  @override
  void initState() {
    super.initState();
    _currentGovernorName = widget.department.governorName;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await OrgService.getGroupsByDept(widget.department.id);
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المجموعات: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateGovernor() async {
    try {
      final personnel = await OrgService.getAvailablePersonnel();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          int? selectedId;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('تعيين حكمدار القسم'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: DropdownButtonFormField<int>(
                    items: personnel.map((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'],
                        child: Text(p['full_name'] ?? 'بدون اسم'),
                      );
                    }).toList(),
                    onChanged: (val) => selectedId = val,
                    decoration: const InputDecoration(labelText: 'اختر فرد'),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedId != null) {
                        try {
                          await OrgService.updateDeptGovernor(
                            widget.department.id,
                            selectedId!,
                          );
                          Navigator.pop(context);
                          // Refresh
                          final depts = await OrgService.getDepartments();
                          final thisDept = depts.firstWhere(
                            (d) => d.id == widget.department.id,
                          );
                          setState(() {
                            _currentGovernorName = thisDept.governorName;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تمت العملية بنجاح')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                        }
                      }
                    },
                    child: const Text('تعيين'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في جلب الأفراد: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل قسم ${widget.department.name}',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GroupFormScreen(deptId: widget.department.id),
            ),
          ).then((_) => _loadGroups());
        },
        label: const Text('إضافة مجموعة'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernSectionCard(
                    title: 'معلومات القسم',
                    icon: Icons.info_outline_rounded,
                    child: ListTile(
                      leading: const Icon(Icons.person_outline_rounded),
                      title: const Text('حكمدار القسم'),
                      subtitle: Text(_currentGovernorName ?? 'غير معين'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        onPressed: _updateGovernor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المجموعات (${_groups.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.tajawal().fontFamily,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_groups.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('لا توجد مجموعات في هذا القسم حالياً'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GroupDetailScreen(group: group),
                                ),
                              ).then((_) => _loadGroups());
                            },
                            title: Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'حكمدار الجماعة: ${group.governorName ?? "غير معروف"}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${group.personnelCount}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  'فرد',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.group_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
