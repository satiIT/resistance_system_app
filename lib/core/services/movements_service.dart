// lib/core/services/movements_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MovementsService {
  // استخدام نفس إعدادات الـ Service الموجود
  static const String baseUrl = 'http://localhost:5000/api';

  // Headers مشتركة
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // 🔹 جلب جميع التحركات - مطابق لـ API الخاص بك
  static Future<Map<String, dynamic>> getAllMovements() async {
    try {
      print('🌐 جاري الاتصال بـ: $baseUrl/personnel-movements');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        print('✅ تم جلب ${decodedBody['data']?.length ?? 0} حركة');
        return decodedBody;
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint التحركات غير موجود (404)');
      } else {
        throw Exception('فشل في جلب التحركات: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 جلب حركة بواسطة ID
  static Future<Map<String, dynamic>> getMovementById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('الحركة غير موجودة (404)');
      } else {
        throw Exception('فشل في جلب الحركة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 إنشاء حركة جديدة - مطابق لـ API الخاص بك
  static Future<Map<String, dynamic>> createMovement(Map<String, dynamic> movementData) async {
    try {
      print('🌐 جاري إنشاء حركة جديدة في: $baseUrl/personnel-movements');
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-movements'),
        headers: getHeaders(),
        body: json.encode(movementData),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        print('✅ تم إنشاء الحركة بنجاح');
        return decodedBody;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء الحركة: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 تحديث حركة
  static Future<Map<String, dynamic>> updateMovement(String id, Map<String, dynamic> movementData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/personnel-movements/$id'),
        headers: getHeaders(),
        body: json.encode(movementData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في تحديث الحركة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 حذف حركة
  static Future<Map<String, dynamic>> deleteMovement(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/personnel-movements/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في حذف الحركة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 جلب حركات مستنفر معين
  static Future<Map<String, dynamic>> getMovementsByPersonnelId(String personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements/personnel/$personnelId'),
        headers: getHeaders(),
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

  // 🔹 إنشاء حركة كاملة
  static Future<Map<String, dynamic>> createCompleteMovement(Map<String, dynamic> completeData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-movements/complete'),
        headers: getHeaders(),
        body: json.encode(completeData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء الحركة الكاملة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 إنشاء توزيع
  static Future<Map<String, dynamic>> createDistribution(Map<String, dynamic> distributionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-movements/distributions'),
        headers: getHeaders(),
        body: json.encode(distributionData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء التوزيع: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 جلب توزيعات مستنفر معين
  static Future<Map<String, dynamic>> getDistributionsByPersonnelId(String personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements/distributions/$personnelId'),
        headers: getHeaders(),
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

  // 🔹 إنشاء إسناد جماعي
  static Future<List<Map<String, dynamic>>> createBulkAssignments(List<Map<String, dynamic>> assignments) async {
    try {
      List<Future<Map<String, dynamic>>> futures = [];
      
      for (var assignment in assignments) {
        futures.add(createMovement(assignment));
      }
      
      final results = await Future.wait(futures);
      return results;
    } catch (e) {
      throw Exception('فشل في الإسناد الجماعي: $e');
    }
  }
}