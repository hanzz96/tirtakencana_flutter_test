import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _baseUrlKey = 'base_url';
  static const String _defaultBaseUrl = 'http://10.0.2.2:8000/api/v1';

  static Future<void> setBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
  }

  static Future<void> clearBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
  }
}