// lib/core/services/reports_api.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ReportsApi {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';

  // Headers مشتركة
  static Map<String, String> getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // === دوال التقارير الأساسية ===

  static Future<Map<String, dynamic>> getPersonnelReport(
    int personnelId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-reports/personnel/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل تقرير المستنفر',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل تقرير المستنفر - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getPerformanceReport(
    int personnelId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-reports/performance/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل تقرير الأداء',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل تقرير الأداء - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getTrainingReport(int personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-reports/training/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل تقرير التدريب',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل تقرير التدريب - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getAttendanceReport(
    int personnelId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-reports/attendance/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل تقرير الحضور',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل تقرير الحضور - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getFinancialReport(
    int personnelId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-reports/financial/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل التقرير المالي',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل التقرير المالي - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<Map<String, dynamic>> getEquipmentReport(
    int personnelId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-reports/equipment/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل تقرير المعدات',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل تقرير المعدات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال الإحصائيات ===

  static Future<Map<String, dynamic>> getPersonnelStats(int personnelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personnel-reports/stats/$personnelId'),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل إحصائيات المستنفر',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل إحصائيات المستنفر - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال التصدير ===

  static Future<String> generatePdfReport(
    int personnelId,
    String reportType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-reports/export/pdf'),
        headers: getHeaders(),
        body: json.encode({
          'personnel_id': personnelId,
          'report_type': reportType,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']['file_url'] ?? '';
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في إنشاء التقرير PDF',
          );
        }
      } else {
        throw Exception(
          'فشل في إنشاء التقرير PDF - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  static Future<String> generateCsvReport(
    int personnelId,
    String reportType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personnel-reports/export/csv'),
        headers: getHeaders(),
        body: json.encode({
          'personnel_id': personnelId,
          'report_type': reportType,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']['file_url'] ?? '';
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في إنشاء التقرير CSV',
          );
        }
      } else {
        throw Exception(
          'فشل في إنشاء التقرير CSV - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // === دوال المساعدة ===

  static String formatCurrency(dynamic amount) {
    if (amount == null) return '0 جنيه';
    final num = double.tryParse(amount.toString()) ?? 0;
    return '${num.toStringAsFixed(0)} جنيه';
  }

  static String formatDate(String? date) {
    if (date == null) return '--';
    return date;
  }

  static String formatPercentage(dynamic value) {
    if (value == null) return '0%';
    final num = double.tryParse(value.toString()) ?? 0;
    return '${num.toStringAsFixed(1)}%';
  }

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'متميز':
      case 'ممتاز':
      case 'excellent':
        return Colors.green;
      case 'جيد':
      case 'good':
        return Colors.blue;
      case 'متوسط':
      case 'average':
        return Colors.orange;
      case 'ضعيف':
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
