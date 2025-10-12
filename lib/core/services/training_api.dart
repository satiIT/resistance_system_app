// ignore_for_file: unused_import

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:universal_platform/universal_platform.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;
import './../models/training_record.dart';

class TrainingApi {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<TrainingRecord>> getTrainingRecords() async {
    final response = await http.get(Uri.parse('$baseUrl/training'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TrainingRecord.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل بيانات التدريب');
    }
  }

  static Future<TrainingRecord> createTrainingRecord(
    TrainingRecord record,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/training'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record.toJson()),
    );

    if (response.statusCode == 201) {
      return TrainingRecord.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في إنشاء سجل التدريب');
    }
  }

  static Future<TrainingRecord> updateTrainingRecord(
    TrainingRecord record,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/training/${record.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(record.toJson()),
    );

    if (response.statusCode == 200) {
      return TrainingRecord.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في تحديث سجل التدريب');
    }
  }

  static Future<void> deleteTrainingRecord(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/training/$id'));

    if (response.statusCode != 200) {
      throw Exception('فشل في حذف سجل التدريب');
    }
  }

  static Future<List<Map<String, dynamic>>> getPersonnelList() async {
    // محاكاة لجلب قائمة المستنفرين - في التطبيق الفعلي سيتم استدعاء API المستنفرين
    await Future.delayed(Duration(milliseconds: 500));

    return [
      {'id': 1, 'name': 'أحمد محمد', 'military_number': 'MIL001'},
      {'id': 2, 'name': 'محمد علي', 'military_number': 'MIL002'},
      {'id': 3, 'name': 'عمر خالد', 'military_number': 'MIL003'},
      {'id': 4, 'name': 'خالد إبراهيم', 'military_number': 'MIL004'},
      {'id': 5, 'name': 'محمود حسن', 'military_number': 'MIL005'},
    ];
  }
}
