// lib/presentation/pages/users_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _authService.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showAddUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'data_entry';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.slate800,
          title: Text(
            'إضافة مستخدم جديد',
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(emailController, 'البريد الإلكتروني', Icons.email),
                const SizedBox(height: 16),
                _buildField(
                  passwordController,
                  'كلمة المرور',
                  Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: AppColors.slate800,
                  style: GoogleFonts.tajawal(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'الدور',
                    labelStyle: GoogleFonts.tajawal(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'admin', child: Text('مدير')),
                    DropdownMenuItem(
                      value: 'data_entry',
                      child: Text('مدخل مستنفرين'),
                    ),
                    DropdownMenuItem(value: 'finance', child: Text('مالية')),
                    DropdownMenuItem(
                      value: 'medical',
                      child: Text('الوحدة الطبية'),
                    ),
                    DropdownMenuItem(value: 'inventory', child: Text('المخزن')),
                    DropdownMenuItem(
                      value: 'training',
                      child: Text('وحدة التدريب'),
                    ),
                    DropdownMenuItem(
                      value: 'operations',
                      child: Text('وحدة العمليات والتحركات'),
                    ),
                  ],
                  onChanged: (val) => setDialogState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty)
                  return;

                final res = await _authService.registerUser(
                  emailController.text,
                  passwordController.text,
                  selectedRole,
                );

                if (res['success'] == true) {
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تمت إضافة المستخدم بنجاح')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] ?? 'فشل الإضافة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('إضافة', style: GoogleFonts.tajawal()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
              child: Text(
                'لا يوجد مستخدمين',
                style: GoogleFonts.tajawal(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(user['role']),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      user['email'],
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _getRoleName(user['role']),
                      style: GoogleFonts.tajawal(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
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
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'حذف',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final res = await _authService.deleteUser(user['id']);
                          if (res['success'] == true) {
                            _loadUsers();
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
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
      default:
        return Colors.grey;
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'مدير';
      case 'data_entry':
        return 'مدخل مستنفرين';
      case 'finance':
        return 'مالية';
      case 'medical':
        return 'الوحدة الطبية';
      case 'inventory':
        return 'المخزن';
      case 'training':
        return 'وحدة التدريب';
      case 'operations':
        return 'وحدة العمليات والتحركات';
      default:
        return role;
    }
  }
}
