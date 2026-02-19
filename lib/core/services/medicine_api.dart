// core/services/medicine_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine_item.dart';

class MedicineApi {
  static const String baseUrl = 'http://localhost:5000/api/medicine';

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
    };
  }

  // جلب جميع حركات الأدوية
  static Future<List<MedicineItem>> getMedicineItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movements'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => MedicineItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل بيانات الأدوية',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل البيانات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في getMedicineItems: $e');
      rethrow;
    }
  }

  // إنشاء حركة دواء جديدة
  static Future<MedicineItem> createMedicineItem(MedicineItem item) async {
    try {
      final jsonData = item.toJson();
      final response = await http.post(
        Uri.parse('$baseUrl/movements'),
        headers: headers,
        body: utf8.encode(json.encode(jsonData)),
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          return MedicineItem.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في إنشاء حركة الدواء',
          );
        }
      } else {
        final errorData = json.decode(decodedBody);
        throw Exception(
          errorData['message'] ??
              'فشل في إنشاء الحركة - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في createMedicineItem: $e');
      rethrow;
    }
  }

  // تحديث حركة دواء
  static Future<MedicineItem> updateMedicineItem(MedicineItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/movements/${item.id}'),
        headers: headers,
        body: utf8.encode(json.encode(item.toJson())),
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          return MedicineItem.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحديث حركة الدواء',
          );
        }
      } else {
        final errorData = json.decode(decodedBody);
        throw Exception(
          errorData['message'] ??
              'فشل في التحديث - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في updateMedicineItem: $e');
      rethrow;
    }
  }

  // حذف حركة دواء
  static Future<void> deleteMedicineItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/movements/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final errorData = json.decode(decodedBody);
        throw Exception(
          errorData['message'] ??
              'فشل في الحذف - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في deleteMedicineItem: $e');
      rethrow;
    }
  }

  // جلب إحصائيات الأدوية
  static Future<Map<String, dynamic>> getMedicineStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل الإحصائيات');
        }
      } else {
        throw Exception(
          'فشل في تحميل الإحصائيات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في getMedicineStats: $e');
      rethrow;
    }
  }

  // جلب الأدوية المنتهية الصلاحية
  static Future<List<MedicineItem>> getExpiringMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data']['expired'];
          return data.map((json) => MedicineItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل الأدوية المنتهية',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل الأدوية المنتهية - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في getExpiringMedicines: $e');
      rethrow;
    }
  }

  // جلب الأدوية قريبة الانتهاء
  static Future<List<MedicineItem>> getNearExpiryMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data']['near_expiry'];
          return data.map((json) => MedicineItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل الأدوية قريبة الانتهاء',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل الأدوية قريبة الانتهاء - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في getNearExpiryMedicines: $e');
      rethrow;
    }
  }
}
