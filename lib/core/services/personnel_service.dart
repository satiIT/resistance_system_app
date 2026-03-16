import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PersonnelService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';
  // static const String baseUrl = 'http://192.168.1.100:5000/api'; // للشبكة المحلية

  // Headers مشتركة مع UTF-8
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json; charset=UTF-8', // ✅ إضافة charset هنا أيضاً
      'Accept-Charset': 'UTF-8', // ✅ إضافة هذا الحقل
    };
  }

  // 🔹 **دالة لمعالجة الاستجابة مع UTF-8**
  static dynamic _decodeResponse(http.Response response) {
    try {
      // ✅ **الإصلاح: استخدام UTF-8 بشكل صريح**
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      return decodedBody;
    } catch (e) {
      print('❌ خطأ في فك ترميز الاستجابة: $e');
      print('📄 النص الخام: ${response.body}');

      // محاولة بديلة باستخدام Latin-1 (قد يعمل مع بعض الحروف)
      try {
        return json.decode(latin1.decode(response.bodyBytes));
      } catch (e2) {
        print('❌ فشل فك الترميز بالبديل: $e2');

        // محاولة التحليل كسلسلة نصية مباشرة
        try {
          final responseBody = String.fromCharCodes(response.bodyBytes);
          return json.decode(responseBody);
        } catch (e3) {
          print('❌ فشل كامل في فك الترميز: $e3');
          throw Exception('تعذر معالجة استجابة الخادم (مشكلة ترميز): $e');
        }
      }
    }
  }

  // 🔹 جلب جميع المستنفرين - مع إصلاح الـ endpoint والتشفير
  static Future<List<dynamic>> getAllPersonnel() async {
    try {
      print('🌐 جاري الاتصال بـ: $baseUrl/personnel');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ✅ **استخدام الدالة المعدلة لفك الترميز**
        final decodedBody = _decodeResponse(response);

        if (decodedBody is List) {
          print('✅ تم جلب ${decodedBody.length} مستنفر');
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            final data = decodedBody['data'] as List;
            print('✅ تم جلب ${data.length} مستنفر من data');
            return data;
          } else if (decodedBody.containsKey('personnel') &&
              decodedBody['personnel'] is List) {
            final personnel = decodedBody['personnel'] as List;
            print('✅ تم جلب ${personnel.length} مستنفر من personnel');
            return personnel;
          } else if (decodedBody.containsKey('results') &&
              decodedBody['results'] is List) {
            final results = decodedBody['results'] as List;
            print('✅ تم جلب ${results.length} مستنفر من results');
            return results;
          } else {
            print('⚠️ الاستجابة لا تحتوي على قائمة');
            return [];
          }
        } else {
          throw Exception(
            'تنسيق الاستجابة غير معروف: ${decodedBody.runtimeType}',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint غير موجود (404). تأكد من عنوان الـ API');
      } else {
        // ✅ **استخدام utf8.decode لعرض الرسالة**
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في جلب البيانات: ${response.statusCode} - $errorMessage',
        );
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
        // ✅ **استخدام الدالة المعدلة**
        final decodedBody = _decodeResponse(response);

        if (decodedBody is Map) {
          if (decodedBody.containsKey('data')) {
            return Map<String, dynamic>.from(decodedBody['data'] as Map);
          } else {
            return Map<String, dynamic>.from(decodedBody);
          }
        } else {
          throw Exception(
            'تنسيق الاستجابة غير متوقع: ${decodedBody.runtimeType}',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('المستنفر غير موجود (404)');
      } else {
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في جلب بيانات المستنفر: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 إنشاء مستنفر جديد - مع إصلاح الـ endpoint
  static Future<Map<String, dynamic>> createPersonnel(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🌐 جاري إنشاء مستنفر جديد في: $baseUrl/personnel');

      // ✅ تطهير البيانات بشكل متقدم قبل الإرسال
      final sanitizedData = _sanitizeForApi(data);
      print('📦 البيانات المرسلة (بعد التطهير): ${json.encode(sanitizedData)}');

      // ✅ **استخدام utf8.encode لترميز الجسم**
      final body = utf8.encode(json.encode(sanitizedData));

      final response = await http.post(
        Uri.parse('$baseUrl/personnel'),
        headers: getHeaders(),
        body: body,
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decodedBody = _decodeResponse(response);

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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في إنشاء المستنفر: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 تحديث مستنفر - مع إصلاح الـ endpoint وتطهير البيانات
  static Future<Map<String, dynamic>> updatePersonnel(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      print('🌐 جاري تحديث مستنفر في: $baseUrl/personnel/$id');

      // ✅ تطهير البيانات بشكل متقدم (متعدد المستويات)
      final sanitizedData = _sanitizeForApi(data);
      final jsonBody = json.encode(sanitizedData);
      print('📦 البيانات المرسلة للتحديث (بعد التطهير): $jsonBody');

      // ✅ **استخدام utf8.encode**
      final body = utf8.encode(jsonBody);

      final response = await http.put(
        Uri.parse('$baseUrl/personnel/$id'),
        headers: getHeaders(),
        body: body,
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('📄 نص الاستجابة (خطأ): ${response.body}');
      }

      if (response.statusCode == 200) {
        final decodedBody = _decodeResponse(response);

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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في تحديث المستنفر: ${response.statusCode} - $errorMessage',
        );
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

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('المستنفر غير موجود (404)');
      } else {
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في حذف المستنفر: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 البحث في المستنفرين - مع إصلاح الـ endpoint
  static Future<List<dynamic>> searchPersonnel(String query) async {
    try {
      // ✅ **ترميز استعلام البحث**
      final encodedQuery = Uri.encodeComponent(query);
      print('🌐 جاري البحث في: $baseUrl/personnel/search?q=$encodedQuery');

      final response = await http.get(
        Uri.parse('$baseUrl/personnel/search?q=$encodedQuery'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = _decodeResponse(response);

        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else if (decodedBody.containsKey('results') &&
              decodedBody['results'] is List) {
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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception('فشل في البحث: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 التصفية حسب الولاية - مع إصلاح الـ endpoint
  static Future<List<dynamic>> getPersonnelByState(String state) async {
    try {
      // ✅ **ترميز اسم الولاية**
      final encodedState = Uri.encodeComponent(state);
      print(
        '🌐 جاري التصفية حسب الولاية: $baseUrl/personnel/state/$encodedState',
      );

      final response = await http.get(
        Uri.parse('$baseUrl/personnel/state/$encodedState'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = _decodeResponse(response);

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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في جلب البيانات حسب الولاية: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔹 التصفية حسب المحلية - مع إصلاح الـ endpoint
  static Future<List<dynamic>> getPersonnelByLocality(String locality) async {
    try {
      // ✅ **ترميز اسم المحلية**
      final encodedLocality = Uri.encodeComponent(locality);
      print(
        '🌐 جاري التصفية حسب المحلية: $baseUrl/personnel/locality/$encodedLocality',
      );

      final response = await http.get(
        Uri.parse('$baseUrl/personnel/locality/$encodedLocality'),
        headers: getHeaders(),
      );

      print('📡 حالة الاستجابة: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = _decodeResponse(response);

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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في جلب البيانات حسب المحلية: ${response.statusCode} - $errorMessage',
        );
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
        final decodedBody = _decodeResponse(response);

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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في جلب الإحصائيات الجغرافية: ${response.statusCode} - $errorMessage',
        );
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
        final decodedBody = _decodeResponse(response);

        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else if (decodedBody.containsKey('states') &&
              decodedBody['states'] is List) {
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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في جلب قائمة الولايات: ${response.statusCode} - $errorMessage',
        );
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
        final decodedBody = _decodeResponse(response);

        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
            return decodedBody['data'] as List;
          } else if (decodedBody.containsKey('localities') &&
              decodedBody['localities'] is List) {
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
        final errorMessage = utf8.decode(response.bodyBytes);
        throw Exception(
          'فشل في جلب قائمة المحليات: ${response.statusCode} - $errorMessage',
        );
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

  // 🔹 دالة لاختبار الاتصال مع UTF-8
  static Future<bool> testConnection() async {
    try {
      print('🧪 اختبار الاتصال بـ: $baseUrl/personnel');
      final response = await http.get(
        Uri.parse('$baseUrl/personnel'),
        headers: getHeaders(),
      );

      print('📡 نتيجة اختبار الاتصال: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ✅ محاولة فك الترميز للتحقق من العملية
        try {
          _decodeResponse(response);
          print('✅ الاتصال ناجح وترميز UTF-8 يعمل');
        } catch (e) {
          print('⚠️ الاتصال ناجح ولكن هناك مشكلة في الترميز: $e');
        }
        return true;
      } else {
        final errorMessage = utf8.decode(response.bodyBytes);
        print('❌ فشل الاتصال: ${response.statusCode} - $errorMessage');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      return false;
    }
  }

  // 🔹 **دالة جديدة: اختبار ترميز النص العربي**
  static Future<void> testArabicEncoding() async {
    try {
      print('🧪 اختبار ترميز النص العربي...');

      // اختبار مع نص عربي
      final testResponse = await http.get(
        Uri.parse('$baseUrl/personnel'),
        headers: getHeaders(),
      );

      if (testResponse.statusCode == 200) {
        final rawBytes = testResponse.bodyBytes;
        final utf8String = utf8.decode(rawBytes);
        final latin1String = latin1.decode(rawBytes);

        print('📊 نتائج اختبار الترميز:');
        print('   طول البيانات (بايت): ${rawBytes.length}');
        print(
          '   الترميز UTF-8 ناجح: ${utf8String.contains('عربي') || utf8String.contains('مستنفر')}',
        );
        print(
          '   الترميز Latin-1 ناجح: ${latin1String.contains('عربي') || latin1String.contains('مستنفر')}',
        );

        // عرض عينة من النص
        if (utf8String.length > 100) {
          print('   عينة من النص (UTF-8): ${utf8String.substring(0, 100)}...');
        }
      }
    } catch (e) {}
  }

  // 🔹 دالة لتطهير البيانات من القيم الفارغة التي تسبب مشاكل في الـ Boolean والأنواع الأخرى
  static dynamic _sanitizeForApi(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final Map<String, dynamic> result = {};
      data.forEach((key, value) {
        if (value == null) {
          result[key] = null;
        } else if (value is String) {
          final trimmed = value.trim();

          // 1. معالجة السلاسل الفارغة -> null (ضروري للـ Booleans والتاريخ في DB)
          if (trimmed.isEmpty ||
              trimmed.toLowerCase() == 'null' ||
              trimmed == 'undefined') {
            result[key] = null;
          }
          // 2. معالجة القيم المنطقية الصريحة كمصطلحات
          else if (trimmed.toLowerCase() == 'true') {
            result[key] = true;
          } else if (trimmed.toLowerCase() == 'false') {
            result[key] = false;
          }
          // 3. معالجة حالات خاصة لبعض قواعد البيانات (0/1 للـ Boolean)
          else if (key.startsWith('is_')) {
            if (trimmed == '1') {
              result[key] = true;
            } else if (trimmed == '0') {
              result[key] = false;
            } else {
              result[key] = trimmed;
            }
          }
          // 4. محاولة تحويل الأرقام للحقول المعروفة أنها رقمية
          else {
            final numValue = num.tryParse(trimmed);
            if (numValue != null &&
                (key.contains('count') ||
                    key.contains('id') ||
                    key.contains('number') ||
                    key.contains('age'))) {
              result[key] = numValue;
            } else {
              result[key] = trimmed;
            }
          }
        } else if (value is Map || value is List) {
          result[key] = _sanitizeForApi(value);
        } else {
          // قيم أخرى (bool, int, double صريحة)
          result[key] = value;
        }
      });
      return result;
    } else if (data is List) {
      return data.map((item) => _sanitizeForApi(item)).toList();
    }
    return data;
  }
}
