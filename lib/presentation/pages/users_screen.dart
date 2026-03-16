import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/org_service.dart';
import '../../core/services/personnel_service.dart';
import '../../core/models/organization.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final AuthService _authService = AuthService();

  List<dynamic> _users = [];
  List<Department> _departments = [];
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
      final users = await _authService.getUsers();
      final depts = await OrgService.getDepartments();
      List<dynamic> personnel = [];
      try {
        final raw = await PersonnelService.getAllPersonnel();
        personnel = raw;
      } catch (pe) {
        print('Warning: could not load personnel: $pe');
      }

      if (mounted) {
        setState(() {
          _users = users;
          _departments = depts;
          _allPersonnel = personnel;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _authService.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  /// Check if an email is already used by any existing user
  bool _isEmailTaken(String email) {
    return _users.any(
      (u) => (u['email'] ?? '').toString().toLowerCase() == email.toLowerCase(),
    );
  }

  /// Generate alternative email when base email is taken
  String _generateAlternativeEmail(String baseEmail) {
    final parts = baseEmail.split('@');
    if (parts.length == 2) {
      final num = DateTime.now().millisecondsSinceEpoch % 1000;
      return '${parts[0]}$num@${parts[1]}';
    }
    return '${baseEmail}_${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  void _showAddUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'data_entry';
    int? selectedDepartmentId;
    int? selectedGroupId;
    int? selectedPersonnelId;
    String? errorMessage;
    String? warningMessage;

    // Dialog-local state for groups
    List<OrgGroup> dialogGroups = [];
    bool isLoadingGroups = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final needsDept =
              selectedRole == 'dept_governor' ||
              selectedRole == 'group_governor';
          final needsGroup = selectedRole == 'group_governor';

          /// Load groups inside dialog state so it rebuilds correctly
          Future<void> loadGroupsForDept(int deptId) async {
            setDialogState(() {
              isLoadingGroups = true;
              dialogGroups = [];
              selectedGroupId = null;
            });
            try {
              final groups = await OrgService.getGroupsByDept(deptId);
              setDialogState(() {
                dialogGroups = groups;
                isLoadingGroups = false;
              });
            } catch (e) {
              setDialogState(() => isLoadingGroups = false);
            }
          }

          /// When a personnel is selected, try to auto-fill email
          void onPersonnelSelected(int? personnelId) {
            setDialogState(() {
              selectedPersonnelId = personnelId;
              warningMessage = null;
            });
            if (personnelId == null) return;

            final _matches = _allPersonnel
                .where((p) => _parseInt(p['id']) == personnelId)
                .toList();
            if (_matches.isEmpty) return;
            final person = _matches.first;

            // Try to get email from personnel record
            String? personnelEmail = person['email'] as String?;
            if ((personnelEmail == null || personnelEmail.isEmpty) &&
                person['national_id'] != null) {
              personnelEmail = '${person['national_id']}@unit.local';
            }

            if (personnelEmail != null && personnelEmail.isNotEmpty) {
              if (_isEmailTaken(personnelEmail)) {
                final alt = _generateAlternativeEmail(personnelEmail);
                setDialogState(() {
                  emailController.text = alt;
                  warningMessage =
                      'البريد "$personnelEmail" مستخدم مسبقاً. تم اقتراح: $alt';
                });
              } else {
                setDialogState(() {
                  emailController.text = personnelEmail ?? '';
                });
              }
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.slate800,
            title: Text(
              'إضافة مستخدم جديد',
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Error banner ──────────────────────────────────────
                    if (errorMessage != null)
                      _infoBanner(errorMessage!, Colors.red),

                    // ── Warning banner (email conflict) ───────────────────
                    if (warningMessage != null)
                      _infoBanner(warningMessage!, Colors.orange),

                    const SizedBox(height: 4),

                    // ── Personnel picker ──────────────────────────────────
                    _sectionLabel('ربط بمستنفر (اختياري)'),
                    DropdownButtonFormField<int?>(
                      value: selectedPersonnelId,
                      dropdownColor: AppColors.slate800,
                      style: GoogleFonts.tajawal(color: Colors.white),
                      isExpanded: true,
                      decoration: _inputDecoration(
                        'اختر المستنفر',
                        Icons.person_search_rounded,
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'بدون ربط',
                            style: GoogleFonts.tajawal(color: Colors.white54),
                          ),
                        ),
                        ..._allPersonnel.whereType<Map>().map((p) {
                          final id = _parseInt(p['id']);
                          final name = _getPersonnelFullName(p);
                          final number =
                              (p['service_number'] ?? p['military_id'] ?? '')
                                  .toString();
                          return DropdownMenuItem<int?>(
                            value: id,
                            child: Text(
                              '$name ${number.isNotEmpty ? "($number)" : ""}',
                              style: GoogleFonts.tajawal(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) => onPersonnelSelected(val),
                    ),

                    const SizedBox(height: 16),

                    // ── Email ─────────────────────────────────────────────
                    _sectionLabel('بيانات الحساب'),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.tajawal(color: Colors.white),
                      decoration: _inputDecoration(
                        'البريد الإلكتروني',
                        Icons.email_rounded,
                      ),
                      onChanged: (_) {
                        // Clear warning when user manually edits email
                        if (warningMessage != null) {
                          setDialogState(() => warningMessage = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // ── Password ──────────────────────────────────────────
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: GoogleFonts.tajawal(color: Colors.white),
                      decoration: _inputDecoration(
                        'كلمة المرور',
                        Icons.lock_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Role ──────────────────────────────────────────────
                    _sectionLabel('الصلاحيات'),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor: AppColors.slate800,
                      style: GoogleFonts.tajawal(color: Colors.white),
                      isExpanded: true,
                      decoration: _inputDecoration(
                        'الدور',
                        Icons.shield_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('مدير النظام'),
                        ),
                        DropdownMenuItem(
                          value: 'data_entry',
                          child: Text('مدخل بيانات'),
                        ),
                        DropdownMenuItem(
                          value: 'finance',
                          child: Text('مالية'),
                        ),
                        DropdownMenuItem(
                          value: 'medical',
                          child: Text('وحدة طبية'),
                        ),
                        DropdownMenuItem(
                          value: 'inventory',
                          child: Text('مخزن'),
                        ),
                        DropdownMenuItem(
                          value: 'training',
                          child: Text('تدريب'),
                        ),
                        DropdownMenuItem(
                          value: 'operations',
                          child: Text('عمليات'),
                        ),
                        DropdownMenuItem(
                          value: 'dept_governor',
                          child: Text('حكمدار قسم'),
                        ),
                        DropdownMenuItem(
                          value: 'group_governor',
                          child: Text('حكمدار مجموعة'),
                        ),
                        DropdownMenuItem(
                          value: 'intelligence',
                          child: Text('الاستخبارات'),
                        ),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedRole = val!;
                          selectedDepartmentId = null;
                          selectedGroupId = null;
                          dialogGroups = [];
                        });
                      },
                    ),

                    // ── Department (only for governors) ───────────────────
                    if (needsDept) ...[
                      const SizedBox(height: 16),
                      _sectionLabel('القسم'),
                      DropdownButtonFormField<int>(
                        value: selectedDepartmentId,
                        dropdownColor: AppColors.slate800,
                        style: GoogleFonts.tajawal(color: Colors.white),
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'اختر القسم',
                          Icons.account_tree_rounded,
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem<int>(
                            value: dept.id,
                            child: Text(
                              dept.name,
                              style: GoogleFonts.tajawal(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedDepartmentId = val;
                            selectedGroupId = null;
                            dialogGroups = [];
                          });
                          if (val != null && needsGroup) {
                            loadGroupsForDept(val);
                          }
                        },
                      ),
                    ],

                    // ── Group (only for group_governor) ───────────────────
                    if (needsGroup) ...[
                      const SizedBox(height: 16),
                      _sectionLabel('المجموعة'),
                      if (selectedDepartmentId == null)
                        _hintText('اختر القسم أولاً لعرض المجموعات')
                      else if (isLoadingGroups)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'جاري تحميل المجموعات...',
                                style: GoogleFonts.tajawal(
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (dialogGroups.isEmpty)
                        _hintText('لا توجد مجموعات في هذا القسم')
                      else
                        DropdownButtonFormField<int>(
                          value: selectedGroupId,
                          dropdownColor: AppColors.slate800,
                          style: GoogleFonts.tajawal(color: Colors.white),
                          isExpanded: true,
                          decoration: _inputDecoration(
                            'اختر المجموعة',
                            Icons.groups_rounded,
                          ),
                          items: dialogGroups.map((group) {
                            return DropdownMenuItem<int>(
                              value: group.id,
                              child: Text(
                                group.name,
                                style: GoogleFonts.tajawal(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() => selectedGroupId = val);
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.tajawal(color: Colors.white54),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text('إضافة', style: GoogleFonts.tajawal()),
                onPressed: () async {
                  // ── Validate ──────────────────────────────────────────
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'البريد الإلكتروني وكلمة المرور مطلوبان';
                    });
                    return;
                  }

                  if ((selectedRole == 'dept_governor' ||
                          selectedRole == 'group_governor') &&
                      selectedPersonnelId == null) {
                    setDialogState(() {
                      errorMessage =
                          'يجب ربط حساب الحكمدار بمستنفر من القائمة المستدلة';
                    });
                    return;
                  }

                  if (_isEmailTaken(email)) {
                    final alt = _generateAlternativeEmail(email);
                    setDialogState(() {
                      errorMessage = null;
                      warningMessage =
                          'البريد "$email" مستخدم. تم اقتراح: $alt';
                      emailController.text = alt;
                    });
                    return;
                  }

                  if (needsDept && selectedDepartmentId == null) {
                    setDialogState(() {
                      errorMessage = 'يجب اختيار القسم';
                    });
                    return;
                  }

                  if (needsGroup && selectedGroupId == null) {
                    setDialogState(() {
                      errorMessage = 'يجب اختيار المجموعة';
                    });
                    return;
                  }

                  final res = await _authService.registerUser(
                    email,
                    password,
                    selectedRole,
                    departmentId: selectedDepartmentId,
                    groupId: selectedGroupId,
                    personnelId: selectedPersonnelId,
                  );

                  if (res['success'] == true) {
                    Navigator.pop(context);
                    await _loadData(); // reload users + personnel
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تمت إضافة المستخدم بنجاح',
                            style: GoogleFonts.tajawal(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    setDialogState(() {
                      errorMessage = res['message'] ?? 'فشل إضافة المستخدم';
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  int _parseInt(dynamic val, [int fallback = 0]) => val == null
      ? fallback
      : (val is int ? val : int.tryParse(val.toString()) ?? fallback);

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.tajawal(color: Colors.white60),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: GoogleFonts.tajawal(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _hintText(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 13),
    ),
  );

  Widget _infoBanner(String text, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline_rounded, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.tajawal(color: color, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  String _getDepartmentName(int? deptId) {
    if (deptId == null) return 'غير محدد';
    final dept = _departments.firstWhere(
      (d) => d.id == deptId,
      orElse: () => Department(id: 0, name: 'غير معروف'),
    );
    return dept.name;
  }

  String _getPersonnelName(int? personnelId) {
    if (personnelId == null) return '';
    final matches = _allPersonnel
        .where((p) => _parseInt(p['id']) == personnelId)
        .toList();
    if (matches.isEmpty) return '#$personnelId';
    final p = matches.first;
    final name = _getPersonnelFullName(p, fallback: '');
    return name.isNotEmpty ? name : '#$personnelId';
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

    final combined = [
      p1,
      p2,
      p3,
      p4,
    ].where((e) => e.trim().isNotEmpty).join(' ');

    if (combined.isNotEmpty) return combined;
    return fallback;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(
        title: Text(
          'إدارة المستخدمين',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'تحديث',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
              child: Text(
                'لا يوجد مستخدمين',
                style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final role = user['role'] ?? '';
                final isDeptGovernor = role == 'dept_governor';
                final isGroupGovernor = role == 'group_governor';
                final personnelId = user['personnel_id'];

                final emailStr = user['email'] ?? '';
                final personnelNameStr = _getPersonnelName(
                  _parseInt(personnelId),
                );
                final displayTitle =
                    personnelNameStr.isNotEmpty &&
                        !personnelNameStr.startsWith('#')
                    ? personnelNameStr
                    : emailStr;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(role),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      displayTitle,
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (displayTitle != emailStr)
                          Text(
                            emailStr,
                            style: GoogleFonts.tajawal(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          _getRoleName(role),
                          style: GoogleFonts.tajawal(
                            color: _getRoleColor(role).withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        if (isDeptGovernor && user['department_id'] != null)
                          Text(
                            'القسم: ${_getDepartmentName(_parseInt(user['department_id']))}',
                            style: GoogleFonts.tajawal(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        if (isGroupGovernor && user['group_id'] != null)
                          Text(
                            'المجموعة: ${user['group_name'] ?? '#${user['group_id']}'}',
                            style: GoogleFonts.tajawal(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.slate800,
                            title: Text(
                              'تأكيد الحذف',
                              style: GoogleFonts.tajawal(color: Colors.white),
                            ),
                            content: Text(
                              'هل أنت متأكد من حذف هذا المستخدم؟',
                              style: GoogleFonts.tajawal(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  'إلغاء',
                                  style: GoogleFonts.tajawal(),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  'حذف',
                                  style: GoogleFonts.tajawal(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final res = await _authService.deleteUser(
                            _parseInt(user['id']),
                          );
                          if (res['success'] == true) {
                            _loadUsers();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم حذف المستخدم بنجاح',
                                    style: GoogleFonts.tajawal(),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Colors.white12),
                            if (personnelId != null)
                              _detailRow(
                                Icons.badge_rounded,
                                'مرتبط بمستنفر',
                                _getPersonnelName(_parseInt(personnelId)),
                                AppColors.primary,
                              ),
                            if (user['created_at'] != null)
                              _detailRow(
                                Icons.calendar_today_rounded,
                                'تاريخ الإنشاء',
                                _formatDate(user['created_at'].toString()),
                                Colors.white38,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded),
        label: Text('مستخدم جديد', style: GoogleFonts.tajawal()),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.tajawal(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.amber;
      case 'finance':
        return Colors.green;
      case 'medical':
        return Colors.blue;
      case 'inventory':
        return Colors.orange;
      case 'training':
        return Colors.indigo;
      case 'operations':
        return Colors.red;
      case 'dept_governor':
        return Colors.purple;
      case 'group_governor':
        return Colors.deepPurple;
      case 'intelligence':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'مدير النظام';
      case 'data_entry':
        return 'مدخل بيانات';
      case 'finance':
        return 'مالية';
      case 'medical':
        return 'الوحدة الطبية';
      case 'inventory':
        return 'المخزن';
      case 'training':
        return 'وحدة التدريب';
      case 'operations':
        return 'وحدة العمليات';
      case 'dept_governor':
        return 'حكمدار قسم';
      case 'group_governor':
        return 'حكمدار مجموعة';
      case 'intelligence':
        return 'الاستخبارات';
      default:
        return role;
    }
  }
}
