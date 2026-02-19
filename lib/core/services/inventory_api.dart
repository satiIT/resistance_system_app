// services/inventory_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item.dart';

class InventoryApi {
  static const String baseUrl = 'http://localhost:5000/api/inventory';

  // إضافة headers للـ UTF-8
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
    };
  }

  // جلب جميع حركات المخزون
  static Future<List<InventoryItem>> getInventoryItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stock-movements'),
        headers: headers,
      );

      // فك الترميز باستخدام UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => InventoryItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل بيانات المخزون',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل البيانات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في getInventoryItems: $e');
      rethrow;
    }
  }

  // إنشاء حركة مخزون جديدة
  static Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    try {
      // تحويل البيانات إلى JSON
      final Map<String, dynamic> jsonData = item.toJson();

      // التأكد من أن item_id ليس null
      if (jsonData['item_id'] == null) {
        throw Exception('يجب اختيار الصنف');
      }

      print('📤 إرسال بيانات حركة المخزون: ${json.encode(jsonData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/stock-movements'),
        headers: headers,
        body: utf8.encode(json.encode(jsonData)), // استخدام UTF-8
      );

      // فك الترميز باستخدام UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);
      print('📥 استجابة الخادم: $decodedBody');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          return InventoryItem.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في إنشاء حركة المخزون',
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
      print('❌ خطأ في createInventoryItem: $e');
      rethrow;
    }
  }

  // تحديث حركة مخزون
  static Future<InventoryItem> updateInventoryItem(InventoryItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/stock-movements/${item.id}'),
        headers: headers,
        body: utf8.encode(json.encode(item.toJson())),
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          return InventoryItem.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحديث حركة المخزون',
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
      print('❌ خطأ في updateInventoryItem: $e');
      rethrow;
    }
  }

  // حذف حركة مخزون
  static Future<void> deleteInventoryItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/stock-movements/$id'),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'فشل في الحذف - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في deleteInventoryItem: $e');
      rethrow;
    }
  }

  // جلب المخزون المفصل (صنف + مخزن)
  static Future<List<Map<String, dynamic>>> getDetailedStock() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/detailed-stock'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في جلب تفاصيل المخزون',
          );
        }
      } else {
        throw Exception(
          'فشل في جلب البيانات - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في getDetailedStock: $e');
      rethrow;
    }
  }

  // جلب المخزون الحالي لمخزن معين
  static Future<List<Map<String, dynamic>>> getStoreStock(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/store-stock/$storeId'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل مخزون المخزن',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل المخزون - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ خطأ في getStoreStock: $e');
      rethrow;
    }
  }

  // جلب إحصائيات المخزون
  static Future<Map<String, dynamic>> getInventoryStats() async {
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
      print('خطأ في getInventoryStats: $e');
      rethrow;
    }
  }

  // جلب العناصر منخفضة المخزون
  static Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stock-alerts'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data']['low_stock'];
          return data.map((json) => InventoryItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل العناصر منخفضة المخزون',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل العناصر منخفضة المخزون - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في getLowStockItems: $e');
      rethrow;
    }
  }

  // جلب العناصر المنتهية الصلاحية
  static Future<List<InventoryItem>> getExpiringItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stock-alerts'),
        headers: headers,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(decodedBody);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data']['expired'];
          return data.map((json) => InventoryItem.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'فشل في تحميل العناصر المنتهية',
          );
        }
      } else {
        throw Exception(
          'فشل في تحميل العناصر المنتهية - رمز الخطأ: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('خطأ في getExpiringItems: $e');
      rethrow;
    }
  }
}
