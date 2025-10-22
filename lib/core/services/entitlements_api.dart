// lib/core/services/entitlements_api.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EntitlementsApi {
  static const String baseUrl = 'http://localhost:5000/api';

  // Headers مشتركة
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // === دوال الاستحقاقات الأساسية ===

  static Future<List<dynamic>> getPersonnelEntitlements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-entitlements'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات الاستحقاقات');
        }
      } else {
        throw Exception('فشل في تحميل بيانات الاستحقاقات - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getEntitlementById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-entitlements/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات الاستحقاق');
        }
      } else if (response.statusCode == 404) {
        throw Exception('الاستحقاق غير موجود');
      } else {
        throw Exception('فشل في تحميل بيانات الاستحقاق - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> getEntitlementsByPersonnelId(int personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-entitlements/personnel/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل استحقاقات المستنفر');
        }
      } else {
        throw Exception('فشل في تحميل استحقاقات المستنفر - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> createEntitlement(Map<String, dynamic> entitlementData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-entitlements'),
        headers: getHeaders(),
        body: json.encode(entitlementData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء الاستحقاق');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء الاستحقاق - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> updateEntitlement(int id, Map<String, dynamic> entitlementData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/personnel-entitlements/$id'),
        headers: getHeaders(),
        body: json.encode(entitlementData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحديث الاستحقاق');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في تحديث الاستحقاق - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<void> deleteEntitlement(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/personnel-entitlements/$id'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] != true) {
          throw Exception(responseData['message'] ?? 'فشل في حذف الاستحقاق');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في حذف الاستحقاق - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال متقدمة ===

  static Future<List<dynamic>> getEntitlementsByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-entitlements/type/$type'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل الاستحقاقات حسب النوع');
        }
      } else {
        throw Exception('فشل في تحميل الاستحقاقات حسب النوع - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> calculateAutomaticEntitlements(int personnelId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-entitlements/calculate/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في حساب الاستحقاقات التلقائية');
        }
      } else {
        throw Exception('فشل في حساب الاستحقاقات التلقائية - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getEntitlementsStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-entitlements/stats/summary'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل إحصائيات الاستحقاقات');
        }
      } else {
        throw Exception('فشل في تحميل إحصائيات الاستحقاقات - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<List<dynamic>> searchEntitlements(Map<String, dynamic> filters) async {
    try {
      final queryParams = filters.entries.map((e) => '${e.key}=${e.value}').join('&');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-entitlements/search/advanced?$queryParams'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'فشل في البحث في الاستحقاقات');
        }
      } else {
        throw Exception('فشل في البحث في الاستحقاقات - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال المساعدة ===

  static String getEntitlementTypeDisplay(String? type) {
    switch (type?.toLowerCase()) {
      case 'war_share':
      case 'سهم حربي':
        return 'سهم حربي';
      case 'basic_salary':
      case 'خلافة أساسية':
        return 'خلافة أساسية';
      case 'transportation':
      case 'بدل انتقال':
        return 'بدل انتقال';
      case 'housing':
      case 'بدل سكن':
        return 'بدل سكن';
      case 'performance':
      case 'مكافأة أداء':
        return 'مكافأة أداء';
      case 'mujahid_basket':
      case 'سلة مجاهد':
        return 'سلة مجاهد';
      default:
        return type ?? 'استحقاق';
    }
  }

  static String getPaymentStatusDisplay(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'مستلم':
      case 'مدفوع':
        return 'مستلم';
      case 'pending':
      case 'معلق':
        return 'معلق';
      case 'cancelled':
      case 'ملغى':
        return 'ملغى';
      case 'processing':
      case 'قيد المعالجة':
        return 'قيد المعالجة';
      default:
        return status ?? 'معلق';
    }
  }

  static Color getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'مستلم':
      case 'مدفوع':
        return Colors.green;
      case 'pending':
      case 'معلق':
        return Colors.orange;
      case 'cancelled':
      case 'ملغى':
        return Colors.red;
      case 'processing':
      case 'قيد المعالجة':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static String formatCurrency(dynamic amount) {
    if (amount == null) return '0 جنيه';
    final num = double.tryParse(amount.toString()) ?? 0;
    return '${num.toStringAsFixed(0)} جنيه';
  }

  static String formatDate(String? date) {
    if (date == null) return '--';
    return date;
  }
}