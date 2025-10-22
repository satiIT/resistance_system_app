import 'dart:convert';
import 'package:http/http.dart' as http;

class DebugPersonnelService {
  static const String baseUrl = 'http://your-api-base-url/api';
  
  static void printDebug(String message, {dynamic data}) {
    print('🐛 DEBUG: $message');
    if (data != null) {
      print('📊 البيانات: $data');
      print('📦 نوع البيانات: ${data.runtimeType}');
    }
  }

  // 🔹 دالة مساعدة لمعالجة الاستجابة
  static dynamic handleResponse(http.Response response) {
    printDebug('الاستجابة من السيرفر', data: {
      'statusCode': response.statusCode,
      'body': response.body,
      'headers': response.headers
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedBody = json.decode(response.body);
      printDebug('الجسم المفكوك', data: decodedBody);
      
      return decodedBody;
    } else {
      throw Exception('❌ خطأ في الاستجابة: ${response.statusCode} - ${response.body}');
    }
  }

  // 🔹 جلب جميع المستنفرين مع تصحيح متقدم
  static Future<List<dynamic>> getAllPersonnel() async {
    try {
      printDebug('بدء جلب جميع المستنفرين');
      
      final response = await http.get(
        Uri.parse('$baseUrl/personnel'),
        headers: {'Content-Type': 'application/json'},
      );

      final result = handleResponse(response);
      
      // ✅ تحليل مختلف أشكال الاستجابة
      if (result is List) {
        printDebug('✅ الاستجابة هي List مباشرة', data: result.length);
        return result;
      } 
      else if (result is Map<String, dynamic>) {
        printDebug('📋 الاستجابة هي Map', data: result.keys);
        
        // البحث عن المفتاح الذي يحتوي على القائمة
        final possibleKeys = ['data', 'personnel', 'results', 'items', 'users'];
        
        for (var key in possibleKeys) {
          if (result.containsKey(key) && result[key] is List) {
            printDebug('✅ تم العثور على القائمة في المفتاح: $key', data: result[key].length);
            return result[key];
          }
        }
        
        // إذا لم نجد قائمة، نرجع قائمة فارغة مع تحذير
        printDebug('⚠️ لم يتم العثور على قائمة في الاستجابة');
        return [];
      }
      else {
        printDebug('🚨 تنسيق استجابة غير معروف', data: result.runtimeType);
        throw Exception('تنسيق استجابة غير معروف: ${result.runtimeType}');
      }
    } catch (e) {
      printDebug('🚨 خطأ كامل في getAllPersonnel', data: e);
      throw Exception('فشل في جلب البيانات: $e');
    }
  }

  // 🔹 دالة اختبار الاتصال
  static Future<void> testConnection() async {
    try {
      printDebug('بدء اختبار الاتصال');
      
      final response = await http.get(
        Uri.parse('$baseUrl/personnel'),
        headers: {'Content-Type': 'application/json'},
      );

      printDebug('نتيجة اختبار الاتصال', data: {
        'statusCode': response.statusCode,
        'body': response.body,
        'contentType': response.headers['content-type']
      });

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        printDebug('هيكل الاستجابة', data: {
          'type': decoded.runtimeType,
          'keys': decoded is Map ? decoded.keys.toList() : 'Not a Map',
          'length': decoded is List ? decoded.length : 'Not a List'
        });
      }
    } catch (e) {
      printDebug('🚨 فشل اختبار الاتصال', data: e);
    }
  }
}