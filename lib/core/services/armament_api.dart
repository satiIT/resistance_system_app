// lib/core/services/armament_api.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArmamentApi {
  static const String baseUrl = 'http://localhost:5000/api';

  // Headers مشتركة
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // === دوال التسليح الأساسية ===

  static Future<List<dynamic>> getPersonnelArmament() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-armament'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات التسليح');
        }
      } else {
        throw Exception('فشل في تحميل بيانات التسليح - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getArmamentById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-armament/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات التسليح');
        }
      } else if (response.statusCode == 404) {
        throw Exception('سجل التسليح غير موجود');
      } else {
        throw Exception('فشل في تحميل بيانات التسليح - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> getArmamentByPersonnelId(int personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-armament/personnel/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل تسليح المستنفر');
        }
      } else {
        throw Exception('فشل في تحميل تسليح المستنفر - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> createArmament(Map<String, dynamic> armamentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-armament'),
        headers: getHeaders(),
        body: json.encode(armamentData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء سجل التسليح');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء سجل التسليح - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> updateArmament(int id, Map<String, dynamic> armamentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/personnel-armament/$id'),
        headers: getHeaders(),
        body: json.encode(armamentData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحديث سجل التسليح');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في تحديث سجل التسليح - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<void> deleteArmament(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/personnel-armament/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] != true) {
          throw Exception(responseData['message'] ?? 'فشل في حذف سجل التسليح');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في حذف سجل التسليح - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال الإحصائيات ===

  static Future<Map<String, dynamic>> getArmamentStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-armament/stats/summary'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل إحصائيات التسليح');
        }
      } else {
        throw Exception('فشل في تحميل إحصائيات التسليح - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال المساعدة ===

  static String getWeaponTypeDisplay(String? type) {
    switch (type?.toLowerCase()) {
      case 'assault_rifle':
      case 'بندقية هجومية':
        return 'بندقية هجومية';
      case 'pistol':
      case 'مسدس':
        return 'مسدس';
      case 'sniper_rifle':
      case 'بندقية قنص':
        return 'بندقية قنص';
      case 'machine_gun':
      case 'رشاش':
        return 'رشاش';
      case 'grenade':
      case 'قنبلة':
        return 'قنبلة';
      case 'protective_vest':
      case 'سترة واقية':
        return 'سترة واقية';
      case 'helmet':
      case 'خوذة':
        return 'خوذة';
      case 'ammunition':
      case 'ذخيرة':
        return 'ذخيرة';
      default:
        return type ?? 'سلاح';
    }
  }

  static String getEquipmentCondition(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'good':
      case 'جيدة':
        return 'جيدة';
      case 'fair':
      case 'متوسطة':
        return 'متوسطة';
      case 'poor':
      case 'سيئة':
        return 'سيئة';
      case 'under_maintenance':
      case 'تحت الصيانة':
        return 'تحت الصيانة';
      default:
        return condition ?? 'جيدة';
    }
  }

  static Color getConditionColor(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'good':
      case 'جيدة':
        return Colors.green;
      case 'fair':
      case 'متوسطة':
        return Colors.orange;
      case 'poor':
      case 'سيئة':
      case 'under_maintenance':
      case 'تحت الصيانة':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Icon getEquipmentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'assault_rifle':
      case 'بندقية هجومية':
      case 'pistol':
      case 'مسدس':
      case 'sniper_rifle':
      case 'بندقية قنص':
      case 'machine_gun':
      case 'رشاش':
        return Icon(Icons.security, color: Colors.red);
      case 'protective_vest':
      case 'سترة واقية':
      case 'helmet':
      case 'خوذة':
        return Icon(Icons.shield, color: Colors.orange);
      case 'grenade':
      case 'قنبلة':
      case 'ammunition':
      case 'ذخيرة':
        return Icon(Icons.bolt, color: Colors.yellow[700]);
      default:
        return Icon(Icons.inventory, color: Colors.blue);
    }
  }
}