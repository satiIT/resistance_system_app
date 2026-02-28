// core/services/financial_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/financial_item.dart';

class FinancialApi {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/finance';

  // === قسم الوارد ===

  // جلب جميع سجلات الوارد
  static Future<List<FinancialItem>> getIncomingFunds() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incoming'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => FinancialItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل بيانات الوارد',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل البيانات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في getIncomingFunds: $e');
      rethrow;
    }
  }

  // إنشاء سجل وارد جديد
  static Future<FinancialItem> createIncomingFund(FinancialItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incoming'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return FinancialItem.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء سجل الوارد');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'فشل في إنشاء السجل - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في createIncomingFund: $e');
      rethrow;
    }
  }

  // تحديث سجل وارد
  static Future<FinancialItem> updateIncomingFund(FinancialItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/incoming/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return FinancialItem.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحديث سجل الوارد');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'فشل في التحديث - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في updateIncomingFund: $e');
      rethrow;
    }
  }

  // حذف سجل وارد
  static Future<void> deleteIncomingFund(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/incoming/$id'));

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'فشل في الحذف - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في deleteIncomingFund: $e');
      rethrow;
    }
  }

  // === قسم المنصرف ===

  // جلب جميع سجلات المنصرف
  static Future<List<FinancialItem>> getOutgoingFunds() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/outgoing'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => FinancialItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل بيانات المنصرف',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل البيانات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في getOutgoingFunds: $e');
      rethrow;
    }
  }

  // إنشاء سجل منصرف جديد
  static Future<FinancialItem> createOutgoingFund(FinancialItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/outgoing'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return FinancialItem.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في إنشاء سجل المنصرف',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'فشل في إنشاء السجل - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في createOutgoingFund: $e');
      rethrow;
    }
  }

  // تحديث سجل منصرف
  static Future<FinancialItem> updateOutgoingFund(FinancialItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/outgoing/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return FinancialItem.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحديث سجل المنصرف',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'فشل في التحديث - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في updateOutgoingFund: $e');
      rethrow;
    }
  }

  // حذف سجل منصرف
  static Future<void> deleteOutgoingFund(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/outgoing/$id'));

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'فشل في الحذف - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في deleteOutgoingFund: $e');
      rethrow;
    }
  }

  // === الإحصائيات والتقارير ===

  // جلب الإحصائيات المالية
  static Future<Map<String, dynamic>> getFinancialStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
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
      print('خطأ في getFinancialStats: $e');
      rethrow;
    }
  }

  // جلب أعلى المصروفات
  static Future<List<FinancialItem>> getTopExpenses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/top/expenses'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => FinancialItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل أعلى المصروفات',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل أعلى المصروفات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في getTopExpenses: $e');
      rethrow;
    }
  }

  // جلب أكبر الواردات
  static Future<List<FinancialItem>> getTopIncoming() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/top/incoming'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => FinancialItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل أكبر الواردات',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل أكبر الواردات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في getTopIncoming: $e');
      rethrow;
    }
  }
}
