// lib/core/services/personnel_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonnelService {
  // 🔹 استخدام عنوان IP بدلاً من localhost للجوال
  //static const String baseUrl = 'http://10.0.2.2:5000/api'; // للاندرويد
   static const String baseUrl = 'http://localhost:5000/api'; // للويب
  // static const String baseUrl = 'http://192.168.1.100:5000/api'; // للشبكة المحلية

  // Headers مشتركة
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // 🔹 جلب جميع المستنفرين - مع إصلاح الـ endpoint
  static Future<List<dynamic>> getAllPersonnel() async {
    try {
      print('🌐 جاري الاتصال بـ: $baseUrl/personnel');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is List) {
          print('✅ تم جلب ${decodedBody.length} مستنفر');
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            final data = decodedBody['data'] as List;
            print('✅ تم جلب ${data.length} مستنفر من data');
            return data;
          } else if (decodedBody.containsKey('personnel') && decodedBody['personnel'] is List) {
            final personnel = decodedBody['personnel'] as List;
            print('✅ تم جلب ${personnel.length} مستنفر من personnel');
            return personnel;
          } else if (decodedBody.containsKey('results') && decodedBody['results'] is List) {
            final results = decodedBody['results'] as List;
            print('✅ تم جلب ${results.length} مستنفر من results');
            return results;
          } else {
            print('⚠️ الاستجابة لا تحتوي على قائمة');
            return [];
          }
        } else {
          throw Exception('تنسيق الاستجابة غير معروف: ${decodedBody.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint غير موجود (404). تأكد من عنوان الـ API');
      } else {
        throw Exception('فشل في جلب البيانات: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 جلب مستنفر بواسطة ID - مع إصلاح الـ endpoint
  static Future<Map<String, dynamic>> getPersonnelById(String id) async {
    try {
      print('🌐 جاري الاتصال بـ: $baseUrl/personnel/$id');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel/$id'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is Map) {
          if (decodedBody.containsKey('data')) {
            return Map<String, dynamic>.from(decodedBody['data'] as Map);
          } else {
            return Map<String, dynamic>.from(decodedBody);
          }
        } else {
          throw Exception('تنسيق الاستجابة غير متوقع: ${decodedBody.runtimeType}');
        }
      } else if (response.statusCode == 404) {
        throw Exception('المستنفر غير موجود (404)');
      } else {
        throw Exception('فشل في جلب بيانات المستنفر: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 إنشاء مستنفر جديد - مع إصلاح الـ endpoint
  static Future<Map<String, dynamic>> createPersonnel(Map<String, dynamic> data) async {
    try {
      print('🌐 جاري إنشاء مستنفر جديد في: $baseUrl/personnel');
      final response = await http.post(
        Uri.parse('$baseUrl/personnel'),
        headers: getHeaders(),
        body: json.encode(data),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is Map) {
          if (decodedBody.containsKey('data')) {
            return Map<String, dynamic>.from(decodedBody['data'] as Map);
          } else {
            return Map<String, dynamic>.from(decodedBody);
          }
        } else {
          return {'success': true, 'message': 'تم الإنشاء بنجاح'};
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint غير موجود (404)');
      } else {
        throw Exception('فشل في إنشاء المستنفر: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 تحديث مستنفر - مع إصلاح الـ endpoint
  static Future<Map<String, dynamic>> updatePersonnel(String id, Map<String, dynamic> data) async {
    try {
      print('🌐 جاري تحديث مستنفر في: $baseUrl/personnel/$id');
      final response = await http.put(
        Uri.parse('$baseUrl/personnel/$id'),
        headers: getHeaders(),
        body: json.encode(data),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is Map) {
          if (decodedBody.containsKey('data')) {
            return Map<String, dynamic>.from(decodedBody['data'] as Map);
          } else {
            return Map<String, dynamic>.from(decodedBody);
          }
        } else {
          return {'success': true, 'message': 'تم التحديث بنجاح'};
        }
      } else if (response.statusCode == 404) {
        throw Exception('المستنفر غير موجود (404)');
      } else {
        throw Exception('فشل في تحديث المستنفر: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 حذف مستنفر - مع إصلاح الـ endpoint
  static Future<bool> deletePersonnel(String id) async {
    try {
      print('🌐 جاري حذف مستنفر من: $baseUrl/personnel/$id');
      final response = await http.delete(
        Uri.parse('$baseUrl/personnel/$id'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 202) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('المستنفر غير موجود (404)');
      } else {
        throw Exception('فشل في حذف المستنفر: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 البحث في المستنفرين - مع إصلاح الـ endpoint
  static Future<List<dynamic>> searchPersonnel(String query) async {
    try {
      print('🌐 جاري البحث في: $baseUrl/personnel/search?q=$query');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel/search?q=$query'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else if (decodedBody.containsKey('results') && decodedBody['results'] is List) {
            return decodedBody['results'] as List;
          } else {
            return [];
          }
        } else {
          throw Exception('تنسيق استجابة البحث غير معروف');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint البحث غير موجود (404)');
      } else {
        throw Exception('فشل في البحث: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 التصفية حسب الولاية - مع إصلاح الـ endpoint
  static Future<List<dynamic>> getPersonnelByState(String state) async {
    try {
      print('🌐 جاري التصفية حسب الولاية: $baseUrl/personnel/state/$state');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel/state/$state'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else {
            return [];
          }
        } else {
          throw Exception('تنسيق استجابة التصفية غير معروف');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint التصفية غير موجود (404)');
      } else {
        throw Exception('فشل في جلب البيانات حسب الولاية: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 التصفية حسب المحلية - مع إصلاح الـ endpoint
  static Future<List<dynamic>> getPersonnelByLocality(String locality) async {
    try {
      print('🌐 جاري التصفية حسب المحلية: $baseUrl/personnel/locality/$locality');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel/locality/$locality'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else {
            return [];
          }
        } else {
          throw Exception('تنسيق استجابة التصفية غير معروف');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint التصفية غير موجود (404)');
      } else {
        throw Exception('فشل في جلب البيانات حسب المحلية: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 الإحصائيات الجغرافية - مع إصلاح الـ endpoint
  static Future<Map<String, dynamic>> getGeographicalStats() async {
    try {
      print('🌐 جاري جلب الإحصائيات: $baseUrl/personnel/stats/geographical');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel/stats/geographical'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is Map) {
          if (decodedBody.containsKey('data')) {
            return Map<String, dynamic>.from(decodedBody['data'] as Map);
          } else {
            return Map<String, dynamic>.from(decodedBody);
          }
        } else {
          throw Exception('تنسيق الإحصائيات غير متوقع');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint الإحصائيات غير موجود (404)');
      } else {
        throw Exception('فشل في جلب الإحصائيات الجغرافية: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 جلب الولايات - مع إصلاح الـ endpoint
  static Future<List<dynamic>> getStates() async {
    try {
      print('🌐 جاري جلب الولايات: $baseUrl/locations/states');
      final response = await http.get(
        Uri.parse('$baseUrl/locations/states'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else if (decodedBody.containsKey('states') && decodedBody['states'] is List) {
            return decodedBody['states'] as List;
          } else {
            return [];
          }
        } else {
          throw Exception('تنسيق استجابة الولايات غير معروف');
        }
      } else if (response.statusCode == 404) {
        print('⚠️ استخدام الولايات الافتراضية بسبب 404');
        return _getDefaultStates();
      } else {
        throw Exception('فشل في جلب قائمة الولايات: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      print('⚠️ استخدام الولايات الافتراضية بسبب الخطأ');
      return _getDefaultStates();
    }
  }

  // 🔹 جلب المحليات - مع إصلاح الـ endpoint
  static Future<List<dynamic>> getLocalities() async {
    try {
      print('🌐 جاري جلب المحليات: $baseUrl/locations/localities');
      final response = await http.get(
        Uri.parse('$baseUrl/locations/localities'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        
        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else if (decodedBody.containsKey('localities') && decodedBody['localities'] is List) {
            return decodedBody['localities'] as List;
          } else {
            return [];
          }
        } else {
          throw Exception('تنسيق استجابة المحليات غير معروف');
        }
      } else if (response.statusCode == 404) {
        print('⚠️ استخدام المحليات الافتراضية بسبب 404');
        return _getDefaultLocalities();
      } else {
        throw Exception('فشل في جلب قائمة المحليات: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      print('⚠️ استخدام المحليات الافتراضية بسبب الخطأ');
      return _getDefaultLocalities();
    }
  }

  // 🔹 بيانات افتراضية للولايات
  static List<Map<String, dynamic>> _getDefaultStates() {
    return [
      {'state_name': 'ولاية الخرطوم', 'state_code': 'KH'},
      {'state_name': 'ولاية الجزيرة', 'state_code': 'GZ'},
      {'state_name': 'ولاية البحر الأحمر', 'state_code': 'RS'},
      {'state_name': 'ولاية كسلا', 'state_code': 'KA'},
      {'state_name': 'ولاية القضارف', 'state_code': 'GD'},
      {'state_name': 'ولاية سنار', 'state_code': 'SI'},
      {'state_name': 'ولاية النيل الأزرق', 'state_code': 'NB'},
      {'state_name': 'ولاية النيل الأبيض', 'state_code': 'NW'},
      {'state_name': 'ولاية شمال كردفان', 'state_code': 'NK'},
      {'state_name': 'ولاية جنوب كردفان', 'state_code': 'SK'},
      {'state_name': 'ولاية غرب كردفان', 'state_code': 'WK'},
      {'state_name': 'ولاية شمال دارفور', 'state_code': 'ND'},
      {'state_name': 'ولاية جنوب دارفور', 'state_code': 'SD'},
      {'state_name': 'ولاية غرب دارفور', 'state_code': 'WD'},
      {'state_name': 'ولاية شرق دارفور', 'state_code': 'ED'},
      {'state_name': 'ولاية وسط دارفور', 'state_code': 'CD'},
    ];
  }

  // 🔹 بيانات افتراضية للمحليات
  static List<Map<String, dynamic>> _getDefaultLocalities() {
    return [
      {'locality_name': 'محلية الخرطوم', 'state_code': 'KH'},
      {'locality_name': 'محلية شرق النيل', 'state_code': 'KH'},
      {'locality_name': 'محلية أم درمان', 'state_code': 'KH'},
      {'locality_name': 'محلية بحري', 'state_code': 'KH'},
      {'locality_name': 'محلية الجزيرة', 'state_code': 'GZ'},
      {'locality_name': 'محلية الحصاحيصا', 'state_code': 'GZ'},
      {'locality_name': 'محلية الكاملين', 'state_code': 'GZ'},
    ];
  }

  // 🔹 دالة لاختبار الاتصال
  static Future<bool> testConnection() async {
    try {
      print('🧪 اختبار الاتصال بـ: $baseUrl/personnel');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel'),
        headers: getHeaders(),
      );

      print('📡 نتيجة اختبار الاتصال: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ الاتصال ناجح');
        return true;
      } else {
        print('❌ فشل الاتصال: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      return false;
    }
  }
}