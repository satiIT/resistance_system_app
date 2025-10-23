// lib/core/services/personnel_movements_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PersonnelMovementsService {
  static final PersonnelMovementsService _instance = PersonnelMovementsService._internal();
  factory PersonnelMovementsService() => _instance;
  PersonnelMovementsService._internal();

  final String _baseUrl = ApiConfig.baseUrl;

  // Get all personnel movements
  Future<Map<String, dynamic>> getAllMovements() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/personnel-movements'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في جلب البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get movement by ID
  Future<Map<String, dynamic>> getMovementById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/personnel-movements/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في جلب الحركة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Create new movement
  Future<Map<String, dynamic>> createMovement(Map<String, dynamic> movementData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/personnel-movements'),
        headers: ApiConfig.headers,
        body: json.encode(movementData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء الحركة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Update movement
  Future<Map<String, dynamic>> updateMovement(String id, Map<String, dynamic> movementData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/personnel-movements/$id'),
        headers: ApiConfig.headers,
        body: json.encode(movementData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في تحديث الحركة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Delete movement
  Future<Map<String, dynamic>> deleteMovement(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/personnel-movements/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في حذف الحركة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get movements by personnel ID
  Future<Map<String, dynamic>> getMovementsByPersonnelId(String personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/personnel-movements/personnel/$personnelId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في جلب حركات المستنفر: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Create bulk assignment
  Future<Map<String, dynamic>> createBulkAssignment(List<Map<String, dynamic>> assignments) async {
    try {
      List<Future<Map<String, dynamic>>> futures = [];
      
      for (var assignment in assignments) {
        futures.add(createMovement(assignment));
      }
      
      final results = await Future.wait(futures);
      
      return {
        'success': true,
        'message': 'تم إسناد المهمة بنجاح إلى ${assignments.length} مستنفر',
        'data': results,
      };
    } catch (e) {
      throw Exception('فشل في الإسناد الجماعي: $e');
    }
  }

  // Create complete movement
  Future<Map<String, dynamic>> createCompleteMovement(Map<String, dynamic> completeData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/personnel-movements/complete'),
        headers: ApiConfig.headers,
        body: json.encode(completeData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء الحركة الكاملة');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Create distribution
  Future<Map<String, dynamic>> createDistribution(Map<String, dynamic> distributionData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/personnel-movements/distributions'),
        headers: ApiConfig.headers,
        body: json.encode(distributionData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء التوزيع');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get distributions by personnel ID
  Future<Map<String, dynamic>> getDistributionsByPersonnelId(String personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/personnel-movements/distributions/$personnelId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في جلب التوزيعات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}