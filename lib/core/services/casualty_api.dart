import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/casualty.dart';

class CasualtyApi {
  static const String baseUrl = 'http://localhost:5000/api';

  // الحصول على جميع السجلات
  static Future<List<Casualty>> getCasualties() async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-casualties'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Casualty.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات الشهداء والجرحى');
      }
    } else {
      throw Exception('فشل في تحميل البيانات - رمز الخطأ: ${response.statusCode}');
    }
  }

  // الحصول على سجل محدد
  static Future<Casualty> getCasualty(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-casualties/$id'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return Casualty.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل السجل');
      }
    } else {
      throw Exception('فشل في تحميل السجل - رمز الخطأ: ${response.statusCode}');
    }
  }

  // إنشاء سجل جديد
  static Future<Casualty> createCasualty(Casualty casualty) async {
    final response = await http.post(
      Uri.parse('$baseUrl/personnel-casualties'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(casualty.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return Casualty.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في إنشاء السجل');
      }
    } else {
      throw Exception('فشل في إنشاء السجل - رمز الخطأ: ${response.statusCode}');
    }
  }

  // تحديث سجل
  static Future<Casualty> updateCasualty(Casualty casualty) async {
    final response = await http.put(
      Uri.parse('$baseUrl/personnel-casualties/${casualty.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(casualty.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return Casualty.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحديث السجل');
      }
    } else {
      throw Exception('فشل في تحديث السجل - رمز الخطأ: ${response.statusCode}');
    }
  }

  // حذف سجل
  static Future<void> deleteCasualty(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/personnel-casualties/$id'));

    if (response.statusCode != 200) {
      throw Exception('فشل في حذف السجل - رمز الخطأ: ${response.statusCode}');
    }
  }

  // الحصول على إحصائيات
  static Future<Map<String, dynamic>> getCasualtyStats() async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-casualties/stats'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return responseData['data'];
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل الإحصائيات');
      }
    } else {
      throw Exception('فشل في تحميل الإحصائيات - رمز الخطأ: ${response.statusCode}');
    }
  }

  // البحث في السجلات
  static Future<List<Casualty>> searchCasualties(String term) async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-casualties/search/$term'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Casualty.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'فشل في البحث');
      }
    } else {
      throw Exception('فشل في البحث - رمز الخطأ: ${response.statusCode}');
    }
  }
}