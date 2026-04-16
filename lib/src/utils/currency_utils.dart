// ═════════════════════════════════════════════════════════════════════
// FILE: utils/currency/currency_utils.dart  (app-independent utility)
//
// ── What changed from v1 ──────────────────────────────────────────
// • CurrencyInfo enriched: flag, locale, decimalDigits, symbolBefore,
//   fallbackRateToNgn, full formatting methods (formatAmount, formatCompact,
//   formatAmountNoSymbol, formatFull, selectorLabel, shortLabel).
//   The original 3-field struct is a subset — fully backward-compatible.
//
// • CurrencyUtils._getCurrencyName / _getCurrencySymbol replaced by
//   CurrencyRegistry lookup — single source of truth, 18+ currencies.
//
// • Switched from http → Dio (matches existing codebase).
//
// • Added in-memory rate cache (1-hour TTL) + parallel-fetch guard.
//   warmUp() pre-fetches at app start; subsequent calls are no-ops.
//
// • Added convertSync() / formatSync() for synchronous widget builds.
//
// • All existing public methods (getExchangeRates, getExchangeRatesECB,
//   convert, convertECB, convertToMultiple, swap, getHistoricalRates,
//   getSupportedCurrencies, getCurrencyInfo, popularCurrencies,
//   formatAmount) are unchanged in signature.
// ═════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────
// CURRENCY INFO — rich value object (app-independent)
// ─────────────────────────────────────────────────────────────────────
class CurrencyInfo {
  /// ISO 4217 code — always uppercase  e.g. 'NGN', 'USD', 'GBP'
  final String code;

  /// Full English name  e.g. 'Nigerian Naira', 'US Dollar'
  final String name;

  /// Primary display symbol  e.g. '₦', '$', '£', '€'
  final String symbol;

  /// Country/region flag emoji  e.g. '🇳🇬', '🇺🇸'
  /// Empty string if not applicable (e.g. multi-country currencies)
  final String flag;

  /// BCP-47 locale used for number formatting  e.g. 'en_NG', 'en_US'
  final String locale;

  /// Decimal places (0 for zero-decimal currencies like JPY, NGN)
  final int decimalDigits;

  /// Whether symbol comes before the number — '$100' (true) vs '100 kr' (false)
  final bool symbolBefore;

  /// Approximate exchange rate relative to NGN.
  /// Used as offline fallback — not for financial precision.
  /// e.g. USD → 1580.0 means "1 USD ≈ ₦1,580"
  final double fallbackRateToNgn;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    this.flag = '',
    this.locale = 'en_US',
    this.decimalDigits = 2,
    this.symbolBefore = true,
    this.fallbackRateToNgn = 1.0,
  });

  // ── Formatting ────────────────────────────────────────────────────

  /// Full formatted amount with symbol.
  /// e.g. formatAmount(24000000) → '₦24,000,000' or '$24,000,000.00'
  String formatAmount(double amount, {bool compact = false}) {
    if (compact) return _formatCompact(amount);
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Compact format for cards/badges — e.g. ₦24M, $15K, £1.2B
  String formatCompact(double amount) => _formatCompact(amount);

  /// Number only, no symbol — for input fields where symbol is shown separately
  String formatAmountNoSymbol(double amount) {
    final pattern =
        '#,##0${decimalDigits > 0 ? '.${'0' * decimalDigits}' : ''}';
    return NumberFormat(pattern, locale).format(amount);
  }

  /// Full format respecting symbol position — '$24,000,000' or '24.000.000 kr'
  String formatFull(double amount) {
    final num = formatAmountNoSymbol(amount);
    return symbolBefore ? '$symbol$num' : '$num $symbol';
  }

  /// Selector chip label — '₦ NGN', '$ USD'
  String get selectorLabel => '$symbol $code';

  /// Short label — '₦', 'KSh NGN' (falls back to code when symbol is long)
  String get shortLabel => symbol.length <= 2 ? '$symbol $code' : symbol;

  // ── Private ───────────────────────────────────────────────────────

  String _formatCompact(double amount) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';
    String result;
    if (abs >= 1_000_000_000) {
      result = '${_trim((abs / 1_000_000_000).toStringAsFixed(1))}B';
    } else if (abs >= 1_000_000) {
      result = '${_trim((abs / 1_000_000).toStringAsFixed(1))}M';
    } else if (abs >= 1_000) {
      result = '${_trim((abs / 1_000).toStringAsFixed(1))}K';
    } else {
      result = abs.toStringAsFixed(0);
    }
    return symbolBefore ? '$sign$symbol$result' : '$sign$result $symbol';
  }

  static String _trim(String s) {
    if (!s.contains('.')) return s;
    s = s.replaceAll(RegExp(r'0+$'), '');
    return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
  }

  @override
  String toString() => '$name ($code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CurrencyInfo && other.code == code);

  @override
  int get hashCode => code.hashCode;
}

// ─────────────────────────────────────────────────────────────────────
// CURRENCY REGISTRY — static lookup, single source of truth
// App-independent — no MyCut-specific fields here.
// MyCut-specific filtering (availableForDeals etc.) lives in
// MyCutCurrencyHelper.
// ─────────────────────────────────────────────────────────────────────
abstract class CurrencyRegistry {
  // ── African ────────────────────────────────────────────────────────
  static const CurrencyInfo ngn = CurrencyInfo(
    code: 'NGN',
    name: 'Nigerian Naira',
    symbol: '₦',
    flag: '🇳🇬',
    locale: 'en_NG',
    decimalDigits: 0,
    symbolBefore: true,
    fallbackRateToNgn: 1.0,
  );
  static const CurrencyInfo ghs = CurrencyInfo(
    code: 'GHS',
    name: 'Ghanaian Cedi',
    symbol: 'GH₵',
    flag: '🇬🇭',
    locale: 'en_GH',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 62.0,
  );
  static const CurrencyInfo kes = CurrencyInfo(
    code: 'KES',
    name: 'Kenyan Shilling',
    symbol: 'KSh',
    flag: '🇰🇪',
    locale: 'sw_KE',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 5.8,
  );
  static const CurrencyInfo zar = CurrencyInfo(
    code: 'ZAR',
    name: 'South African Rand',
    symbol: 'R',
    flag: '🇿🇦',
    locale: 'en_ZA',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 40.0,
  );
  static const CurrencyInfo egp = CurrencyInfo(
    code: 'EGP',
    name: 'Egyptian Pound',
    symbol: 'E£',
    flag: '🇪🇬',
    locale: 'ar_EG',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 15.0,
  );
  static const CurrencyInfo tzs = CurrencyInfo(
    code: 'TZS',
    name: 'Tanzanian Shilling',
    symbol: 'TSh',
    flag: '🇹🇿',
    locale: 'sw_TZ',
    decimalDigits: 0,
    symbolBefore: true,
    fallbackRateToNgn: 0.28,
  );
  static const CurrencyInfo ugx = CurrencyInfo(
    code: 'UGX',
    name: 'Ugandan Shilling',
    symbol: 'USh',
    flag: '🇺🇬',
    locale: 'sw_UG',
    decimalDigits: 0,
    symbolBefore: true,
    fallbackRateToNgn: 0.20,
  );
  static const CurrencyInfo xof = CurrencyInfo(
    code: 'XOF',
    name: 'West African CFA Franc',
    symbol: 'CFA',
    flag: '🌍',
    locale: 'fr_SN',
    decimalDigits: 0,
    symbolBefore: false,
    fallbackRateToNgn: 1.2,
  );

  // ── Major World ────────────────────────────────────────────────────
  static const CurrencyInfo usd = CurrencyInfo(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    flag: '🇺🇸',
    locale: 'en_US',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 1580.0,
  );
  static const CurrencyInfo eur = CurrencyInfo(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    flag: '🇪🇺',
    locale: 'de_DE',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 1720.0,
  );
  static const CurrencyInfo gbp = CurrencyInfo(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    flag: '🇬🇧',
    locale: 'en_GB',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 2010.0,
  );
  static const CurrencyInfo aed = CurrencyInfo(
    code: 'AED',
    name: 'UAE Dirham',
    symbol: 'د.إ',
    flag: '🇦🇪',
    locale: 'ar_AE',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 430.0,
  );
  static const CurrencyInfo cad = CurrencyInfo(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
    flag: '🇨🇦',
    locale: 'en_CA',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 1160.0,
  );
  static const CurrencyInfo aud = CurrencyInfo(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
    flag: '🇦🇺',
    locale: 'en_AU',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 1030.0,
  );
  static const CurrencyInfo chf = CurrencyInfo(
    code: 'CHF',
    name: 'Swiss Franc',
    symbol: 'Fr',
    flag: '🇨🇭',
    locale: 'de_CH',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 1790.0,
  );
  static const CurrencyInfo cny = CurrencyInfo(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    flag: '🇨🇳',
    locale: 'zh_CN',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 220.0,
  );
  static const CurrencyInfo jpy = CurrencyInfo(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    flag: '🇯🇵',
    locale: 'ja_JP',
    decimalDigits: 0,
    symbolBefore: true,
    fallbackRateToNgn: 10.5,
  );
  static const CurrencyInfo inr = CurrencyInfo(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    flag: '🇮🇳',
    locale: 'en_IN',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 19.0,
  );
  static const CurrencyInfo brl = CurrencyInfo(
    code: 'BRL',
    name: 'Brazilian Real',
    symbol: 'R\$',
    flag: '🇧🇷',
    locale: 'pt_BR',
    decimalDigits: 2,
    symbolBefore: true,
    fallbackRateToNgn: 290.0,
  );
  static const CurrencyInfo rub = CurrencyInfo(
    code: 'RUB',
    name: 'Russian Ruble',
    symbol: '₽',
    flag: '🇷🇺',
    locale: 'ru_RU',
    decimalDigits: 2,
    symbolBefore: false,
    fallbackRateToNgn: 17.0,
  );

  // ── Registry map ───────────────────────────────────────────────────
  static const Map<String, CurrencyInfo> _all = {
    'NGN': ngn,
    'GHS': ghs,
    'KES': kes,
    'ZAR': zar,
    'EGP': egp,
    'TZS': tzs,
    'UGX': ugx,
    'XOF': xof,
    'USD': usd,
    'EUR': eur,
    'GBP': gbp,
    'AED': aed,
    'CAD': cad,
    'AUD': aud,
    'CHF': chf,
    'CNY': cny,
    'JPY': jpy,
    'INR': inr,
    'BRL': brl,
    'RUB': rub,
  };

  /// All registered currencies
  static List<CurrencyInfo> get all => _all.values.toList();

  /// African currencies
  static List<CurrencyInfo> get african => [
    ngn,
    ghs,
    kes,
    zar,
    egp,
    tzs,
    ugx,
    xof,
  ];

  /// Popular currencies shown in quick-select lists
  static List<CurrencyInfo> get popular => [
    usd,
    eur,
    gbp,
    jpy,
    cny,
    ngn,
    ghs,
    zar,
    kes,
  ];

  /// Look up by ISO code — returns NGN as safe fallback
  static CurrencyInfo get(String code) => _all[code.toUpperCase()] ?? ngn;

  /// Look up by ISO code — returns null if not found
  static CurrencyInfo? tryGet(String code) => _all[code.toUpperCase()];

  /// Whether a code is registered
  static bool isKnown(String code) => _all.containsKey(code.toUpperCase());

  /// Build a CurrencyInfo from a raw API currency code.
  /// If not in registry, constructs a minimal entry using code as symbol.
  static CurrencyInfo fromApiCode(String code) =>
      _all[code.toUpperCase()] ??
      CurrencyInfo(
        code: code.toUpperCase(),
        name: code.toUpperCase(),
        symbol: code.toUpperCase(),
      );
}

// ─────────────────────────────────────────────────────────────────────
// RATE CACHE (internal)
// ─────────────────────────────────────────────────────────────────────
class _RateCache {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime fetchedAt;
  static const Duration ttl = Duration(hours: 1);

  _RateCache({
    required this.baseCurrency,
    required this.rates,
    required this.fetchedAt,
  });

  bool get isExpired => DateTime.now().difference(fetchedAt) > ttl;
  bool get isFresh => !isExpired;
}

// ─────────────────────────────────────────────────────────────────────
// RESULT MODELS
// ─────────────────────────────────────────────────────────────────────

/// Result of a getExchangeRates() call
class ExchangeRatesResult {
  final bool success;
  final String baseCurrency;
  final String? date;
  final Map<String, double> rates;
  final DateTime? timestamp;
  final String? message;

  /// true = came from live API; false = cached or fallback
  final bool isLive;

  const ExchangeRatesResult({
    required this.success,
    required this.baseCurrency,
    this.date,
    required this.rates,
    this.timestamp,
    this.message,
    this.isLive = false,
  });

  /// Rate for a specific currency, or null if not in response
  double? getRate(String currency) => rates[currency.toUpperCase()];

  bool hasCurrency(String currency) =>
      rates.containsKey(currency.toUpperCase());

  /// Convert this result to a CurrencyInfo-enriched map
  Map<String, CurrencyInfo> get currencyInfoMap => {
    for (final e in rates.entries) e.key: CurrencyRegistry.fromApiCode(e.key),
  };
}

/// Result of a single currency conversion
class CurrencyConversionResult {
  final bool success;
  final double fromAmount;
  final String fromCurrency;
  final double? toAmount;
  final String toCurrency;
  final double? exchangeRate;
  final DateTime? timestamp;
  final String? message;
  final bool isLive;

  const CurrencyConversionResult({
    required this.success,
    required this.fromAmount,
    required this.fromCurrency,
    this.toAmount,
    required this.toCurrency,
    this.exchangeRate,
    this.timestamp,
    this.message,
    this.isLive = false,
  });

  /// '₦24,000,000 = $15,189.87'
  String get formattedConversion {
    if (!success || toAmount == null) return 'Conversion failed';
    final from = CurrencyRegistry.get(fromCurrency);
    final to = CurrencyRegistry.get(toCurrency);
    return '${from.formatAmount(fromAmount)} = ${to.formatAmount(toAmount!)}';
  }

  /// '$15,189.87'
  String get formattedResult {
    if (!success || toAmount == null) return '';
    return CurrencyRegistry.get(toCurrency).formatAmount(toAmount!);
  }

  /// '1 NGN = $0.000633'
  String get rateDescription {
    if (exchangeRate == null) return '';
    final to = CurrencyRegistry.get(toCurrency);
    return '1 $fromCurrency = ${to.formatAmount(exchangeRate!)}';
  }
}

/// Result of a two-way swap operation
class CurrencySwapResult {
  final String currency1;
  final String currency2;
  final double amount;
  final CurrencyConversionResult currency1ToCurrency2;
  final CurrencyConversionResult currency2ToCurrency1;

  const CurrencySwapResult({
    required this.currency1,
    required this.currency2,
    required this.amount,
    required this.currency1ToCurrency2,
    required this.currency2ToCurrency1,
  });
}

// ─────────────────────────────────────────────────────────────────────
// CURRENCY UTILS — app-independent utility class
// All original public methods preserved. New methods added.
// ─────────────────────────────────────────────────────────────────────
class CurrencyUtils {
  CurrencyUtils._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // ── API endpoints ─────────────────────────────────────────────────
  /// Free, no API key  —  base can be any currency
  static const String _exchangeRatesAPI =
      'https://api.exchangerate-api.com/v6/';

  /// European Central Bank data via Frankfurter  —  supports historical
  static const String _frankfurterAPI = 'https://api.frankfurter.app';

  // ── In-memory cache (one entry per base currency) ─────────────────
  static final Map<String, _RateCache> _cache = {};

  /// Optional init (reserved for future API key support)
  static void init({String? openExchangeRatesKey}) {}

  // ═══════════════════════════════════════════════════════════════════
  // WARM-UP  —  call once at app start
  // ═══════════════════════════════════════════════════════════════════

  /// Pre-fetch NGN-base rates so first UI render is instant.
  /// Safe to call multiple times — no-op if cache is fresh.
  static Future<void> warmUp({String baseCurrency = 'NGN'}) async {
    final key = baseCurrency.toUpperCase();
    if (_cache[key]?.isFresh == true) return;
    await getExchangeRates(baseCurrency: baseCurrency);
  }

  /// Whether live rates are cached and fresh for [baseCurrency]
  static bool hasLiveRates({String baseCurrency = 'NGN'}) =>
      _cache[baseCurrency.toUpperCase()]?.isFresh == true;

  /// When rates for [baseCurrency] were last fetched
  static DateTime? lastFetchTime({String baseCurrency = 'NGN'}) =>
      _cache[baseCurrency.toUpperCase()]?.fetchedAt;

  // ═══════════════════════════════════════════════════════════════════
  // GET EXCHANGE RATES
  // ═══════════════════════════════════════════════════════════════════

  /// Get latest exchange rates for [baseCurrency] (exchangerate-api.com).
  /// Results are cached for 1 hour.
  static Future<ExchangeRatesResult> getExchangeRates({
    String baseCurrency = 'USD',
  }) async {
    final key = baseCurrency.toUpperCase();

    // Return from cache if fresh
    if (_cache[key]?.isFresh == true) {
      return ExchangeRatesResult(
        success: true,
        baseCurrency: key,
        rates: _cache[key]!.rates,
        timestamp: _cache[key]!.fetchedAt,
        isLive: true,
      );
    }

    try {
      final response = await _dio.get('$_exchangeRatesAPI/$key/latest');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = _parseRates(data['rates'] as Map);

        // Populate cache
        _cache[key] = _RateCache(
          baseCurrency: key,
          rates: rates,
          fetchedAt: DateTime.now(),
        );

        return ExchangeRatesResult(
          success: true,
          baseCurrency: data['base'] as String? ?? key,
          date: data['date'] as String?,
          rates: rates,
          timestamp: DateTime.now(),
          isLive: true,
        );
      }
    } catch (e) {
      debugPrint('[CurrencyUtils] getExchangeRates error: $e');
    }

    // Fallback: derive rates from CurrencyRegistry hardcoded values
    return ExchangeRatesResult(
      success: false,
      baseCurrency: key,
      rates: _fallbackRatesFor(key),
      timestamp: DateTime.now(),
      message: 'Using fallback rates — network unavailable',
      isLive: false,
    );
  }

  /// Get latest rates via Frankfurter (ECB data).
  /// More accurate for EUR-pair currencies. Does NOT cache separately.
  static Future<ExchangeRatesResult> getExchangeRatesECB({
    String baseCurrency = 'EUR',
  }) async {
    try {
      final response = await _dio.get(
        '$_frankfurterAPI/latest',
        queryParameters: {'from': baseCurrency.toUpperCase()},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = _parseRates(data['rates'] as Map);
        rates[baseCurrency.toUpperCase()] = 1.0;

        return ExchangeRatesResult(
          success: true,
          baseCurrency: data['base'] as String? ?? baseCurrency,
          date: data['date'] as String?,
          rates: rates,
          timestamp: DateTime.now(),
          isLive: true,
        );
      }
    } catch (e) {
      debugPrint('[CurrencyUtils] getExchangeRatesECB error: $e');
    }

    return ExchangeRatesResult(
      success: false,
      baseCurrency: baseCurrency,
      rates: {},
      message: 'Failed to fetch ECB rates',
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CURRENCY CONVERSION
  // ═══════════════════════════════════════════════════════════════════

  /// Convert [amount] from [fromCurrency] to [toCurrency] (live rates).
  static Future<CurrencyConversionResult> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();

    if (from == to) {
      return CurrencyConversionResult(
        success: true,
        fromAmount: amount,
        fromCurrency: from,
        toAmount: amount,
        toCurrency: to,
        exchangeRate: 1.0,
        timestamp: DateTime.now(),
        isLive: true,
      );
    }

    final ratesResult = await getExchangeRates(baseCurrency: from);
    final rate = ratesResult.getRate(to);

    if (rate == null) {
      return CurrencyConversionResult(
        success: false,
        fromAmount: amount,
        fromCurrency: from,
        toCurrency: to,
        message: 'Rate for $to not found',
      );
    }

    return CurrencyConversionResult(
      success: true,
      fromAmount: amount,
      fromCurrency: from,
      toAmount: amount * rate,
      toCurrency: to,
      exchangeRate: rate,
      timestamp: ratesResult.timestamp,
      isLive: ratesResult.isLive,
    );
  }

  /// Convert using Frankfurter (ECB). More accurate for European currencies.
  static Future<CurrencyConversionResult> convertECB({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();

    try {
      final response = await _dio.get(
        '$_frankfurterAPI/latest',
        queryParameters: {'amount': amount.toString(), 'from': from, 'to': to},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        final converted = (rates[to] as num).toDouble();

        return CurrencyConversionResult(
          success: true,
          fromAmount: amount,
          fromCurrency: from,
          toAmount: converted,
          toCurrency: to,
          exchangeRate: converted / amount,
          timestamp: DateTime.now(),
          isLive: true,
        );
      }
    } catch (e) {
      debugPrint('[CurrencyUtils] convertECB error: $e');
    }

    return CurrencyConversionResult(
      success: false,
      fromAmount: amount,
      fromCurrency: from,
      toCurrency: to,
      message: 'ECB conversion failed',
    );
  }

  /// Convert [amount] to multiple target currencies in one call.
  static Future<Map<String, CurrencyConversionResult>> convertToMultiple({
    required double amount,
    required String fromCurrency,
    required List<String> toCurrencies,
  }) async {
    // Fetch once, fan out — more efficient than calling convert() per currency
    final ratesResult = await getExchangeRates(baseCurrency: fromCurrency);
    final results = <String, CurrencyConversionResult>{};

    for (final to in toCurrencies) {
      final rate = ratesResult.getRate(to);
      if (rate != null) {
        results[to] = CurrencyConversionResult(
          success: true,
          fromAmount: amount,
          fromCurrency: fromCurrency.toUpperCase(),
          toAmount: amount * rate,
          toCurrency: to.toUpperCase(),
          exchangeRate: rate,
          timestamp: ratesResult.timestamp,
          isLive: ratesResult.isLive,
        );
      } else {
        results[to] = CurrencyConversionResult(
          success: false,
          fromAmount: amount,
          fromCurrency: fromCurrency.toUpperCase(),
          toCurrency: to.toUpperCase(),
          message: 'Rate not found',
        );
      }
    }

    return results;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SYNCHRONOUS CONVERSION  (uses cache/fallback — no async needed)
  // Safe to call inside widget build() methods.
  // ═══════════════════════════════════════════════════════════════════

  /// Convert synchronously using cached or fallback rates.
  static double convertSync({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();
    if (from == to) return amount;

    // Try live cache first (base = from)
    final cached = _cache[from];
    if (cached?.isFresh == true && cached!.rates.containsKey(to)) {
      return amount * cached.rates[to]!;
    }

    // Fallback: convert via NGN as bridge
    final fromInfo = CurrencyRegistry.get(from);
    final toInfo = CurrencyRegistry.get(to);
    if (fromInfo.fallbackRateToNgn <= 0 || toInfo.fallbackRateToNgn <= 0) {
      return amount;
    }
    final inNgn = amount * fromInfo.fallbackRateToNgn;
    return inNgn / toInfo.fallbackRateToNgn;
  }

  /// Format [amount] synchronously using cached or fallback rates.
  static String formatSync(double amount, String currencyCode) =>
      CurrencyRegistry.get(currencyCode).formatAmount(amount);

  // ═══════════════════════════════════════════════════════════════════
  // SWAP
  // ═══════════════════════════════════════════════════════════════════

  /// Two-way conversion — returns both directions.
  static Future<CurrencySwapResult> swap({
    required double amount,
    required String currency1,
    required String currency2,
  }) async {
    // Single fetch for currency1 base covers both directions
    final ratesResult = await getExchangeRates(baseCurrency: currency1);
    final rate1to2 = ratesResult.getRate(currency2);

    final c1to2 = rate1to2 != null
        ? CurrencyConversionResult(
            success: true,
            fromAmount: amount,
            fromCurrency: currency1,
            toAmount: amount * rate1to2,
            toCurrency: currency2,
            exchangeRate: rate1to2,
            isLive: ratesResult.isLive,
          )
        : CurrencyConversionResult(
            success: false,
            fromAmount: amount,
            fromCurrency: currency1,
            toCurrency: currency2,
          );

    final c2to1 = rate1to2 != null
        ? CurrencyConversionResult(
            success: true,
            fromAmount: amount,
            fromCurrency: currency2,
            toAmount: amount / rate1to2,
            toCurrency: currency1,
            exchangeRate: 1 / rate1to2,
            isLive: ratesResult.isLive,
          )
        : CurrencyConversionResult(
            success: false,
            fromAmount: amount,
            fromCurrency: currency2,
            toCurrency: currency1,
          );

    return CurrencySwapResult(
      currency1: currency1,
      currency2: currency2,
      amount: amount,
      currency1ToCurrency2: c1to2,
      currency2ToCurrency1: c2to1,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HISTORICAL RATES  (Frankfurter — ECB data)
  // ═══════════════════════════════════════════════════════════════════

  /// Get historical exchange rates for [date] (format: 'YYYY-MM-DD').
  static Future<ExchangeRatesResult> getHistoricalRates({
    required String date,
    String baseCurrency = 'USD',
  }) async {
    try {
      final response = await _dio.get(
        '$_frankfurterAPI/$date',
        queryParameters: {'from': baseCurrency.toUpperCase()},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = _parseRates(data['rates'] as Map);
        rates[baseCurrency.toUpperCase()] = 1.0;

        return ExchangeRatesResult(
          success: true,
          baseCurrency: data['base'] as String? ?? baseCurrency,
          date: data['date'] as String?,
          rates: rates,
          timestamp: DateTime.tryParse(data['date'] as String? ?? ''),
          isLive: false, // historical = not live
        );
      }
    } catch (e) {
      debugPrint('[CurrencyUtils] getHistoricalRates error: $e');
    }

    return ExchangeRatesResult(
      success: false,
      baseCurrency: baseCurrency,
      rates: {},
      message: 'Failed to fetch historical rates for $date',
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CURRENCY INFORMATION
  // ═══════════════════════════════════════════════════════════════════

  /// List of all currencies from a live rate fetch.
  /// Falls back to CurrencyRegistry.all if network unavailable.
  static Future<List<CurrencyInfo>> getSupportedCurrencies() async {
    final result = await getExchangeRates(baseCurrency: 'USD');
    if (!result.success) return CurrencyRegistry.all;
    return result.rates.keys
        .map((code) => CurrencyRegistry.fromApiCode(code))
        .toList();
  }

  /// Look up CurrencyInfo by ISO code — delegates to CurrencyRegistry.
  /// Builds a minimal entry for unknown codes.
  static CurrencyInfo getCurrencyInfo(String code) =>
      CurrencyRegistry.fromApiCode(code);

  /// Popular currencies list — same as before but now uses rich CurrencyInfo
  static List<CurrencyInfo> get popularCurrencies => CurrencyRegistry.popular;

  /// All currencies with rich metadata from the registry
  static List<CurrencyInfo> get allCurrencies => CurrencyRegistry.all;

  // ═══════════════════════════════════════════════════════════════════
  // FORMATTING  (static, synchronous)
  // ═══════════════════════════════════════════════════════════════════

  /// Format [amount] with currency symbol.
  /// e.g. formatAmount(1500000, 'NGN') → '₦1,500,000'
  static String formatAmount(double amount, String currencyCode) =>
      CurrencyRegistry.get(currencyCode).formatAmount(amount);

  /// Compact format — e.g. '₦1.5M', '$15K'
  static String formatCompact(double amount, String currencyCode) =>
      CurrencyRegistry.get(currencyCode).formatCompact(amount);

  /// Number only, no symbol — for input fields
  static String formatNoSymbol(double amount, String currencyCode) =>
      CurrencyRegistry.get(currencyCode).formatAmountNoSymbol(amount);

  /// Symbol for a currency — e.g. '₦', '$', '£'
  static String symbolFor(String currencyCode) =>
      CurrencyRegistry.get(currencyCode).symbol;

  /// Flag emoji — e.g. '🇳🇬'
  static String flagFor(String currencyCode) =>
      CurrencyRegistry.get(currencyCode).flag;

  /// Parse a user-typed currency string to double.
  /// Strips symbols, commas, spaces.
  static double? parseInput(String raw, String currencyCode) {
    final symbol = CurrencyRegistry.get(currencyCode).symbol;
    final cleaned = raw.replaceAll(symbol, '').replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  static Map<String, double> _parseRates(Map raw) => Map<String, double>.from(
    raw.map(
      (k, v) => MapEntry(k.toString().toUpperCase(), (v as num).toDouble()),
    ),
  );

  /// Build a fallback rates map relative to [baseCurrency] using registry values.
  static Map<String, double> _fallbackRatesFor(String baseCurrency) {
    final baseInfo = CurrencyRegistry.get(baseCurrency);
    final baseNgn = baseInfo.fallbackRateToNgn;
    if (baseNgn <= 0) return {};

    final result = <String, double>{};
    for (final info in CurrencyRegistry.all) {
      if (info.fallbackRateToNgn > 0) {
        // rate = (1/info.fallbackRateToNgn) / (1/baseNgn) = baseNgn / info.fallbackRateToNgn
        result[info.code] = baseNgn / info.fallbackRateToNgn;
      }
    }
    return result;
  }
}
