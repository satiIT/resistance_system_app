// lib/core/services/intelligence_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class IntelligenceService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/intelligence';

  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('intelligence_session_id');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final sessionId = await getSessionId();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json; charset=UTF-8',
      'Accept-Charset': 'UTF-8',
      'session-id': sessionId ?? '',
    };
  }

  static Future<List<dynamic>> getRecords(String type) async {
    try {
      final endpoint = type == 'proactive'
          ? 'proactive'
          : (type == 'weapons' ? 'weapons' : 'statements');
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['data'] ?? [];
      } else if (response.statusCode == 403) {
        throw Exception('AUTH_REQUIRED');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching intelligence records: $e');
      rethrow;
    }
  }

  static Future<bool> saveRecord(String type, Map<String, dynamic> data) async {
    try {
      final endpoint = type == 'proactive'
          ? 'proactive'
          : (type == 'weapons' ? 'weapons' : 'statements');

      // If it's weapons, we might want to use the main armament API instead,
      // but for simplicity we added an endpoint in intelligence.js as well.
      // However, the weapons archive should ideally use the existing armament API.
      // For now, let's use the intelligence endpoint we just created.

      final url = type == 'weapons'
          ? '${ApiConfig.baseUrl}/api/personnel-armament'
          : '$baseUrl/$endpoint';

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: utf8.encode(json.encode(data)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error saving intelligence record: $e');
      return false;
    }
  }
}
