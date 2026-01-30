import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Currency Utilities
/// Real-time currency conversion and exchange rates
class CurrencyUtils {
  CurrencyUtils._();

  static final Dio _dio = Dio();
  
  // Multiple API endpoints for redundancy
  static const String _exchangeRatesAPI = 'https://api.exchangerate-api.com/v4/latest';
  static const String _openExchangeRatesAPI = 'https://openexchangerates.org/api/latest.json';
  static const String _frankfurterAPI = 'https://api.frankfurter.app';
  
  static String? _openExchangeRatesKey;

  /// Initialize with API keys (optional)
  static void init({String? openExchangeRatesKey}) {
    _openExchangeRatesKey = openExchangeRatesKey;
  }

  // ==================== Get Exchange Rates ====================

  /// Get latest exchange rates for a base currency
  /// Uses free exchangerate-api.com (no API key required)
  static Future<ExchangeRatesResult> getExchangeRates({
    String baseCurrency = 'USD',
  }) async {
    try {
      final response = await _dio.get(
        '$_exchangeRatesAPI/$baseCurrency',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final rates = Map<String, double>.from(
          (data['rates'] as Map).map(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
          ),
        );

        return ExchangeRatesResult(
          success: true,
          baseCurrency: data['base'] as String,
          date: data['date'] as String,
          rates: rates,
          timestamp: DateTime.now(),
        );
      }

      return ExchangeRatesResult(
        success: false,
        baseCurrency: baseCurrency,
        rates: {},
        message: 'Failed to fetch exchange rates',
      );
    } catch (e) {
      return ExchangeRatesResult(
        success: false,
        baseCurrency: baseCurrency,
        rates: {},
        message: e.toString(),
      );
    }
  }

  /// Get exchange rates using Frankfurter API (European Central Bank data)
  static Future<ExchangeRatesResult> getExchangeRatesECB({
    String baseCurrency = 'EUR',
  }) async {
    try {
      final response = await _dio.get(
        '$_frankfurterAPI/latest',
        queryParameters: {'from': baseCurrency},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final rates = Map<String, double>.from(
          (data['rates'] as Map).map(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
          ),
        );

        // Add base currency with rate 1.0
        rates[baseCurrency] = 1.0;

        return ExchangeRatesResult(
          success: true,
          baseCurrency: data['base'] as String,
          date: data['date'] as String,
          rates: rates,
          timestamp: DateTime.now(),
        );
      }

      return ExchangeRatesResult(
        success: false,
        baseCurrency: baseCurrency,
        rates: {},
        message: 'Failed to fetch exchange rates',
      );
    } catch (e) {
      return ExchangeRatesResult(
        success: false,
        baseCurrency: baseCurrency,
        rates: {},
        message: e.toString(),
      );
    }
  }

  // ==================== Currency Conversion ====================

  /// Convert amount from one currency to another
  static Future<CurrencyConversionResult> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      // Get exchange rates
      final ratesResult = await getExchangeRates(baseCurrency: fromCurrency);

      if (!ratesResult.success || !ratesResult.rates.containsKey(toCurrency)) {
        return CurrencyConversionResult(
          success: false,
          fromAmount: amount,
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          message: 'Failed to get exchange rate',
        );
      }

      final rate = ratesResult.rates[toCurrency]!;
      final convertedAmount = amount * rate;

      return CurrencyConversionResult(
        success: true,
        fromAmount: amount,
        fromCurrency: fromCurrency,
        toAmount: convertedAmount,
        toCurrency: toCurrency,
        exchangeRate: rate,
        timestamp: ratesResult.timestamp,
      );
    } catch (e) {
      return CurrencyConversionResult(
        success: false,
        fromAmount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        message: e.toString(),
      );
    }
  }

  /// Convert using Frankfurter API (more accurate for European currencies)
  static Future<CurrencyConversionResult> convertECB({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await _dio.get(
        '$_frankfurterAPI/latest',
        queryParameters: {
          'amount': amount.toString(),
          'from': fromCurrency,
          'to': toCurrency,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final rates = data['rates'] as Map;
        final convertedAmount = (rates[toCurrency] as num).toDouble();
        final rate = convertedAmount / amount;

        return CurrencyConversionResult(
          success: true,
          fromAmount: amount,
          fromCurrency: fromCurrency,
          toAmount: convertedAmount,
          toCurrency: toCurrency,
          exchangeRate: rate,
          timestamp: DateTime.now(),
        );
      }

      return CurrencyConversionResult(
        success: false,
        fromAmount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        message: 'Failed to convert currency',
      );
    } catch (e) {
      return CurrencyConversionResult(
        success: false,
        fromAmount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        message: e.toString(),
      );
    }
  }

  /// Batch convert amount to multiple currencies
  static Future<Map<String, CurrencyConversionResult>> convertToMultiple({
    required double amount,
    required String fromCurrency,
    required List<String> toCurrencies,
  }) async {
    final results = <String, CurrencyConversionResult>{};

    for (final toCurrency in toCurrencies) {
      final result = await convert(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
      results[toCurrency] = result;
    }

    return results;
  }

  // ==================== Currency Swap ====================

  /// Swap currencies (convert both ways)
  static Future<CurrencySwapResult> swap({
    required double amount,
    required String currency1,
    required String currency2,
  }) async {
    final conversion1to2 = await convert(
      amount: amount,
      fromCurrency: currency1,
      toCurrency: currency2,
    );

    final conversion2to1 = await convert(
      amount: amount,
      fromCurrency: currency2,
      toCurrency: currency1,
    );

    return CurrencySwapResult(
      currency1: currency1,
      currency2: currency2,
      amount: amount,
      currency1ToCurrency2: conversion1to2,
      currency2ToCurrency1: conversion2to1,
    );
  }

  // ==================== Historical Rates ====================

  /// Get historical exchange rates for a specific date
  /// Date format: YYYY-MM-DD
  static Future<ExchangeRatesResult> getHistoricalRates({
    required String date,
    String baseCurrency = 'USD',
  }) async {
    try {
      final response = await _dio.get(
        '$_frankfurterAPI/$date',
        queryParameters: {'from': baseCurrency},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final rates = Map<String, double>.from(
          (data['rates'] as Map).map(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
          ),
        );

        rates[baseCurrency] = 1.0;

        return ExchangeRatesResult(
          success: true,
          baseCurrency: data['base'] as String,
          date: data['date'] as String,
          rates: rates,
          timestamp: DateTime.parse(data['date'] as String),
        );
      }

      return ExchangeRatesResult(
        success: false,
        baseCurrency: baseCurrency,
        rates: {},
        message: 'Failed to fetch historical rates',
      );
    } catch (e) {
      return ExchangeRatesResult(
        success: false,
        baseCurrency: baseCurrency,
        rates: {},
        message: e.toString(),
      );
    }
  }

  // ==================== Currency Information ====================

  /// Get list of supported currencies
  static Future<List<CurrencyInfo>> getSupportedCurrencies() async {
    final result = await getExchangeRates(baseCurrency: 'USD');
    
    if (!result.success) return [];

    return result.rates.keys.map((code) {
      return CurrencyInfo(
        code: code,
        name: _getCurrencyName(code),
        symbol: _getCurrencySymbol(code),
      );
    }).toList();
  }

  /// Get currency info by code
  static CurrencyInfo getCurrencyInfo(String code) {
    return CurrencyInfo(
      code: code,
      name: _getCurrencyName(code),
      symbol: _getCurrencySymbol(code),
    );
  }

  /// Get popular currencies
  static List<CurrencyInfo> get popularCurrencies => [
        CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$'),
        CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€'),
        CurrencyInfo(code: 'GBP', name: 'British Pound', symbol: '£'),
        CurrencyInfo(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
        CurrencyInfo(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
        CurrencyInfo(code: 'NGN', name: 'Nigerian Naira', symbol: '₦'),
        CurrencyInfo(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵'),
        CurrencyInfo(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
        CurrencyInfo(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh'),
      ];

  // ==================== Helper Methods ====================

  static String _getCurrencyName(String code) {
    const names = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'CNY': 'Chinese Yuan',
      'NGN': 'Nigerian Naira',
      'GHS': 'Ghanaian Cedi',
      'ZAR': 'South African Rand',
      'KES': 'Kenyan Shilling',
      'CAD': 'Canadian Dollar',
      'AUD': 'Australian Dollar',
      'CHF': 'Swiss Franc',
      'INR': 'Indian Rupee',
      'BRL': 'Brazilian Real',
      'RUB': 'Russian Ruble',
    };
    return names[code] ?? code;
  }

  static String _getCurrencySymbol(String code) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'NGN': '₦',
      'GHS': 'GH₵',
      'ZAR': 'R',
      'KES': 'KSh',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'CHF': 'CHF',
      'INR': '₹',
      'BRL': 'R\$',
      'RUB': '₽',
    };
    return symbols[code] ?? code;
  }

  /// Format amount with currency symbol
  static String formatAmount(double amount, String currencyCode) {
    final symbol = _getCurrencySymbol(currencyCode);
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

// ==================== Models ====================

/// Exchange rates result
class ExchangeRatesResult {
  final bool success;
  final String baseCurrency;
  final String? date;
  final Map<String, double> rates;
  final DateTime? timestamp;
  final String? message;

  ExchangeRatesResult({
    required this.success,
    required this.baseCurrency,
    this.date,
    required this.rates,
    this.timestamp,
    this.message,
  });

  /// Get rate for a specific currency
  double? getRate(String currency) => rates[currency];

  /// Check if currency is supported
  bool hasCurrency(String currency) => rates.containsKey(currency);
}

/// Currency conversion result
class CurrencyConversionResult {
  final bool success;
  final double fromAmount;
  final String fromCurrency;
  final double? toAmount;
  final String toCurrency;
  final double? exchangeRate;
  final DateTime? timestamp;
  final String? message;

  CurrencyConversionResult({
    required this.success,
    required this.fromAmount,
    required this.fromCurrency,
    this.toAmount,
    required this.toCurrency,
    this.exchangeRate,
    this.timestamp,
    this.message,
  });

  /// Get formatted conversion string
  String get formattedConversion {
    if (!success || toAmount == null) return 'Conversion failed';
    
    final fromSymbol = CurrencyUtils._getCurrencySymbol(fromCurrency);
    final toSymbol = CurrencyUtils._getCurrencySymbol(toCurrency);
    
    return '$fromSymbol${fromAmount.toStringAsFixed(2)} = $toSymbol${toAmount!.toStringAsFixed(2)}';
  }
}

/// Currency swap result
class CurrencySwapResult {
  final String currency1;
  final String currency2;
  final double amount;
  final CurrencyConversionResult currency1ToCurrency2;
  final CurrencyConversionResult currency2ToCurrency1;

  CurrencySwapResult({
    required this.currency1,
    required this.currency2,
    required this.amount,
    required this.currency1ToCurrency2,
    required this.currency2ToCurrency1,
  });
}

/// Currency info
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });

  @override
  String toString() => '$name ($code)';
}

/// Usage Examples
void currencyUtilsExamples() async {
  // Get exchange rates
  final rates = await CurrencyUtils.getExchangeRates(baseCurrency: 'USD');
  if (rates.success) {
    debugPrint('1 USD = ${rates.getRate('NGN')} NGN');
    debugPrint('1 USD = ${rates.getRate('EUR')} EUR');
  }

  // Convert currency
  final conversion = await CurrencyUtils.convert(
    amount: 100,
    fromCurrency: 'USD',
    toCurrency: 'NGN',
  );

  if (conversion.success) {
    debugPrint(conversion.formattedConversion);
    debugPrint('Exchange Rate: ${conversion.exchangeRate}');
  }

  // Swap currencies
  final swap = await CurrencyUtils.swap(
    amount: 100,
    currency1: 'USD',
    currency2: 'EUR',
  );

  debugPrint('100 USD to EUR: ${swap.currency1ToCurrency2.toAmount}');
  debugPrint('100 EUR to USD: ${swap.currency2ToCurrency1.toAmount}');

  // Convert to multiple currencies
  final multiConversion = await CurrencyUtils.convertToMultiple(
    amount: 100,
    fromCurrency: 'USD',
    toCurrencies: ['NGN', 'GHS', 'KES', 'ZAR'],
  );

  multiConversion.forEach((currency, result) {
    if (result.success) {
      debugPrint('100 USD = ${result.toAmount} $currency');
    }
  });

  // Get historical rates
  final historical = await CurrencyUtils.getHistoricalRates(
    date: '2024-01-01',
    baseCurrency: 'USD',
  );

  // Get popular currencies
  for (final currency in CurrencyUtils.popularCurrencies) {
    debugPrint('${currency.name}: ${currency.symbol}');
  }

  // Format amount
  final formatted = CurrencyUtils.formatAmount(1500000, 'NGN');
  debugPrint(formatted); // ₦1500000.00
}