import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Core models
// ─────────────────────────────────────────────────────────────────────────────

/// A country entry used across CommonDesigns components.
///
/// Works with all three data sources:
/// - Built-in static list ([CountryData]) — instant, offline, no setup
/// - REST Countries API (restcountries.com v3.1) — richer data, no key needed
/// - CountryStateCity API (countrystatecity.in) — states & cities, key required
@immutable
class Country {
  /// English common name (e.g. "United States").
  final String name;

  /// ISO 3166-1 alpha-2 code, always uppercase (e.g. "US").
  final String code;

  /// ISO 3166-1 alpha-3 code (e.g. "USA"). Available from API sources only.
  final String? code3;

  /// International dial code including leading + (e.g. "+1").
  final String dialCode;

  /// Unicode emoji flag derived from [code] (e.g. "🇺🇸").
  final String flag;

  /// ISO 4217 currency code (e.g. "USD"). Available from API sources only.
  final String? currency;

  /// Capital city. Available from API sources only.
  final String? capital;

  /// Continental region (e.g. "Africa", "Europe"). Available from all sources.
  final String? region;

  /// Sub-region (e.g. "Western Africa"). Available from all sources.
  final String? subregion;

  /// Official language names. Available from API sources only.
  final List<String>? languages;

  /// Population estimate. Available from API sources only.
  final int? population;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    this.code3,
    this.currency,
    this.capital,
    this.region,
    this.subregion,
    this.languages,
    this.population,
  });

  // ── Factories ──────────────────────────────────────────────────────────────

  /// Parses a restcountries.com v3.1 JSON object.
  factory Country.fromRestCountriesJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<String, dynamic>?;
    final name =
        nameMap?['common'] as String? ?? json['name'] as String? ?? '';

    final idd = json['idd'] as Map<String, dynamic>?;
    final root = idd?['root'] as String? ?? '';
    final suffixes = (idd?['suffixes'] as List?)?.cast<String>() ?? [];
    // Some countries (US, CA) share +1 — take first suffix only.
    final dialCode = suffixes.isEmpty ? root : '$root${suffixes.first}';

    final code = (json['cca2'] as String? ?? '').toUpperCase();

    return Country(
      name: name,
      code: code,
      code3: json['cca3'] as String?,
      dialCode: dialCode.isEmpty ? '' : dialCode,
      flag: json['flag'] as String? ?? _emojiFlag(code),
      currency:
          (json['currencies'] as Map<String, dynamic>?)?.keys.firstOrNull,
      capital:
          ((json['capital'] as List?)?.cast<String>() ?? []).firstOrNull,
      region: json['region'] as String?,
      subregion: json['subregion'] as String?,
      languages: (json['languages'] as Map<String, dynamic>?)
          ?.values
          .cast<String>()
          .toList(),
      population: json['population'] as int?,
    );
  }

  /// Parses a countrystatecity.in country JSON object.
  factory Country.fromCSCJson(Map<String, dynamic> json) {
    final code = (json['iso2'] as String? ?? '').toUpperCase();
    // CSC phonecode may omit the leading +
    var dial = (json['phonecode'] as String? ?? '').trim();
    if (dial.isNotEmpty && !dial.startsWith('+')) dial = '+$dial';

    return Country(
      name: json['name'] as String? ?? '',
      code: code,
      code3: json['iso3'] as String?,
      dialCode: dial,
      flag: _emojiFlag(code),
      currency: json['currency'] as String?,
      capital: json['capital'] as String?,
      region: json['region'] as String?,
      subregion: json['subregion'] as String?,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Builds an emoji flag from a 2-letter ISO code.
  static String _emojiFlag(String code) {
    if (code.length != 2) return '';
    return String.fromCharCodes(
      code.toUpperCase().codeUnits.map((c) => c - 0x41 + 0x1F1E6),
    );
  }

  Country copyWith({
    String? name,
    String? code,
    String? code3,
    String? dialCode,
    String? flag,
    String? currency,
    String? capital,
    String? region,
    String? subregion,
    List<String>? languages,
    int? population,
  }) =>
      Country(
        name: name ?? this.name,
        code: code ?? this.code,
        code3: code3 ?? this.code3,
        dialCode: dialCode ?? this.dialCode,
        flag: flag ?? this.flag,
        currency: currency ?? this.currency,
        capital: capital ?? this.capital,
        region: region ?? this.region,
        subregion: subregion ?? this.subregion,
        languages: languages ?? this.languages,
        population: population ?? this.population,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Country && code == other.code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$name ($dialCode)';
}

// ─────────────────────────────────────────────────────────────────────────────
// State / Region
// ─────────────────────────────────────────────────────────────────────────────

/// An administrative state or region within a country.
@immutable
class CountryState {
  final String name;

  /// ISO 3166-2 sub-division code (e.g. "LA" for Lagos State).
  final String code;

  /// Parent country's ISO 3166-1 alpha-2 code.
  final String? countryCode;

  const CountryState({
    required this.name,
    required this.code,
    this.countryCode,
  });

  factory CountryState.fromJson(Map<String, dynamic> json) => CountryState(
        name: json['name'] as String? ?? '',
        code: (json['iso2'] as String? ??
            json['code'] as String? ??
            ''),
        countryCode: json['country_code'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryState &&
          code == other.code &&
          countryCode == other.countryCode);

  @override
  int get hashCode => Object.hash(code, countryCode);

  @override
  String toString() => name;
}

// ─────────────────────────────────────────────────────────────────────────────
// City
// ─────────────────────────────────────────────────────────────────────────────

/// A city within a state/country.
@immutable
class CountryCity {
  final String name;
  final String? stateCode;
  final String? countryCode;

  const CountryCity({
    required this.name,
    this.stateCode,
    this.countryCode,
  });

  factory CountryCity.fromJson(Map<String, dynamic> json) => CountryCity(
        name: json['name'] as String? ?? '',
        stateCode: json['state_code'] as String?,
        countryCode: json['country_code'] as String?,
      );

  @override
  String toString() => name;
}

// ─────────────────────────────────────────────────────────────────────────────
// Dial code convenience view
// ─────────────────────────────────────────────────────────────────────────────

/// A lightweight view of a country used in dial-code pickers.
@immutable
class DialCode {
  final String country;
  final String code;
  final String dialCode;
  final String flag;

  const DialCode({
    required this.country,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  factory DialCode.fromCountry(Country c) => DialCode(
        country: c.name,
        code: c.code,
        dialCode: c.dialCode,
        flag: c.flag,
      );

  /// e.g. "🇳🇬 +234"
  String get display => '$flag $dialCode';

  /// e.g. "🇳🇬 Nigeria (+234)"
  String get fullDisplay => '$flag $country ($dialCode)';

  @override
  String toString() => '$country ($dialCode)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Typed result wrappers  (mirrors CountryUtils style)
// ─────────────────────────────────────────────────────────────────────────────

/// Result wrapper for a list of [Country].
class CountryListResult {
  final bool success;
  final List<Country> countries;
  final String? message;

  const CountryListResult({
    required this.success,
    required this.countries,
    this.message,
  });

  bool get isEmpty => countries.isEmpty;
  int get count => countries.length;
}

/// Result wrapper for a list of [CountryState].
class StateListResult {
  final bool success;
  final List<CountryState> states;
  final String countryCode;
  final String? message;

  const StateListResult({
    required this.success,
    required this.states,
    required this.countryCode,
    this.message,
  });

  bool get isEmpty => states.isEmpty;
}

/// Result wrapper for a list of [CountryCity].
class CityListResult {
  final bool success;
  final List<CountryCity> cities;
  final String countryCode;
  final String stateCode;
  final String? message;

  const CityListResult({
    required this.success,
    required this.cities,
    required this.countryCode,
    required this.stateCode,
    this.message,
  });

  bool get isEmpty => cities.isEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────
// Iterable extension (Dart <3.0 compat)
// ─────────────────────────────────────────────────────────────────────────────

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}