import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
        headers: ApiConfig.headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        await _saveAuthData(data['token'], data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تسجيل الدخول',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال بالخادم'};
    }
  }

  // Register User (Admin Only) - Updated with department_id, group_id, personnel_id
  Future<Map<String, dynamic>> registerUser(
    String email,
    String password,
    String role, {
    int? departmentId,
    int? groupId,
    int? personnelId,
  }) async {
    try {
      final token = await getToken();

      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'role': role,
      };

      if (departmentId != null) body['department_id'] = departmentId;
      if (groupId != null) body['group_id'] = groupId;
      if (personnelId != null) body['personnel_id'] = personnelId;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'message': 'حدث خطأ أثناء إضافة المستخدم: $e'};
    }
  }

  // Get All Users (Admin Only)
  Future<List<dynamic>> getUsers() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/users'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] == true) {
        return data['users'] ?? [];
      }
      return [];
    } catch (e) {
      print('Get users error: $e');
      return [];
    }
  }

  // Delete User
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/users/$id'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ أثناء حذف المستخدم'};
    }
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/change-password'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ أثناء تغيير كلمة المرور'};
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove('intelligence_session_id');
  }

  // Intelligence Section Login
  Future<Map<String, dynamic>> intelLogin(String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/intelligence/auth'),
        headers: ApiConfig.headers,
        body: jsonEncode({'password': password}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('intelligence_session_id', data['session_id']);
        return {'success': true, 'session_id': data['session_id']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'كلمة المرور غير صحيحة',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال بقسم الاستخبارات',
      };
    }
  }

  // Helper Methods
  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get user role
  Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?['role'];
  }

  // Get user department id
  Future<int?> getUserDepartmentId() async {
    final user = await getCurrentUser();
    return user?['department_id'];
  }

  // Get user group id
  Future<int?> getUserGroupId() async {
    final user = await getCurrentUser();
    return user?['group_id'];
  }

  // Get user personnel id
  Future<int?> getUserPersonnelId() async {
    final user = await getCurrentUser();
    return user?['personnel_id'];
  }
}
