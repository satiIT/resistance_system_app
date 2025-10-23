import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/training_record.dart';
import '../models/training_course.dart';

class TrainingApi {
  static const String baseUrl = 'http://localhost:5000/api';

  // === دوال سجلات التدريب ===

static Future<List<TrainingRecord>> getTrainingRecords() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/personnel-training'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        
        // Debug: Print raw data structure
        print('=== DEBUG: Raw API Response ===');
        if (data.isNotEmpty) {
          print('First record keys: ${data.first.keys}');
          print('First record values: $data');
        }
        
        // تنظيف البيانات قبل تحويلها
        final List<Map<String, dynamic>> cleanedData = [];
        
        for (var item in data) {
          try {
            final cleanedItem = _cleanTrainingRecordData(item);
            cleanedData.add(cleanedItem);
          } catch (e) {
            print('Error cleaning record $item: $e');
            // Skip invalid records
            continue;
          }
        }
        
        print('Successfully cleaned ${cleanedData.length} out of ${data.length} records');
        return cleanedData.map((json) => TrainingRecord.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل بيانات التدريب');
      }
    } else {
      throw Exception('فشل في تحميل بيانات التدريب - رمز الخطأ: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getTrainingRecords: $e');
    throw e;
  }
}

// دالة محسنة لتنظيف بيانات سجل التدريب
static Map<String, dynamic> _cleanTrainingRecordData(Map<String, dynamic> data) {
  // Handle all possible integer fields
  final cleanedData = {
    'id': _cleanInt(data['id']),
    'personnel_id': _cleanInt(data['personnel_id']),
    'course_id': _cleanInt(data['course_id']),
    'evaluation_score': _cleanInt(data['evaluation_score']),
    
    // Handle string fields
    'personnel_name': _cleanString(data['personnel_name']),
    'military_number': _cleanString(data['military_number']),
    'course_name': _cleanString(data['course_name']),
    'prior_training_type': _cleanString(data['prior_training_type']),
    'attendance_status': _cleanString(data['attendance_status']),
    'training_camp_name': _cleanString(data['training_camp_name']),
    'firing_location': _cleanString(data['firing_location']),
    'weapon_type': _cleanString(data['weapon_type']),
    'specialized_course_type': _cleanString(data['specialized_course_type']),
    'weapon_training_type': _cleanString(data['weapon_training_type']),
    'notes': _cleanString(data['notes']),
    
    // Handle boolean fields
    'certificate_received': _cleanBool(data['certificate_received']),
  };
  
  // Remove null values to avoid conflicts
  cleanedData.removeWhere((key, value) => value == null);
  
  return cleanedData;
}

// دالة محسنة لتنظيف الأرقام
static int? _cleanInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    if (value.isEmpty || 
        value.toLowerCase() == 'null' || 
        value.toLowerCase() == 'undefined') {
      return null;
    }
    return int.tryParse(value);
  }
  if (value is double) return value.toInt();
  return null;
}

// دالة محسنة لتنظيف النصوص
static String? _cleanString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    if (value.isEmpty || 
        value.toLowerCase() == 'null' || 
        value.toLowerCase() == 'undefined') {
      return null;
    }
    return value;
  }
  return value.toString();
}

// دالة لتنظيف القيم المنطقية
static bool? _cleanBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  return null;
}  static Future<TrainingRecord> getTrainingRecord(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-training/$id'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return TrainingRecord.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل سجل التدريب');
      }
    } else if (response.statusCode == 404) {
      throw Exception('سجل التدريب غير موجود');
    } else {
      throw Exception('فشل في تحميل سجل التدريب - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<TrainingRecord> createTrainingRecord(TrainingRecord record) async {
    final response = await http.post(
      Uri.parse('$baseUrl/personnel-training'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return TrainingRecord.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في إنشاء سجل التدريب');
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'فشل في إنشاء سجل التدريب - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<TrainingRecord> updateTrainingRecord(TrainingRecord record) async {
    final response = await http.put(
      Uri.parse('$baseUrl/personnel-training/${record.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return TrainingRecord.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحديث سجل التدريب');
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'فشل في تحديث سجل التدريب - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<void> deleteTrainingRecord(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/personnel-training/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'فشل في حذف سجل التدريب');
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'فشل في حذف سجل التدريب - رمز الخطأ: ${response.statusCode}');
    }
  }

  // === دوال المستنفرين ===

  static Future<List<Map<String, dynamic>>> getPersonnelList() async {
    final response = await http.get(Uri.parse('$baseUrl/personnel'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((person) => {
          'id': person['id'],
          'name': '${person['first_name']} ${person['second_name']} ${person['third_name']} ${person['fourth_name']}',
          'military_number': person['military_id'].toString(),
          'rank': person['rank'],
          'unit': person['unit'],
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

  // === دوال إضافية للتدريب ===

  static Future<List<TrainingRecord>> getTrainingByPersonnelId(int personnelId) async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-training/personnel/$personnelId'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => TrainingRecord.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل سجلات التدريب للمستنفر');
      }
    } else {
      throw Exception('فشل في تحميل سجلات التدريب للمستنفر - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getTrainingStats() async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-training/stats/summary'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return responseData['data'];
      } else {
        throw Exception(responseData['message'] ?? 'فشل في تحميل إحصائيات التدريب');
      }
    } else {
      throw Exception('فشل في تحميل إحصائيات التدريب - رمز الخطأ: ${response.statusCode}');
    }
  }

  static Future<List<TrainingRecord>> searchTraining(String term) async {
    final response = await http.get(Uri.parse('$baseUrl/personnel-training/search/$term'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) => TrainingRecord.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'فشل في البحث');
      }
    } else {
      throw Exception('فشل في البحث - رمز الخطأ: ${response.statusCode}');
    }
  }

  // === دوال الدورات التدريبية (إذا كانت موجودة في المستقبل) ===

  static Future<List<TrainingCourse>> getTrainingCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/training-courses'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => TrainingCourse.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'فشل في تحميل الدورات التدريبية');
        }
      } else {
        throw Exception('فشل في تحميل الدورات التدريبية - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('الدورات التدريبية غير متاحة حالياً');
    }
  }

  static Future<TrainingCourse> createTrainingCourse(TrainingCourse course) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/training-courses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(course.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return TrainingCourse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء الدورة التدريبية');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في إنشاء الدورة التدريبية - رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('لا يمكن إنشاء الدورة التدريبية حالياً');
    }
  }
  static Future<List<dynamic>> getInstructors() async {
  final response = await http.get(Uri.parse('$baseUrl/instructors'));
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      return responseData['data'];
    } else {
      throw Exception(responseData['message'] ?? 'فشل في تحميل المدربين');
    }
  } else {
    throw Exception('فشل في تحميل المدربين - رمز الخطأ: ${response.statusCode}');
  }
}

static Future<dynamic> createInstructor(Map<String, dynamic> instructorData) async {
  final response = await http.post(
    Uri.parse('$baseUrl/instructors'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(instructorData),
  );

  if (response.statusCode == 201) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      return responseData['data'];
    } else {
      throw Exception(responseData['message'] ?? 'فشل في إنشاء المدرب');
    }
  } else {
    throw Exception('فشل في إنشاء المدرب - رمز الخطأ: ${response.statusCode}');
  }
}

static Future<void> deleteInstructor(int instructorId) async {
  final response = await http.delete(Uri.parse('$baseUrl/instructors/$instructorId'));

  if (response.statusCode != 200) {
    final Map<String, dynamic> errorData = json.decode(response.body);
    throw Exception(errorData['message'] ?? 'فشل في حذف المدرب');
  }
}
// دوال تحديث المدربين والدورات
static Future<dynamic> updateInstructor(int id, Map<String, dynamic> instructorData) async {
  final response = await http.put(
    Uri.parse('$baseUrl/instructors/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(instructorData),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      return responseData['data'];
    } else {
      throw Exception(responseData['message'] ?? 'فشل في تحديث المدرب');
    }
  } else {
    throw Exception('فشل في تحديث المدرب - رمز الخطأ: ${response.statusCode}');
  }
}

static Future<TrainingCourse> updateTrainingCourse(TrainingCourse course) async {
  final response = await http.put(
    Uri.parse('$baseUrl/training-courses/${course.id}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(course.toJson()),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      return TrainingCourse.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'فشل في تحديث الدورة');
    }
  } else {
    throw Exception('فشل في تحديث الدورة - رمز الخطأ: ${response.statusCode}');
  }
}
// دوال الدورات التدريبية
static Future<List<TrainingCourse>> fetchTrainingCourses() async {
  final response = await http.get(Uri.parse('$baseUrl/training-courses'));
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      final List<dynamic> data = responseData['data'];
      return data.map((json) => TrainingCourse.fromJson(json)).toList();
    } else {
      throw Exception(responseData['message'] ?? 'فشل في تحميل الدورات');
    }
  } else {
    throw Exception('فشل في تحميل الدورات - رمز الخطأ: ${response.statusCode}');
  }
}

static Future<TrainingCourse> createNewTrainingCourse(TrainingCourse course) async {
  final response = await http.post(
    Uri.parse('$baseUrl/training-courses'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(course.toJson()),
  );

  if (response.statusCode == 201) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      return TrainingCourse.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'فشل في إنشاء الدورة');
    }
  } else {
    throw Exception('فشل في إنشاء الدورة - رمز الخطأ: ${response.statusCode}');
  }
}

static Future<void> deleteTrainingCourse(int courseId) async {
  final response = await http.delete(Uri.parse('$baseUrl/training-courses/$courseId'));

  if (response.statusCode != 200) {
    final Map<String, dynamic> errorData = json.decode(response.body);
    throw Exception(errorData['message'] ?? 'فشل في حذف الدورة');
  }
}

// دوال تسجيل المتدربين في الدورات
static Future<TrainingRecord> enrollTraineeInCourse(int courseId, int personnelId, Map<String, dynamic> trainingData) async {
  final response = await http.post(
    Uri.parse('$baseUrl/training-courses/$courseId/enroll'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'personnel_id': personnelId,
      ...trainingData
    }),
  );

  if (response.statusCode == 201) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      return TrainingRecord.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'فشل في تسجيل المتدرب');
    }
  } else {
    throw Exception('فشل في تسجيل المتدرب - رمز الخطأ: ${response.statusCode}');
  }
}

static Future<List<TrainingRecord>> getCourseTrainees(int courseId) async {
  final response = await http.get(Uri.parse('$baseUrl/training-courses/$courseId/participants'));
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      final List<dynamic> data = responseData['data'];
      return data.map((json) => TrainingRecord.fromJson(json)).toList();
    } else {
      throw Exception(responseData['message'] ?? 'فشل في تحميل المتدربين');
    }
  } else {
    throw Exception('فشل في تحميل المتدربين - رمز الخطأ: ${response.statusCode}');
  }
}
static Future<void> debugTrainingRecords() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/personnel-training'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print('=== DEBUG: API Response ===');
      print('Success: ${responseData['success']}');
      print('Message: ${responseData['message']}');
      
      if (responseData['success'] == true) {
        final List<dynamic> data = responseData['data'];
        print('Number of records: ${data.length}');
        
        if (data.isNotEmpty) {
          print('First record structure:');
          for (var key in data.first.keys) {
            print('  $key: ${data.first[key]} (type: ${data.first[key]?.runtimeType})');
          }
          
          // Check for null values
          print('\nRecords with null values:');
          for (int i = 0; i < data.length; i++) {
            var record = data[i];
            var nullFields = record.keys.where((key) => record[key] == null).toList();
            if (nullFields.isNotEmpty) {
              print('Record $i has null fields: $nullFields');
            }
          }
        }
      }
    } else {
      print('API Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Debug Error: $e');
  }
}

}
// Safe API wrapper with enhanced error handling
class SafeTrainingApi {
  static Future<List<TrainingRecord>> getTrainingRecordsSafe() async {
    try {
      print('🔍 Starting safe training records load...');
      
      final response = await TrainingApi.getTrainingRecords();
      
      // Validate each record
      final validRecords = <TrainingRecord>[];
      int errorCount = 0;
      
      for (var record in response) {
        try {
          // Validate critical fields
          if (record.id == null) {
            print('⚠️ Warning: Record with null ID found, skipping');
            errorCount++;
            continue;
          }
          
          if (record.personnelId == null) {
            print('⚠️ Warning: Record ${record.id} has null personnelId');
            // We'll still include it but log the issue
          }
          
          validRecords.add(record);
          
        } catch (e) {
          print('❌ Error validating record: $e');
          errorCount++;
        }
      }
      
      print('✅ Safe load completed: ${validRecords.length} valid, $errorCount errors');
      
      if (validRecords.isEmpty && response.isNotEmpty) {
        throw Exception('لا توجد سجلات صالحة للعرض');
      }
      
      return validRecords;
      
    } catch (e) {
      print('💥 Critical error in safe API: $e');
      rethrow;
    }
  }
}