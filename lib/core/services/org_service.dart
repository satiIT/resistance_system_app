import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/organization.dart';

class OrgService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/org';

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
  }

  // Departments
  static Future<List<Department>> getDepartments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/departments'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'] as List;
      return data.map((json) => Department.fromJson(json)).toList();
    }
    throw Exception('فشل في تحميل الأقسام');
  }

  static Future<void> updateDeptGovernor(int deptId, int governorId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/departments/$deptId/governor'),
      headers: headers,
      body: json.encode({'governor_id': governorId}),
    );
    if (response.statusCode != 200)
      throw Exception('فشل في تحديث حكمدار القسم');
  }

  // Groups
  static Future<List<OrgGroup>> getAllGroups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'] as List;
      return data.map((json) => OrgGroup.fromJson(json)).toList();
    }
    throw Exception('فشل في تحميل المجموعات');
  }

  static Future<List<OrgGroup>> getGroupsByDept(int deptId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/departments/$deptId/groups'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'] as List;
      return data.map((json) => OrgGroup.fromJson(json)).toList();
    }
    throw Exception('فشل في تحميل المجموعات');
  }

  static Future<OrgGroup> createGroup(
    int deptId,
    String name,
    int? governorId,
  ) async {
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
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      return OrgGroup.fromJson(data);
    }
    throw Exception('فشل في إنشاء المجموعة');
  }

  static Future<List<dynamic>> getGroupPersonnel(int groupId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/personnel'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes))['data'] as List;
    }
    throw Exception('فشل في تحميل أفراد المجموعة');
  }

  static Future<void> addPersonnelToGroup(int personnelId, int groupId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/$groupId/personnel'),
      headers: headers,
      body: json.encode({'personnel_id': personnelId}),
    );
    if (response.statusCode != 200)
      throw Exception('فشل في إضافة الفرد للمجموعة');
  }

  static Future<void> removePersonnelFromGroup(int personnelId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/personnel/$personnelId/group'),
      headers: headers,
    );
    if (response.statusCode != 200)
      throw Exception('فشل في إزالة الفرد من المجموعة');
  }

  static Future<List<dynamic>> getAvailablePersonnel() async {
    final response = await http.get(
      Uri.parse('$baseUrl/personnel/available'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes))['data'] as List;
    }
    throw Exception('فشل في تحميل الأفراد المتاحين');
  }

  // Reports
  static Future<List<OrgReport>> getReports(
    int userId,
    String role,
    int? personnelId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/reports?userId=$userId&role=$role&personnelId=${personnelId ?? ""}',
      ),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'] as List;
      return data.map((json) => OrgReport.fromJson(json)).toList();
    }
    throw Exception('فشل في تحميل التقارير');
  }

  static Future<void> createReport(
    String type,
    int targetId,
    String note,
    int createdBy,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: headers,
      body: json.encode({
        'report_type': type,
        'target_id': targetId,
        'note': note,
        'created_by': createdBy,
      }),
    );
    if (response.statusCode != 201) throw Exception('فشل في إضافة التقرير');
  }
}
