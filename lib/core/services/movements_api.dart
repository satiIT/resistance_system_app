// lib/core/services/movements_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MovementsApi {
  static const String baseUrl = 'http://localhost:5000/api';

  // Headers مشتركة
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // === دوال الحركات الأساسية ===

  static Future<List<dynamic>> getPersonnelMovements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات التحركات');
        }
      } else {
        throw Exception('فشل في تحميل بيانات التحركات - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getMovementById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات التحرك');
        }
      } else if (response.statusCode == 404) {
        throw Exception('التحرك غير موجود');
      } else {
        throw Exception('فشل في تحميل بيانات التحرك - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> createMovement(Map<String, dynamic> movementData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-movements'),
        headers: getHeaders(),
        body: json.encode(movementData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء التحرك');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء التحرك - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> updateMovement(int id, Map<String, dynamic> movementData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/personnel-movements/$id'),
        headers: getHeaders(),
        body: json.encode(movementData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحديث التحرك');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في تحديث التحرك - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<void> deleteMovement(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/personnel-movements/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] != true) {
          throw Exception(responseData['message'] ?? 'فشل في حذف التحرك');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في حذف التحرك - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال الحركات حسب المستنفر ===

  static Future<List<dynamic>> getMovementsByPersonnelId(int personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements/personnel/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل تحركات المستنفر');
        }
      } else {
        throw Exception('فشل في تحميل تحركات المستنفر - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال الحركات الكاملة (Form 3) ===

  static Future<List<dynamic>> getCompleteMovements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements-complete'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل الحركات الكاملة');
        }
      } else {
        throw Exception('فشل في تحميل الحركات الكاملة - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> getCompleteMovementsByPersonnelId(int personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements-complete/personnel/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل الحركات الكاملة للمستنفر');
        }
      } else {
        throw Exception('فشل في تحميل الحركات الكاملة للمستنفر - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> createCompleteMovement(Map<String, dynamic> movementData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-movements-complete'),
        headers: getHeaders(),
        body: json.encode(movementData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء الحركة الكاملة');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء الحركة الكاملة - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال التوزيعات ===

  static Future<List<dynamic>> getDistributionsByPersonnelId(int personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-movements/distributions/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل التوزيعات');
        }
      } else {
        throw Exception('فشل في تحميل التوزيعات - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> createDistribution(Map<String, dynamic> distributionData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-movements/distributions'),
        headers: getHeaders(),
        body: json.encode(distributionData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء التوزيع');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء التوزيع - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال أوامر الحركة ===

  static Future<List<dynamic>> getMovementOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movement-orders'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل أوامر الحركة');
        }
      } else {
        throw Exception('فشل في تحميل أوامر الحركة - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال الإحصائيات ===

  static Future<Map<String, dynamic>> getMovementsStats() async {
    try {
      final List<dynamic> movements = await getPersonnelMovements();
      
      final int totalMovements = movements.length;
      final int completed = movements.where((m) => m['status'] == 'منتهي' || m['status'] == 'مكتمل').length;
      final int inProgress = movements.where((m) => m['status'] == 'قيد التنفيذ' || m['status'] == 'نشط').length;
      final int transfers = movements.where((m) => m['movement_type'] == 'نقل').length;
      final int distributions = movements.where((m) => m['movement_type'] == 'توزيع').length;
      final int missions = movements.where((m) => m['movement_type'] == 'مهمة').length;

      return {
        'total_movements': totalMovements,
        'completed': completed,
        'in_progress': inProgress,
        'transfers': transfers,
        'distributions': distributions,
        'missions': missions,
      };
    } catch (e) {
      throw Exception('فشل في حساب الإحصائيات: $e');
    }
  }
}