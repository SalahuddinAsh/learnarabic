import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON-blob wrapper over SharedPreferences, replacing the web app's
/// localStorage.getItem/setItem(JSON.stringify(...)) pattern 1:1.
class Storage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Map<String, dynamic>? getJson(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static void setJson(String key, Map<String, dynamic> value) {
    _prefs?.setString(key, jsonEncode(value));
  }

  static List<dynamic>? getJsonList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static void setJsonList(String key, List<dynamic> value) {
    _prefs?.setString(key, jsonEncode(value));
  }
}
