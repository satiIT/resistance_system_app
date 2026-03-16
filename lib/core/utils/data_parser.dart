import 'package:flutter/material.dart';

class DataParser {
  /// Safely retrieves a string value from a map, checking multiple possible keys.
  /// Returns [defaultValue] if no key matches or value is null.
  static String getString(
    Map<dynamic, dynamic>? data,
    List<String> keys, {
    String defaultValue = 'غير معرف',
  }) {
    if (data == null) return defaultValue;

    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final val = data[key];

        // Handle nested maps (e.g., rank: {id: 1, name: "Captain"})
        if (val is Map) {
          if (val.containsKey('name') && val['name'] != null) {
            return val['name'].toString().trim();
          }
          if (val.containsKey('${key}_name') && val['${key}_name'] != null) {
            return val['${key}_name'].toString().trim();
          }
        }

        final value = val.toString().trim();
        if (value.isNotEmpty && value != 'null') {
          return value;
        }
      }
    }
    return defaultValue;
  }

  /// Tries to find a value by converting snake_case keys to camelCase automatically if needed
  static String smartGetString(
    Map<dynamic, dynamic>? data,
    String baseKey, {
    String defaultValue = 'غير معرف',
  }) {
    if (data == null) return defaultValue;

    // Generate variations: snake_case, camelCase, PascalCase, and _name suffixes
    final keys = [
      baseKey, // first_name
      '${baseKey}_name', // first_name_name? well, for 'rank' -> 'rank_name'
      _toCamelCase(baseKey),
      '${_toCamelCase(baseKey)}Name', // rankName
      _toPascalCase(baseKey),
      baseKey.toUpperCase(),
    ];

    return getString(data, keys, defaultValue: defaultValue);
  }

  /// Safely parses a DateTime from dynamic input.
  static DateTime? smartGetDate(Map<dynamic, dynamic>? data, String baseKey) {
    if (data == null) return null;

    final keys = [
      baseKey, // first_name
      _toCamelCase(baseKey), // firstName
      _toPascalCase(baseKey), // FirstName
    ];

    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final val = data[key];
        if (val is DateTime) return val;
        if (val is String) {
          try {
            return DateTime.parse(val);
          } catch (e) {
            // ignore
          }
        }
      }
    }
    return null;
  }

  static String _toCamelCase(String text) {
    if (!text.contains('_')) return text;
    return text
        .split('_')
        .asMap()
        .map((index, word) {
          if (index == 0) return MapEntry(index, word);
          if (word.isEmpty) return MapEntry(index, '');
          return MapEntry(index, word[0].toUpperCase() + word.substring(1));
        })
        .values
        .join('');
  }

  static String _toPascalCase(String text) {
    if (text.isEmpty) return text;
    final camel = _toCamelCase(text);
    return camel[0].toUpperCase() + camel.substring(1);
  }
}
