// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl =
      'http://localhost:5000'; // Replace with your API URL
  static const Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
}
