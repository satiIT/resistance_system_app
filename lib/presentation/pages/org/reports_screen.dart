import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/org_service.dart';
import '../../../core/models/organization.dart';
import '../../../core/services/personnel_service.dart';
import '../../../core/services/auth_service.dart';

class OrgReportsScreen extends StatefulWidget {
  final int userId;
  final String role;
  final int? personnelId;
  final String? reportScope; // Added to filter/pre-select by scope

  const OrgReportsScreen({
    Key? key,
    required this.userId,
    required this.role,
    this.personnelId,
    this.reportScope,
  }) : super(key: key);

  @override
  State<OrgReportsScreen> createState() => _OrgReportsScreenState();
}

class _OrgReportsScreenState extends State<OrgReportsScreen> {
  List<OrgReport> _reports = [];
  bool _isLoading = true;

  // Filter variables
  String _selectedFilterType = 'all';
  int? _filterDepartmentId;
  int? _filterGroupId;
  int? _filterPersonnelId;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  // Cached data for dropdowns
  List<Department> _departments = [];
  List<OrgGroup> _groups = [];
  List<dynamic> _personnel = [];
  List<dynamic> _filteredGroups = [];
  List<dynamic> _filteredPersonnel = [];

  bool _targetsLoaded = false;
  final AuthService _authService = AuthService();

  // User context
  int? _userDeptId;
  int? _userGroupId;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _loadTargets();
  }

  Future<void> _loadReports() async {
    try {
      // Use named parameters instead of positional arguments
      final reports = await OrgService.getReports(
        userId: widget.userId,
        role: widget.role,
        personnelId: widget.personnelId,
      );

      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل التقارير: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTargets() async {
    if (_targetsLoaded) return;
    try {
      // Get user specific context
      _userDeptId = await _authService.getUserDepartmentId();
      _userGroupId = await _authService.getUserGroupId();

      // Use static methods correctly
      final depts = await OrgService.getDepartments();
      final groups = await OrgService.getAllGroups();
      final personnel = await PersonnelService.getAllPersonnel();

      if (mounted) {
        setState(() {
          _departments = depts;
          _groups = groups;
          _personnel = personnel;

          // Role-based restrictions
          if (widget.role == 'group_governor' && _userGroupId != null) {
            _filterGroupId = _userGroupId;
            _filteredGroups = _groups
                .where((g) => g.id == _userGroupId)
                .toList();
            _filteredPersonnel = _personnel
                .where((p) => p['group_id'] == _userGroupId)
                .toList();
          } else if (widget.role == 'dept_governor' && _userDeptId != null) {
            _filterDepartmentId = _userDeptId;
            _filteredGroups = _groups
                .where((g) => g.deptId == _userDeptId)
                .toList();
            _filteredPersonnel = _personnel.where((p) {
              final group = _groups.firstWhere(
                (g) => g.id == p['group_id'],
                orElse: () =>
                    OrgGroup(id: -1, name: '', deptId: -1, personnelCount: 0),
              );
              return group.deptId == _userDeptId;
            }).toList();
          } else {
            _filteredGroups = groups;
            _filteredPersonnel = personnel;
          }

          _targetsLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading targets: $e');
    }
  }

  void _updateFilters() {
    setState(() {
      // Filter groups based on selected department
      if (_filterDepartmentId != null) {
        _filteredGroups = _groups
            .where((g) => g.deptId == _filterDepartmentId)
            .toList();
      } else {
        _filteredGroups = _groups;
      }

      // Filter personnel based on selected group
      if (_filterGroupId != null) {
        _filteredPersonnel = _personnel
            .where((p) => p['group_id'] == _filterGroupId)
            .toList();
      } else {
        _filteredPersonnel = _personnel;
      }
    });
  }

  List<OrgReport> _getFilteredReports() {
    return _reports.where((report) {
      // Filter by type
      if (_selectedFilterType != 'all' &&
          report.reportType != _selectedFilterType) {
        return false;
      }

      // Filter by department (for personnel and groups)
      if (_filterDepartmentId != null) {
        if (report.reportType == 'department' &&
            report.targetId != _filterDepartmentId) {
          return false;
        }
        // Add more complex filtering logic here based on your data structure
      }

      // Filter by group
      if (_filterGroupId != null) {
        if (report.reportType == 'group' && report.targetId != _filterGroupId) {
          return false;
        }
      }

      // Filter by personnel
      if (_filterPersonnelId != null) {
        if (report.reportType == 'personnel' &&
            report.targetId != _filterPersonnelId) {
          return false;
        }
      }

      // Filter by date range
      if (_filterStartDate != null) {
        if (report.createdAt.isBefore(_filterStartDate!)) {
          return false;
        }
      }

      if (_filterEndDate != null) {
        if (report.createdAt.isAfter(_filterEndDate!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.slate800,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filterStartDate = picked.start;
        _filterEndDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilterType = 'all';
      _filterDepartmentId = null;
      _filterGroupId = null;
      _filterPersonnelId = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _filteredGroups = _groups;
      _filteredPersonnel = _personnel;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'تصفية التقارير',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Report Type Filter
                    DropdownButtonFormField<String>(
                      value: _selectedFilterType,
                      decoration: const InputDecoration(
                        labelText: 'نوع التقرير',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('الكل'),
                        ),
                        if (widget.role == 'admin' ||
                            widget.role == 'group_governor')
                          const DropdownMenuItem(
                            value: 'personnel',
                            child: Text('أفراد'),
                          ),
                        if (widget.role == 'admin' ||
                            widget.role == 'dept_governor' ||
                            widget.role == 'group_governor')
                          const DropdownMenuItem(
                            value: 'group',
                            child: Text('مجموعات'),
                          ),
                        if (widget.role == 'admin' ||
                            widget.role == 'dept_governor')
                          const DropdownMenuItem(
                            value: 'department',
                            child: Text('أقسام'),
                          ),
                        const DropdownMenuItem(
                          value: 'weekly',
                          child: Text('تقرير أسبوعي'),
                        ),
                        const DropdownMenuItem(
                          value: 'monthly',
                          child: Text('تقرير شهري'),
                        ),
                      ],
                      onChanged: (val) =>
                          setDialogState(() => _selectedFilterType = val!),
                      isExpanded: true,
                    ),

                    const SizedBox(height: 16),

                    // Department Filter
                    DropdownButtonFormField<int?>(
                      value: _filterDepartmentId,
                      decoration: const InputDecoration(
                        labelText: 'القسم',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('الكل'),
                        ),
                        ..._departments
                            .where((d) {
                              if (widget.role == 'dept_governor' ||
                                  widget.role == 'group_governor') {
                                return d.id == _userDeptId;
                              }
                              return true;
                            })
                            .map(
                              (d) => DropdownMenuItem<int?>(
                                value: d.id,
                                child: Text(d.name),
                              ),
                            ),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          _filterDepartmentId = val;
                          _filterGroupId = null;
                          _filterPersonnelId = null;
                          if (val != null) {
                            _filteredGroups = _groups
                                .where((g) => g.deptId == val)
                                .toList();
                          } else {
                            _filteredGroups = _groups;
                          }
                        });
                      },
                      isExpanded: true,
                    ),

                    const SizedBox(height: 16),

                    // Group Filter
                    DropdownButtonFormField<int?>(
                      value: _filterGroupId,
                      decoration: const InputDecoration(
                        labelText: 'المجموعة',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('الكل'),
                        ),
                        ..._filteredGroups.map(
                          (g) => DropdownMenuItem<int?>(
                            value: g.id,
                            child: Text(g.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          _filterGroupId = val;
                          _filterPersonnelId = null;
                        });
                      },
                      isExpanded: true,
                    ),

                    const SizedBox(height: 16),

                    // Personnel Filter
                    DropdownButtonFormField<int?>(
                      value: _filterPersonnelId,
                      decoration: const InputDecoration(
                        labelText: 'الفرد',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('الكل'),
                        ),
                        ..._filteredPersonnel.map((p) {
                          final name = [
                            p['first_name'],
                            p['second_name'],
                            p['third_name'],
                            p['fourth_name'],
                          ].where((n) => n != null && n.isNotEmpty).join(' ');

                          return DropdownMenuItem<int?>(
                            value: p['id'],
                            child: Text(name.isNotEmpty ? name : 'بدون اسم'),
                          );
                        }),
                      ],
                      onChanged: (val) =>
                          setDialogState(() => _filterPersonnelId = val),
                      isExpanded: true,
                    ),

                    const SizedBox(height: 16),

                    // Date Range
                    InkWell(
                      onTap: () async {
                        DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _filterStartDate = picked.start;
                            _filterEndDate = picked.end;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _filterStartDate != null &&
                                        _filterEndDate != null
                                    ? 'من ${_filterStartDate!.day}/${_filterStartDate!.month}/${_filterStartDate!.year} إلى ${_filterEndDate!.day}/${_filterEndDate!.month}/${_filterEndDate!.year}'
                                    : 'اختر نطاق تاريخ',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearFilters();
                    Navigator.pop(context);
                  },
                  child: Text('مسح الكل'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Apply filters
                      _updateFilters();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('تطبيق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddReportDialog() async {
    final _noteController = TextEditingController();
    String _selectedType = widget.reportScope == 'personnel'
        ? 'personnel'
        : widget.reportScope == 'division'
        ? 'group'
        : widget.reportScope == 'unit'
        ? 'weekly'
        : 'personnel';
    int? _selectedTargetId;
    DateTime _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<DropdownMenuItem<int>> targetItems = [];

            if (_selectedType == 'personnel') {
              var filteredPeople = _personnel;
              if (widget.role == 'group_governor' && _userGroupId != null) {
                filteredPeople = _personnel
                    .where((p) => p['group_id'] == _userGroupId)
                    .toList();
              } else if (widget.role == 'dept_governor' &&
                  _userDeptId != null) {
                filteredPeople = _personnel.where((p) {
                  final group = _groups.firstWhere(
                    (g) => g.id == p['group_id'],
                    orElse: () => OrgGroup(
                      id: -1,
                      name: '',
                      deptId: -1,
                      personnelCount: 0,
                    ),
                  );
                  return group.deptId == _userDeptId;
                }).toList();
              }

              targetItems = filteredPeople.map<DropdownMenuItem<int>>((p) {
                final name = [
                  p['first_name'],
                  p['second_name'],
                  p['third_name'],
                  p['fourth_name'],
                ].where((n) => n != null && n.isNotEmpty).join(' ');

                return DropdownMenuItem<int>(
                  value: p['id'] as int,
                  child: Text(name.isEmpty ? 'بدون اسم' : name),
                );
              }).toList();
            } else if (_selectedType == 'group') {
              var filteredGroups = _groups;
              if (widget.role == 'group_governor' && _userGroupId != null) {
                filteredGroups = _groups
                    .where((g) => g.id == _userGroupId)
                    .toList();
              } else if (widget.role == 'dept_governor' &&
                  _userDeptId != null) {
                filteredGroups = _groups
                    .where((g) => g.deptId == _userDeptId)
                    .toList();
              }

              targetItems = filteredGroups
                  .map(
                    (g) =>
                        DropdownMenuItem<int>(value: g.id, child: Text(g.name)),
                  )
                  .toList();
            } else if (_selectedType == 'department') {
              var filteredDepts = _departments;
              if (widget.role == 'group_governor' && _userDeptId != null) {
                filteredDepts = _departments
                    .where((d) => d.id == _userDeptId)
                    .toList();
              } else if (widget.role == 'dept_governor' &&
                  _userDeptId != null) {
                filteredDepts = _departments
                    .where((d) => d.id == _userDeptId)
                    .toList();
              } else if (widget.role != 'admin') {
                // If not admin and not governor, they shouldn't see any dept to report on probably, but keep it broad for now or restricted
                filteredDepts = [];
              }

              targetItems = filteredDepts
                  .map(
                    (d) =>
                        DropdownMenuItem<int>(value: d.id, child: Text(d.name)),
                  )
                  .toList();
            }

            return AlertDialog(
              title: Text(
                'إضافة تقرير جديد',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Report Date
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            const SizedBox(width: 8),
                            Text(
                              'تاريخ التقرير: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: GoogleFonts.tajawal(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Report Type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع التقرير',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'personnel',
                          child: Text('فرد'),
                        ),
                        DropdownMenuItem(value: 'group', child: Text('مجموعة')),
                        DropdownMenuItem(
                          value: 'department',
                          child: Text('قسم'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('أسبوعي'),
                        ),
                        DropdownMenuItem(value: 'monthly', child: Text('شهري')),
                      ],
                      onChanged: (val) => setDialogState(() {
                        _selectedType = val!;
                        _selectedTargetId = null;
                      }),
                      isExpanded: true,
                    ),

                    const SizedBox(height: 16),

                    if (_selectedType == 'personnel' ||
                        _selectedType == 'group' ||
                        _selectedType == 'department') ...[
                      // Target
                      DropdownButtonFormField<int>(
                        value: _selectedTargetId,
                        decoration: const InputDecoration(
                          labelText: 'اختر الهدف',
                          border: OutlineInputBorder(),
                        ),
                        items: targetItems,
                        onChanged: (val) =>
                            setDialogState(() => _selectedTargetId = val),
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Notes
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'نص التقرير',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_noteController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برجاء إدخال نص التقرير')),
                      );
                      return;
                    }

                    try {
                      await OrgService.createReport(
                        _selectedType,
                        _selectedTargetId,
                        _noteController.text,
                        widget.userId,
                        reportDate: _selectedDate,
                      );
                      if (mounted) Navigator.pop(context);
                      _loadReports();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم إضافة التقرير بنجاح')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _getFilteredReports();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التقارير',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Filter Button
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          // Clear Filters Button
          if (_selectedFilterType != 'all' ||
              _filterDepartmentId != null ||
              _filterGroupId != null ||
              _filterPersonnelId != null ||
              _filterStartDate != null)
            IconButton(icon: Icon(Icons.clear_all), onPressed: _clearFilters),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReportDialog,
        label: const Text('إضافة تقرير'),
        icon: const Icon(Icons.note_add_rounded),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredReports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تقارير',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  if (_selectedFilterType != 'all' ||
                      _filterDepartmentId != null ||
                      _filterGroupId != null ||
                      _filterPersonnelId != null ||
                      _filterStartDate != null)
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text('إلغاء التصفية'),
                    ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                final String labelType = report.reportType == 'personnel'
                    ? 'تقرير فرد'
                    : report.reportType == 'group'
                    ? 'تقرير مجموعة'
                    : report.reportType == 'department'
                    ? 'تقرير قسم'
                    : report.reportType == 'weekly'
                    ? 'تقرير أسبوعي'
                    : 'تقرير شهري';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(
                                labelType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: AppColors.secondary.withOpacity(
                                0.2,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (report.reportDate != null)
                                  Text(
                                    'تاريخ التقرير: ${report.reportDate!.day}/${report.reportDate!.month}/${report.reportDate!.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'بخصوص: ${report.targetName}',
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.note ?? '',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const Divider(height: 32),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'بواسطة: ${report.creatorEmail ?? "غير معروف"}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
