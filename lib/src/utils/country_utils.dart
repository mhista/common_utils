import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Country Utilities
/// Fetch real-time countries, states, and cities data
class CountryUtils {
  CountryUtils._();

  static final Dio _dio = Dio();
  
  // Free API endpoints (no authentication required)
  static const String _countriesAPI = 'https://restcountries.com/v3.1';
  static const String _countryStateCityAPI = 'https://api.countrystatecity.in/v1';
  
  // Optional: CountryStateCity API key for better rate limits
  static String? _cscApiKey;

  /// Initialize with API key (optional but recommended)
  /// Get free API key from https://countrystatecity.in/
  static void init({String? cscApiKey}) {
    _cscApiKey = cscApiKey;
    if (_cscApiKey != null) {
      _dio.options.headers['X-CSCAPI-KEY'] = _cscApiKey;
    }
  }

  // ==================== Get Countries ====================

  /// Get all countries
  static Future<CountryListResult> getAllCountries() async {
    try {
      final response = await _dio.get('$_countriesAPI/all');

      if (response.statusCode == 200) {
        final data = response.data as List;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        
        // Sort alphabetically
        countries.sort((a, b) => a.name.compareTo(b.name));

        return CountryListResult(
          success: true,
          countries: countries,
        );
      }

      return CountryListResult(
        success: false,
        countries: [],
        message: 'Failed to fetch countries',
      );
    } catch (e) {
      return CountryListResult(
        success: false,
        countries: [],
        message: e.toString(),
      );
    }
  }

  /// Get country by name
  static Future<Country?> getCountryByName(String name) async {
    try {
      final response = await _dio.get('$_countriesAPI/name/$name');

      if (response.statusCode == 200) {
        final data = response.data as List;
        if (data.isNotEmpty) {
          return Country.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get country by code (ISO 2 or 3 letter code)
  static Future<Country?> getCountryByCode(String code) async {
    try {
      final response = await _dio.get('$_countriesAPI/alpha/$code');

      if (response.statusCode == 200) {
        return Country.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Search countries
  static Future<List<Country>> searchCountries(String query) async {
    final result = await getAllCountries();
    
    if (!result.success) return [];

    return result.countries.where((country) {
      return country.name.toLowerCase().contains(query.toLowerCase()) ||
          country.code.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ==================== Get States/Regions ====================

  /// Get states for a country using CountryStateCity API
  static Future<StateListResult> getStates(String countryCode) async {
    try {
      if (_cscApiKey == null) {
        throw CountryUtilsException(
          'CSC API key required. Call CountryUtils.init(cscApiKey: "your-key")',
        );
      }

      final response = await _dio.get(
        '$_countryStateCityAPI/countries/${countryCode.toUpperCase()}/states',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        final states = data.map((json) => StateRegion.fromJson(json)).toList();
        
        states.sort((a, b) => a.name.compareTo(b.name));

        return StateListResult(
          success: true,
          states: states,
          countryCode: countryCode,
        );
      }

      return StateListResult(
        success: false,
        states: [],
        countryCode: countryCode,
        message: 'Failed to fetch states',
      );
    } catch (e) {
      return StateListResult(
        success: false,
        states: [],
        countryCode: countryCode,
        message: e.toString(),
      );
    }
  }

  /// Get Nigerian states (predefined for offline use)
  static List<StateRegion> getNigerianStates() {
    return [
      StateRegion(name: 'Abia', code: 'AB'),
      StateRegion(name: 'Adamawa', code: 'AD'),
      StateRegion(name: 'Akwa Ibom', code: 'AK'),
      StateRegion(name: 'Anambra', code: 'AN'),
      StateRegion(name: 'Bauchi', code: 'BA'),
      StateRegion(name: 'Bayelsa', code: 'BY'),
      StateRegion(name: 'Benue', code: 'BE'),
      StateRegion(name: 'Borno', code: 'BO'),
      StateRegion(name: 'Cross River', code: 'CR'),
      StateRegion(name: 'Delta', code: 'DE'),
      StateRegion(name: 'Ebonyi', code: 'EB'),
      StateRegion(name: 'Edo', code: 'ED'),
      StateRegion(name: 'Ekiti', code: 'EK'),
      StateRegion(name: 'Enugu', code: 'EN'),
      StateRegion(name: 'FCT', code: 'FC'),
      StateRegion(name: 'Gombe', code: 'GO'),
      StateRegion(name: 'Imo', code: 'IM'),
      StateRegion(name: 'Jigawa', code: 'JI'),
      StateRegion(name: 'Kaduna', code: 'KD'),
      StateRegion(name: 'Kano', code: 'KN'),
      StateRegion(name: 'Katsina', code: 'KT'),
      StateRegion(name: 'Kebbi', code: 'KE'),
      StateRegion(name: 'Kogi', code: 'KO'),
      StateRegion(name: 'Kwara', code: 'KW'),
      StateRegion(name: 'Lagos', code: 'LA'),
      StateRegion(name: 'Nasarawa', code: 'NA'),
      StateRegion(name: 'Niger', code: 'NI'),
      StateRegion(name: 'Ogun', code: 'OG'),
      StateRegion(name: 'Ondo', code: 'ON'),
      StateRegion(name: 'Osun', code: 'OS'),
      StateRegion(name: 'Oyo', code: 'OY'),
      StateRegion(name: 'Plateau', code: 'PL'),
      StateRegion(name: 'Rivers', code: 'RI'),
      StateRegion(name: 'Sokoto', code: 'SO'),
      StateRegion(name: 'Taraba', code: 'TA'),
      StateRegion(name: 'Yobe', code: 'YO'),
      StateRegion(name: 'Zamfara', code: 'ZA'),
    ];
  }

  /// Get US states (predefined)
  static List<StateRegion> getUSStates() {
    return [
      StateRegion(name: 'Alabama', code: 'AL'),
      StateRegion(name: 'Alaska', code: 'AK'),
      StateRegion(name: 'Arizona', code: 'AZ'),
      StateRegion(name: 'Arkansas', code: 'AR'),
      StateRegion(name: 'California', code: 'CA'),
      StateRegion(name: 'Colorado', code: 'CO'),
      StateRegion(name: 'Connecticut', code: 'CT'),
      StateRegion(name: 'Delaware', code: 'DE'),
      StateRegion(name: 'Florida', code: 'FL'),
      StateRegion(name: 'Georgia', code: 'GA'),
      // ... Add all 50 states
    ];
  }

  // ==================== Get Cities ====================

  /// Get cities for a state using CountryStateCity API
  static Future<CityListResult> getCities({
    required String countryCode,
    required String stateCode,
  }) async {
    try {
      if (_cscApiKey == null) {
        throw CountryUtilsException(
          'CSC API key required. Call CountryUtils.init(cscApiKey: "your-key")',
        );
      }

      final response = await _dio.get(
        '$_countryStateCityAPI/countries/${countryCode.toUpperCase()}/states/${stateCode.toUpperCase()}/cities',
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        final cities = data.map((json) => City.fromJson(json)).toList();
        
        cities.sort((a, b) => a.name.compareTo(b.name));

        return CityListResult(
          success: true,
          cities: cities,
          countryCode: countryCode,
          stateCode: stateCode,
        );
      }

      return CityListResult(
        success: false,
        cities: [],
        countryCode: countryCode,
        stateCode: stateCode,
        message: 'Failed to fetch cities',
      );
    } catch (e) {
      return CityListResult(
        success: false,
        cities: [],
        countryCode: countryCode,
        stateCode: stateCode,
        message: e.toString(),
      );
    }
  }

  // ==================== Popular Countries ====================

  /// Get popular countries for quick access
  static List<Country> get popularCountries => [
        Country(
          name: 'Nigeria',
          code: 'NG',
          code3: 'NGA',
          dialCode: '+234',
          flag: '🇳🇬',
          currency: 'NGN',
        ),
        Country(
          name: 'United States',
          code: 'US',
          code3: 'USA',
          dialCode: '+1',
          flag: '🇺🇸',
          currency: 'USD',
        ),
        Country(
          name: 'United Kingdom',
          code: 'GB',
          code3: 'GBR',
          dialCode: '+44',
          flag: '🇬🇧',
          currency: 'GBP',
        ),
        Country(
          name: 'Ghana',
          code: 'GH',
          code3: 'GHA',
          dialCode: '+233',
          flag: '🇬🇭',
          currency: 'GHS',
        ),
        Country(
          name: 'South Africa',
          code: 'ZA',
          code3: 'ZAF',
          dialCode: '+27',
          flag: '🇿🇦',
          currency: 'ZAR',
        ),
        Country(
          name: 'Kenya',
          code: 'KE',
          code3: 'KEN',
          dialCode: '+254',
          flag: '🇰🇪',
          currency: 'KES',
        ),
      ];

  // ==================== Dial Codes ====================

  /// Get country dial codes
  static Future<List<DialCode>> getDialCodes() async {
    final result = await getAllCountries();
    
    if (!result.success) return [];

    return result.countries
        .where((c) => c.dialCode != null)
        .map((c) => DialCode(
              country: c.name,
              code: c.code,
              dialCode: c.dialCode!,
              flag: c.flag,
            ))
        .toList();
  }
}

// ==================== Models ====================

/// Country model
class Country {
  final String name;
  final String code; // ISO 3166-1 alpha-2
  final String? code3; // ISO 3166-1 alpha-3
  final String? dialCode;
  final String? flag; // Emoji flag
  final String? capital;
  final String? region;
  final String? subregion;
  final String? currency;
  final List<String>? languages;
  final int? population;

  Country({
    required this.name,
    required this.code,
    this.code3,
    this.dialCode,
    this.flag,
    this.capital,
    this.region,
    this.subregion,
    this.currency,
    this.languages,
    this.population,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final name = json['name'] is Map
        ? (json['name']['common'] as String)
        : (json['name'] as String);

    final dialCode = json['idd'] != null
        ? '${json['idd']['root'] ?? ''}${(json['idd']['suffixes'] as List?)?.first ?? ''}'
        : null;

    return Country(
      name: name,
      code: json['cca2'] as String,
      code3: json['cca3'] as String?,
      dialCode: dialCode,
      flag: json['flag'] as String?,
      capital: (json['capital'] as List?)?.first as String?,
      region: json['region'] as String?,
      subregion: json['subregion'] as String?,
      currency: (json['currencies'] as Map?)?.keys.first as String?,
      languages: (json['languages'] as Map?)?.values.cast<String>().toList(),
      population: json['population'] as int?,
    );
  }

  @override
  String toString() => name;
}

/// State/Region model
class StateRegion {
  final String name;
  final String code;
  final String? countryCode;

  StateRegion({
    required this.name,
    required this.code,
    this.countryCode,
  });

  factory StateRegion.fromJson(Map<String, dynamic> json) {
    return StateRegion(
      name: json['name'] as String,
      code: json['iso2'] as String,
      countryCode: json['country_code'] as String?,
    );
  }

  @override
  String toString() => name;
}

/// City model
class City {
  final String name;
  final String? stateCode;
  final String? countryCode;

  City({
    required this.name,
    this.stateCode,
    this.countryCode,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String,
      stateCode: json['state_code'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  @override
  String toString() => name;
}

/// Dial code model
class DialCode {
  final String country;
  final String code;
  final String dialCode;
  final String? flag;

  DialCode({
    required this.country,
    required this.code,
    required this.dialCode,
    this.flag,
  });

  String get displayText => '$flag $dialCode';
  String get fullDisplay => '$flag $country ($dialCode)';

  @override
  String toString() => '$country ($dialCode)';
}

/// Country list result
class CountryListResult {
  final bool success;
  final List<Country> countries;
  final String? message;

  CountryListResult({
    required this.success,
    required this.countries,
    this.message,
  });
}

/// State list result
class StateListResult {
  final bool success;
  final List<StateRegion> states;
  final String countryCode;
  final String? message;

  StateListResult({
    required this.success,
    required this.states,
    required this.countryCode,
    this.message,
  });
}

/// City list result
class CityListResult {
  final bool success;
  final List<City> cities;
  final String countryCode;
  final String stateCode;
  final String? message;

  CityListResult({
    required this.success,
    required this.cities,
    required this.countryCode,
    required this.stateCode,
    this.message,
  });
}

/// Country Utils Exception
class CountryUtilsException implements Exception {
  final String message;

  CountryUtilsException(this.message);

  @override
  String toString() => 'CountryUtilsException: $message';
}

/// Usage Examples
void countryUtilsExamples() async {
  // Initialize (optional but recommended for states/cities)
  CountryUtils.init(cscApiKey: 'your-api-key');

  // Get all countries
  final countries = await CountryUtils.getAllCountries();
  if (countries.success) {
    for (final country in countries.countries) {
      debugPrint('${country.flag} ${country.name} (${country.dialCode})');
    }
  }

  // Get country by code
  final nigeria = await CountryUtils.getCountryByCode('NG');
  debugPrint('${nigeria?.name} - Capital: ${nigeria?.capital}');

  // Search countries
  final _ = await CountryUtils.searchCountries('United');

  // Get states
  final states = await CountryUtils.getStates('NG');
  if (states.success) {
    for (final state in states.states) {
      debugPrint(state.name);
    }
  }

  // Get Nigerian states (offline)
  final _ = CountryUtils.getNigerianStates();

  // Get cities
  final _ = await CountryUtils.getCities(
    countryCode: 'NG',
    stateCode: 'LA', // Lagos
  );

  // Get popular countries
  for (final country in CountryUtils.popularCountries) {
    debugPrint('${country.flag} ${country.name}');
  }

  // Get dial codes
  final dialCodes = await CountryUtils.getDialCodes();
  for (final dialCode in dialCodes.take(10)) {
    debugPrint(dialCode.fullDisplay);
  }
}