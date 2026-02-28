import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  // 1. URLs defined
  static const String ngrokUrl =
      'https://woebegone-ian-septifragally.ngrok-free.dev';
  static const String ipAddress = '127.0.0.1';
  static const String localPort = '5000';

  static String _baseUrl = '';

  // Getter to return the discovered URL, or fall back to local if not yet initialized
  static String get baseUrl {
    if (_baseUrl.isNotEmpty) return _baseUrl;

    // Default fallback logic during first initialization
    if (kIsWeb) return 'http://$ipAddress:$localPort';
    if (Platform.isAndroid &&
        (ipAddress == '127.0.0.1' || ipAddress == 'localhost')) {
      return 'http://10.0.2.2:$localPort';
    }
    return 'http://$ipAddress:$localPort';
  }

  // Automatic Discovery logic
  static Future<void> initialize() async {
    final local = _getDefaultLocalUrl();
    final remote = ngrokUrl;

    print('🌐 [API DISCOVERY] Starting...');

    try {
      // Race: try to hit the status endpoint on both simultaneously with short timeouts
      final results = await Future.wait([_checkUrl(local), _checkUrl(remote)]);

      if (results[0]) {
        _baseUrl = local;
        print('🌐 [API DISCOVERY] Winner: LOCAL ($local)');
      } else if (results[1]) {
        _baseUrl = remote;
        print('🌐 [API DISCOVERY] Winner: NGROK ($remote)');
      } else {
        print('⚠️ [API DISCOVERY] No response. Using default local.');
        _baseUrl = local;
      }
    } catch (e) {
      print('❌ [API DISCOVERY] Error during discovery: $e');
      _baseUrl = local;
    }
  }

  static String _getDefaultLocalUrl() {
    if (kIsWeb) return 'http://$ipAddress:$localPort';
    if (Platform.isAndroid &&
        (ipAddress == '127.0.0.1' || ipAddress == 'localhost')) {
      return 'http://10.0.2.2:$localPort';
    }
    return 'http://$ipAddress:$localPort';
  }

  static Future<bool> _checkUrl(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse('$url/api/public'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 2));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
}
