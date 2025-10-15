import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/casualty.dart';
import '../models/martyr_compensation.dart';

class CasualtyApi {
  static const String baseUrl = 'http://localhost:5000/api';

  // === دوال الشهداء والجرحى ===

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

  static Future<void> deleteCasualty(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/personnel-casualties/$id'));

    if (response.statusCode != 200) {
      throw Exception('فشل في حذف السجل - رمز الخطأ: ${response.statusCode}');
    }
  }

  // === دوال تعويضات الشهداء ===

  static Future<List<MartyrCompensation>> getMartyrCompensations() async {
    final response = await http.get(Uri.parse('$baseUrl/martyr-compensation'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => MartyrCompensation.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل تعويضات الشهداء');
      }
    } else {
      throw Exception('فشل في تحميل تعويضات الشهداء - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<MartyrCompensation> getMartyrCompensation(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/martyr-compensation/$id'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return MartyrCompensation.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل تعويض الشهيد');
      }
    } else {
      throw Exception('فشل في تحميل تعويض الشهيد - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<MartyrCompensation> createMartyrCompensation(MartyrCompensation compensation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/martyr-compensation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(compensation.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return MartyrCompensation.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في إنشاء تعويض الشهيد');
      }
    } else {
      throw Exception('فشل في إنشاء تعويض الشهيد - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<MartyrCompensation> updateMartyrCompensation(MartyrCompensation compensation) async {
    final response = await http.put(
      Uri.parse('$baseUrl/martyr-compensation/${compensation.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(compensation.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return MartyrCompensation.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحديث تعويض الشهيد');
      }
    } else {
      throw Exception('فشل في تحديث تعويض الشهيد - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<void> deleteMartyrCompensation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/martyr-compensation/$id'));

    if (response.statusCode != 200) {
      throw Exception('فشل في حذف تعويض الشهيد - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<MartyrCompensation?> getCompensationByCasualtyId(int casualtyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/martyr-compensation/casualty/$casualtyId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return MartyrCompensation.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // === دوال إضافية ===

  static Future<List<Map<String, dynamic>>> getPersonnelList() async {
    final response = await http.get(Uri.parse('$baseUrl/personnel'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((person) => {
          'id': person['id'],
          'military_number': person['military_id']?.toString() ?? '',
          'full_name': '${person['first_name']} ${person['second_name']} ${person['third_name']} ${person['fourth_name']}',
          'rank': person['rank'],
          'unit': person['unit'],
          'next_of_kin_name': person['next_of_kin_name'],
          'next_of_kin_phone': person['next_of_kin_phone'],
          'next_of_kin_address': person['next_of_kin_address'],
        }).toList();
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل قائمة المستنفرين');
      }
    } else {
      throw Exception('فشل في تحميل قائمة المستنفرين - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getPersonnelById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/personnel/$id'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return responseData['data'];
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات المستنفر');
      }
    } else {
      throw Exception('فشل في تحميل بيانات المستنفر - رمز الخطأ: ${response.statusCode}');
    }
  }

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

  static Future<bool> checkDuplicateRecord(int personnelId, String formType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/personnel-casualties/check-duplicate/$personnelId/$formType')
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['exists'] ?? false;
    } else {
      throw Exception('فشل في التحقق من التكرار - رمز الخطأ: ${response.statusCode}');
    }
  }
}