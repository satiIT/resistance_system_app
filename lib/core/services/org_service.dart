import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/organization.dart';
import 'auth_service.dart';

class OrgService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/org';

  static Future<Map<String, String>> getHeaders() async {
    final authService = AuthService();
    final token = await authService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Departments
  static Future<List<Department>> getDepartments() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/departments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          final List<dynamic> deptsList = data['data'] ?? [];
          return deptsList.map((json) => Department.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting departments: $e');
      return [];
    }
  }

  static Future<void> updateDeptGovernor(int deptId, int governorId) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/departments/$deptId/governor'),
      headers: headers,
      body: json.encode({'governor_id': governorId}),
    );
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'فشل في تحديث حكمدار القسم');
    }
  }

  // Groups
  static Future<List<OrgGroup>> getAllGroups() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/groups'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          final List<dynamic> groupsList = data['data'] ?? [];
          return groupsList.map((json) => OrgGroup.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting groups: $e');
      return [];
    }
  }

  static Future<List<OrgGroup>> getGroupsByDept(int deptId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/departments/$deptId/groups'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          final List<dynamic> groupsList = data['data'] ?? [];
          return groupsList.map((json) => OrgGroup.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting groups by dept: $e');
      return [];
    }
  }

  static Future<OrgGroup?> createGroup(
    int deptId,
    String name,
    int? governorId,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/groups'),
        headers: headers,
        body: json.encode({
          'dept_id': deptId,
          'name': name,
          'governor_id': governorId,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return OrgGroup.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getGroupPersonnel(int groupId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/groups/$groupId/personnel'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error getting group personnel: $e');
      return [];
    }
  }

  static Future<bool> addPersonnelToGroup(int personnelId, int groupId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/groups/$groupId/personnel'),
        headers: headers,
        body: json.encode({'personnel_id': personnelId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error adding personnel to group: $e');
      return false;
    }
  }

  static Future<bool> removePersonnelFromGroup(int personnelId) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/personnel/$personnelId/group'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error removing personnel from group: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getAvailablePersonnel() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/personnel/available'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error getting available personnel: $e');
      return [];
    }
  }

  // Reports - Updated with date filter
  static Future<List<OrgReport>> getReports({
    required int userId,
    required String role,
    int? personnelId,
    String? reportType,
    int? departmentId,
    int? groupId,
    int? targetPersonnelId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await getHeaders();

      // Build query parameters
      Map<String, String> queryParams = {
        'userId': userId.toString(),
        'role': role,
      };

      if (personnelId != null)
        queryParams['personnelId'] = personnelId.toString();
      if (reportType != null && reportType != 'all')
        queryParams['reportType'] = reportType;
      if (departmentId != null)
        queryParams['departmentId'] = departmentId.toString();
      if (groupId != null) queryParams['groupId'] = groupId.toString();
      if (targetPersonnelId != null)
        queryParams['targetPersonnelId'] = targetPersonnelId.toString();
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse(
        '$baseUrl/reports',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          final List<dynamic> reportsList = data['data'] ?? [];
          return reportsList.map((json) => OrgReport.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting reports: $e');
      return [];
    }
  }

  static Future<bool> createReport(
    String type,
    int? targetId,
    String note,
    int createdBy, {
    DateTime? reportDate,
  }) async {
    try {
      final headers = await getHeaders();

      Map<String, dynamic> body = {
        'report_type': type,
        'target_id': targetId,
        'note': note,
        'created_by': createdBy,
      };

      if (reportDate != null) {
        body['report_date'] = reportDate.toIso8601String();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error creating report: $e');
      return false;
    }
  }

  // Get filtered reports by date range
  static Future<List<OrgReport>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? userId,
    String? role,
  }) async {
    try {
      final headers = await getHeaders();

      Map<String, String> queryParams = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (userId != null) queryParams['userId'] = userId.toString();
      if (role != null) queryParams['role'] = role;

      final uri = Uri.parse(
        '$baseUrl/reports/by-date-range',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true) {
          final List<dynamic> reportsList = data['data'] ?? [];
          return reportsList.map((json) => OrgReport.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting reports by date range: $e');
      return [];
    }
  }
}
