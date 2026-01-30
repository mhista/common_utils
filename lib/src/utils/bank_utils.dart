import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Bank Utilities
/// Utilities for bank operations using Paystack API
class BankUtils {
  BankUtils._();

  static final Dio _dio = Dio();
  static const String _paystackBaseUrl = 'https://api.paystack.co';
  static String? _paystackSecretKey;

  /// Initialize with Paystack secret key
  static void init({required String paystackSecretKey}) {
    _paystackSecretKey = paystackSecretKey;
    _dio.options.headers['Authorization'] = 'Bearer $paystackSecretKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  /// Check if initialized
  static bool get isInitialized => _paystackSecretKey != null;

  // ==================== Get Banks List ====================

  /// Get list of banks for a country
  /// [country] - Country code (NG for Nigeria, GH for Ghana, ZA for South Africa, KE for Kenya)
  /// [currency] - Currency code (NGN, GHS, ZAR, KES)
  /// [perPage] - Number of results per page (default: 100)
  /// [page] - Page number (default: 1)
  static Future<BankListResult> getBanks({
    String country = 'nigeria',
    String? currency,
    int perPage = 100,
    int page = 1,
  }) async {
    try {
      if (!isInitialized) {
        throw BankUtilsException('BankUtils not initialized. Call BankUtils.init() first.');
      }

      final queryParams = {
        'country': country,
        'perPage': perPage.toString(),
        'page': page.toString(),
      };

      if (currency != null) {
        queryParams['currency'] = currency;
      }

      final response = await _dio.get(
        '$_paystackBaseUrl/bank',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'] as List;
        final banks = data.map((json) => Bank.fromJson(json)).toList();
        
        return BankListResult(
          success: true,
          banks: banks,
          message: response.data['message'],
        );
      }

      return BankListResult(
        success: false,
        banks: [],
        message: response.data['message'] ?? 'Failed to fetch banks',
      );
    } catch (e) {
      return BankListResult(
        success: false,
        banks: [],
        message: e.toString(),
      );
    }
  }

  /// Get Nigerian banks (convenience method)
  static Future<BankListResult> getNigerianBanks() {
    return getBanks(country: 'nigeria', currency: 'NGN');
  }

  /// Get Ghanaian banks
  static Future<BankListResult> getGhanaianBanks() {
    return getBanks(country: 'ghana', currency: 'GHS');
  }

  /// Get South African banks
  static Future<BankListResult> getSouthAfricanBanks() {
    return getBanks(country: 'south africa', currency: 'ZAR');
  }

  /// Get Kenyan banks
  static Future<BankListResult> getKenyanBanks() {
    return getBanks(country: 'kenya', currency: 'KES');
  }

  // ==================== Resolve Account Details ====================

  /// Resolve account number to get account name
  /// [accountNumber] - Bank account number
  /// [bankCode] - Bank code from banks list
  static Future<AccountResolutionResult> resolveAccountNumber({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      if (!isInitialized) {
        throw BankUtilsException('BankUtils not initialized. Call BankUtils.init() first.');
      }

      final response = await _dio.get(
        '$_paystackBaseUrl/bank/resolve',
        queryParameters: {
          'account_number': accountNumber,
          'bank_code': bankCode,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        
        return AccountResolutionResult(
          success: true,
          accountNumber: data['account_number'],
          accountName: data['account_name'],
          bankId: data['bank_id'],
        );
      }

      return AccountResolutionResult(
        success: false,
        message: response.data['message'] ?? 'Failed to resolve account',
      );
    } catch (e) {
      return AccountResolutionResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  // ==================== Validate Account ====================

  /// Validate bank account (checks if account exists and returns details)
  static Future<AccountValidationResult> validateAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final resolution = await resolveAccountNumber(
        accountNumber: accountNumber,
        bankCode: bankCode,
      );

      if (resolution.success && resolution.accountName != null) {
        return AccountValidationResult(
          isValid: true,
          accountNumber: resolution.accountNumber,
          accountName: resolution.accountName,
          message: 'Account validated successfully',
        );
      }

      return AccountValidationResult(
        isValid: false,
        message: resolution.message ?? 'Invalid account',
      );
    } catch (e) {
      return AccountValidationResult(
        isValid: false,
        message: e.toString(),
      );
    }
  }

  // ==================== Search Banks ====================

  /// Search banks by name
  static Future<List<Bank>> searchBanks({
    required String query,
    String country = 'nigeria',
  }) async {
    final result = await getBanks(country: country);
    
    if (!result.success) return [];

    return result.banks.where((bank) {
      return bank.name.toLowerCase().contains(query.toLowerCase()) ||
          bank.code.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get bank by code
  static Future<Bank?> getBankByCode({
    required String code,
    String country = 'nigeria',
  }) async {
    final result = await getBanks(country: country);
    
    if (!result.success) return null;

    try {
      return result.banks.firstWhere((bank) => bank.code == code);
    } catch (e) {
      return null;
    }
  }

  // ==================== Supported Countries ====================

  /// Get list of supported countries
  static List<BankCountry> get supportedCountries => [
        BankCountry(
          name: 'Nigeria',
          code: 'nigeria',
          currency: 'NGN',
          currencySymbol: '₦',
        ),
        BankCountry(
          name: 'Ghana',
          code: 'ghana',
          currency: 'GHS',
          currencySymbol: 'GH₵',
        ),
        BankCountry(
          name: 'South Africa',
          code: 'south africa',
          currency: 'ZAR',
          currencySymbol: 'R',
        ),
        BankCountry(
          name: 'Kenya',
          code: 'kenya',
          currency: 'KES',
          currencySymbol: 'KSh',
        ),
      ];

  /// Check if country is supported
  static bool isCountrySupported(String countryCode) {
    return supportedCountries.any((c) => c.code == countryCode.toLowerCase());
  }
}

// ==================== Models ====================

/// Bank model
class Bank {
  final int id;
  final String name;
  final String slug;
  final String code;
  final String? longCode;
  final String? gateway;
  final bool payWithBank;
  final bool active;
  final String? country;
  final String? currency;
  final String type;

  Bank({
    required this.id,
    required this.name,
    required this.slug,
    required this.code,
    this.longCode,
    this.gateway,
    required this.payWithBank,
    required this.active,
    this.country,
    this.currency,
    required this.type,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      code: json['code'] as String,
      longCode: json['longcode'] as String?,
      gateway: json['gateway'] as String?,
      payWithBank: json['pay_with_bank'] as bool? ?? false,
      active: json['active'] as bool,
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'code': code,
      'longcode': longCode,
      'gateway': gateway,
      'pay_with_bank': payWithBank,
      'active': active,
      'country': country,
      'currency': currency,
      'type': type,
    };
  }

  @override
  String toString() => name;
}

/// Bank list result
class BankListResult {
  final bool success;
  final List<Bank> banks;
  final String? message;

  BankListResult({
    required this.success,
    required this.banks,
    this.message,
  });
}

/// Account resolution result
class AccountResolutionResult {
  final bool success;
  final String? accountNumber;
  final String? accountName;
  final int? bankId;
  final String? message;

  AccountResolutionResult({
    required this.success,
    this.accountNumber,
    this.accountName,
    this.bankId,
    this.message,
  });
}

/// Account validation result
class AccountValidationResult {
  final bool isValid;
  final String? accountNumber;
  final String? accountName;
  final String? message;

  AccountValidationResult({
    required this.isValid,
    this.accountNumber,
    this.accountName,
    this.message,
  });
}

/// Bank country model
class BankCountry {
  final String name;
  final String code;
  final String currency;
  final String currencySymbol;

  BankCountry({
    required this.name,
    required this.code,
    required this.currency,
    required this.currencySymbol,
  });
}

/// Bank Utils Exception
class BankUtilsException implements Exception {
  final String message;

  BankUtilsException(this.message);

  @override
  String toString() => 'BankUtilsException: $message';
}

/// Usage Examples
void bankUtilsExamples() async {
  // Initialize
  BankUtils.init(paystackSecretKey: 'sk_test_your_secret_key');

  // Get Nigerian banks
  final banksResult = await BankUtils.getNigerianBanks();
  if (banksResult.success) {
    debugPrint('Found ${banksResult.banks.length} banks');
    for (final bank in banksResult.banks) {
      debugPrint('${bank.name} - ${bank.code}');
    }
  }

  // Resolve account number
  final resolution = await BankUtils.resolveAccountNumber(
    accountNumber: '0123456789',
    bankCode: '058', // GTBank code
  );

  if (resolution.success) {
    debugPrint('Account Name: ${resolution.accountName}');
  }

  // Validate account
  final validation = await BankUtils.validateAccount(
    accountNumber: '0123456789',
    bankCode: '058',
  );

  if (validation.isValid) {
    debugPrint('Valid account: ${validation.accountName}');
  }

  // Search banks
  final _ = await BankUtils.searchBanks(
    query: 'GTBank',
    country: 'nigeria',
  );

  // Get bank by code
  final bank = await BankUtils.getBankByCode(code: '058');
  debugPrint(bank?.name);

  // Get supported countries
  for (final country in BankUtils.supportedCountries) {
    debugPrint('${country.name} (${country.currency})');
  }
}