import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/customer_model.dart';
import '../models/gift_summary_model.dart';
import '../utils/logger.dart';

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  String get baseUrl => ApiConfig.baseUrl;

  // Helper method untuk handle response dengan logging
  Map<String, dynamic> _handleResponse(http.Response response, String endpoint) {
    AppLogger.debug('📊 Handling response for: $endpoint');
    AppLogger.verbose('🔢 Status Code: ${response.statusCode}');
    AppLogger.verbose('📦 Response Headers: ${response.headers}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        AppLogger.debug('✅ Response successful for: $endpoint');
        AppLogger.verbose('📄 Response Data: $data');
        return data;
      } catch (e) {
        AppLogger.error('❌ JSON decode error for: $endpoint', e);
        throw Exception('JSON decode error: $e');
      }
    } else {
      AppLogger.warning('⚠️ HTTP Error ${response.statusCode} for: $endpoint');
      AppLogger.verbose('📄 Error Response Body: ${response.body}');
      throw Exception('HTTP ${response.statusCode} - Failed to load data from $endpoint');
    }
  }

  // Get customers dengan filter - Fixed for pagination response
  // Get customers - Simplified for pagination
  Future<List<Customer>> getCustomers({String? shopName}) async {
    final endpoint = 'customers';
    final url = shopName != null && shopName != 'Semua Toko'
        ? '${ApiConfig.customers}?shop_name=${Uri.encodeComponent(shopName)}'
        : ApiConfig.customers;

    AppLogger.info('🛍️ Fetching customers');

    try {
      final response = await client.get(Uri.parse(url));
      final data = _handleResponse(response, endpoint);

      if (data['success'] == true) {
        // Extract from pagination structure: {current_page: 1, data: [...]}
        final paginationData = data['data'] as Map<String, dynamic>;
        final customersData = paginationData['data'] as List;

        final customers = customersData
            .map((json) => Customer.fromJson(json))
            .toList();

        AppLogger.info('✅ Loaded ${customers.length} customers');
        return customers;
      } else {
        throw Exception('API Error: ${data['message']}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 Failed to fetch customers', e, stackTrace);
      rethrow;
    }
  }
  // Get customer filter options
  Future<List<String>> getCustomerFilterOptions() async {
    const endpoint = 'customer-filter-options';
    AppLogger.info('🏪 Fetching shop filter options');
    AppLogger.debug('📡 URL: ${ApiConfig.customerFilterOptions}');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await client.get(Uri.parse(ApiConfig.customerFilterOptions));
      stopwatch.stop();

      AppLogger.debug('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      final data = _handleResponse(response, endpoint);

      if (data['success'] == true) {
        final shops = (data['shops'] as List).cast<String>();
        AppLogger.info('✅ Loaded ${shops.length} shop options');
        AppLogger.verbose('🏪 Shops: $shops');
        return shops;
      } else {
        AppLogger.error('❌ API returned error for shop options', null);
        throw Exception('API Error: ${data['message']}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 Failed to fetch shop options', e, stackTrace);
      rethrow;
    }
  }

  // Get gift summary
  // Get gift summary dengan response handling yang benar
  Future<List<GiftSummary>> getGiftSummary() async {
    const endpoint = 'gift-summary';
    AppLogger.info('🎁 Fetching gift summary');
    AppLogger.debug('📡 URL: ${ApiConfig.giftSummary}');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await client.get(Uri.parse(ApiConfig.giftSummary));
      stopwatch.stop();

      AppLogger.debug('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      final data = _handleResponse(response, endpoint);

      AppLogger.verbose('📄 Gift Summary Response: $data');

      if (data['success'] == true) {
        // Handle different response structures
        dynamic giftData = data['data'];

        List<dynamic> giftsList = [];

        if (giftData is List) {
          giftsList = giftData;
        } else if (giftData is Map<String, dynamic>) {
          // Jika response paginated
          if (giftData['data'] is List) {
            giftsList = giftData['data'];
          } else {
            throw Exception('Invalid gift summary data format');
          }
        } else {
          throw Exception('Unknown gift summary response format');
        }

        final gifts = giftsList
            .map((json) => GiftSummary.fromJson(json))
            .toList();

        AppLogger.info('✅ Loaded ${gifts.length} gift types');
        AppLogger.verbose('🎁 Gifts: ${gifts.map((g) => g.name).toList()}');
        return gifts;
      } else {
        AppLogger.error('❌ API returned error for gift summary: ${data['message']}');
        throw Exception('API Error: ${data['message']}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 Failed to fetch gift summary', e, stackTrace);
      rethrow;
    }
  }

  // Confirm gift (terima/tolak) - Dengan better error handling
  Future<Map<String, dynamic>> confirmGift({
    required String custId,
    required String action,
    required List<String> ttOtpNumbers,
    String? failedReason,
  }) async {
    const endpoint = 'gift-confirmation';
    AppLogger.info('📝 Confirming gift - Action: $action');

    final body = {
      'cust_id': custId,
      'action': action,
      'tt_otp_numbers': ttOtpNumbers,
      'failed_reason': failedReason,
    };

    try {
      final stopwatch = Stopwatch()..start();
      final response = await client.post(
        Uri.parse(ApiConfig.giftConfirmation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      stopwatch.stop();

      AppLogger.debug('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      AppLogger.verbose('📦 Request Body: $body');

      // Handle response dengan detail
      final data = _handleResponse(response, endpoint);

      if (data['success'] == true) {
        AppLogger.info('✅ Gift confirmation successful - $action');
        return data;
      } else {
        // Log error detail dari API response
        AppLogger.error('❌ API returned error for gift confirmation: ${data['message']}');
        AppLogger.error('📄 Error details: ${data['errors'] ?? 'No additional error details'}');
        throw Exception('API Error: ${data['message']}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 Failed to confirm gift', e, stackTrace);
      AppLogger.error('📡 URL: ${ApiConfig.giftConfirmation}');
      AppLogger.error('📦 Request: $body');
      rethrow;
    }
  }

  // Update gift status
  Future<Map<String, dynamic>> updateGiftStatus({
    required int id,
    required String action,
  }) async {
    final endpoint = 'gift-update/$id';
    final url = '${ApiConfig.giftUpdate}/$id';

    AppLogger.info('🔄 Updating gift status');
    AppLogger.debug('📡 URL: $url');
    AppLogger.debug('🆔 TTH ID: $id');
    AppLogger.debug('🎯 Action: $action');

    final body = {'action': action};

    try {
      final stopwatch = Stopwatch()..start();
      final response = await client.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      stopwatch.stop();

      AppLogger.debug('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      AppLogger.verbose('📦 Request Body: $body');
      final data = _handleResponse(response, endpoint);

      if (data['success'] == true) {
        AppLogger.info('✅ Gift status updated successfully');
        AppLogger.verbose('📄 Response: $data');
        return data;
      } else {
        AppLogger.error('❌ Gift status update failed', null);
        throw Exception('API Error: ${data['message']}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 Failed to update gift status', e, stackTrace);
      rethrow;
    }
  }

  // Get failed reason options
  Future<List<String>> getFailedReasonOptions() async {
    const endpoint = 'failed-reason-options';
    AppLogger.info('📋 Fetching failed reason options');
    AppLogger.debug('📡 URL: ${ApiConfig.failedReasonOptions}');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await client.get(Uri.parse(ApiConfig.failedReasonOptions));
      stopwatch.stop();

      AppLogger.debug('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      final data = _handleResponse(response, endpoint);

      if (data['success'] == true) {
        final reasons = (data['data'] as List).cast<String>();
        AppLogger.info('✅ Loaded ${reasons.length} failed reasons');
        AppLogger.verbose('📋 Reasons: $reasons');
        return reasons;
      } else {
        AppLogger.error('❌ API returned error for failed reasons', null);
        throw Exception('API Error: ${data['message']}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 Failed to fetch failed reasons', e, stackTrace);
      rethrow;
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    const endpoint = 'test-connection';
    AppLogger.info('🚀 Testing API Connection');
    AppLogger.debug('📡 URL: ${ApiConfig.testConnection}');
    AppLogger.debug('🔗 Base URL: $baseUrl');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await client.get(
        Uri.parse(ApiConfig.testConnection),
        headers: {'Accept': 'application/json'},
      );
      stopwatch.stop();

      AppLogger.debug('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      AppLogger.debug('📊 Status Code: ${response.statusCode}');
      AppLogger.verbose('📦 Response Headers: ${response.headers}');
      AppLogger.verbose('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        AppLogger.info('✅ API Connection Successful: $data');
        return data['success'] == true;
      } else {
        AppLogger.warning('❌ API returned error: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 API Connection Failed', e, stackTrace);
      rethrow;
    }
  }

  // Utility method untuk log semua endpoints
  void logAllEndpoints() {
    AppLogger.info('🌐 Available API Endpoints:');
    AppLogger.debug('   📍 Base URL: $baseUrl');
    AppLogger.debug('   👥 Customers: ${ApiConfig.customers}');
    AppLogger.debug('   🏪 Shop Options: ${ApiConfig.customerFilterOptions}');
    AppLogger.debug('   🎁 Gift Summary: ${ApiConfig.giftSummary}');
    AppLogger.debug('   ✅ Gift Confirmation: ${ApiConfig.giftConfirmation}');
    AppLogger.debug('   🔄 Gift Update: ${ApiConfig.giftUpdate}');
    AppLogger.debug('   📋 Failed Reasons: ${ApiConfig.failedReasonOptions}');
    AppLogger.debug('   🚀 Test Connection: ${ApiConfig.testConnection}');
  }
}