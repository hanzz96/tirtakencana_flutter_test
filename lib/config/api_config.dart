import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String _baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Initialize from shared preferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('base_url') ?? 'http://10.0.2.2:8000/api/v1';
  }

  static String get baseUrl => _baseUrl;

  static set baseUrl(String url) {
    _baseUrl = url;
    // Save to shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('base_url', url);
    });
  }

  // Endpoints
  static String get customers => '$_baseUrl/customers';
  static String get customerFilterOptions => '$_baseUrl/customer-filter-options';
  static String get giftSummary => '$_baseUrl/gift-summary';
  static String get giftConfirmation => '$_baseUrl/gift-confirmation';
  static String get giftUpdate => '$_baseUrl/gift-update';
  static String get failedReasonOptions => '$_baseUrl/failed-reason-options';
  static String get testConnection => '$_baseUrl/test-connection';
}