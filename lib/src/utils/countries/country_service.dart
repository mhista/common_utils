import 'package:flutter/foundation.dart';
import 'country_model.dart';
import 'country_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Source enum
// ─────────────────────────────────────────────────────────────────────────────

/// Selects where [CountryService] loads country data from.
enum CountrySource {
  /// Built-in static list — zero network, instant, works fully offline.
  /// Contains: name, code, dial code, flag, region, sub-region.
  staticData,

  /// restcountries.com v3.1 — free, no API key required.
  /// Adds: capital, currency, languages, population, official name.
  restCountriesApi,

  /// countrystatecity.in — requires an API key for states & cities.
  /// Also provides richer country data.
  countryStateCityApi,
}

// ─────────────────────────────────────────────────────────────────────────────
// CountryService
// ─────────────────────────────────────────────────────────────────────────────

/// Unified service for country, state, and city data.
///
/// Supports three data sources via [CountrySource].
/// Switch sources without changing call-site code.
///
/// ─────────────────────────────────────────────────────────
/// ## Setup
///
/// **Offline only (default — no setup needed)**
/// ```dart
/// // Anywhere in your app:
/// final service = CountryService();
/// ```
///
/// **With REST Countries API** (free, no key)
/// ```dart
/// CountryService.init(
///   source: CountrySource.restCountriesApi,
///   httpClient: MyHttpClient(), // inject your package:http or dio client
/// );
/// ```
///
/// **With CountryStateCity API** (states + cities)
/// ```dart
/// CountryService.init(
///   source: CountrySource.countryStateCityApi,
///   cscApiKey: 'your-key-from-countrystatecity.in',
///   httpClient: MyHttpClient(),
/// );
/// ```
///
/// ─────────────────────────────────────────────────────────
/// ## Usage after init
///
/// ```dart
/// // Countries
/// final result = await CountryService.instance.getAllCountries();
/// if (result.success) {
///   for (final c in result.countries) { ... }
/// }
///
/// // States (offline — NG, US, GB, CA, AU, ZA, GH, KE included)
/// final states = await CountryService.instance.getStates('NG');
///
/// // States (live — any country)
/// final states = await CountryService.instance.getStates('BR');
///
/// // Cities (requires countryStateCityApi)
/// final cities = await CountryService.instance.getCities(
///   countryCode: 'NG',
///   stateCode: 'LA',
/// );
///
/// // Search
/// final hits = await CountryService.instance.searchCountries('nig');
///
/// // Single country
/// final nigeria = await CountryService.instance.getCountryByCode('NG');
///
/// // Dial codes
/// final dials = CountryService.instance.getDialCodes();
///
/// // Popular countries (curated list, instant)
/// final popular = CountryService.instance.popularCountries;
/// ```
class CountryService {
  // ── Singleton ──────────────────────────────────────────────────────────────

  static CountryService _instance = const CountryService._();

  /// The global instance configured via [CountryService.init].
  /// Defaults to [CountrySource.staticData] — no setup needed.
  static CountryService get instance => _instance;

  // ── Global init ────────────────────────────────────────────────────────────

  /// Configure the global [instance] once at app startup.
  ///
  /// Call this in `main()` or your dependency injection setup before
  /// any component tries to use country data.
  ///
  /// ```dart
  /// void main() {
  ///   CountryService.init(
  ///     source: CountrySource.restCountriesApi,
  ///     httpClient: HttpPackageClient(),
  ///   );
  ///   runApp(const MyApp());
  /// }
  /// ```
  static void init({
    CountrySource source = CountrySource.staticData,
    String? cscApiKey,
    CountryHttpClient? httpClient,
  }) {
    _instance = CountryService._(
      source: source,
      cscApiKey: cscApiKey,
      httpClient: httpClient,
    );
  }

  // ── Construction ───────────────────────────────────────────────────────────

  final CountrySource source;
  final String? _cscApiKey;
  final CountryHttpClient? _httpClient;

  const CountryService._({
    this.source = CountrySource.staticData,
    String? cscApiKey,
    CountryHttpClient? httpClient,
  })  : _cscApiKey = cscApiKey,
        _httpClient = httpClient;

  /// Create a one-off instance (useful for testing or scoped use).
  const CountryService({
    this.source = CountrySource.staticData,
    String? cscApiKey,
    CountryHttpClient? httpClient,
  })  : _cscApiKey = cscApiKey,
        _httpClient = httpClient;

  // ── Response cache ─────────────────────────────────────────────────────────
  // Cache API responses per source so we only hit the network once per session.

  static CountryListResult? _cachedCountries;
  static CountrySource? _cacheSource;

  static void clearCache() {
    _cachedCountries = null;
    _cacheSource = null;
  }

  // ── API URLs ───────────────────────────────────────────────────────────────

  static const _restBase = 'https://restcountries.com/v3.1';
  static const _cscBase  = 'https://api.countrystatecity.in/v1';

  // ─────────────────────────────────────────────────────────────────────────
  // Countries
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns all countries from the configured [source], sorted A→Z.
  ///
  /// API results are cached for the lifetime of the app session.
  /// Call [clearCache] to force a fresh fetch.
  Future<CountryListResult> getAllCountries() async {
    // Static source — instant, no cache needed
    if (source == CountrySource.staticData) {
      return CountryListResult(
        success: true,
        countries: CountryData.all,
      );
    }

    // Return cache if source hasn't changed
    if (_cachedCountries != null && _cacheSource == source) {
      return _cachedCountries!;
    }

    try {
      final countries = source == CountrySource.restCountriesApi
          ? await _fetchRestCountries()
          : await _fetchCSCCountries();

      final result = CountryListResult(success: true, countries: countries);
      _cachedCountries = result;
      _cacheSource = source;
      return result;
    } catch (e, st) {
      debugPrint('[CountryService] getAllCountries error: $e\n$st');
      return CountryListResult(
        success: false,
        countries: [],
        message: e.toString(),
      );
    }
  }

  /// Returns a single country by ISO 3166-1 alpha-2 [code].
  ///
  /// For [CountrySource.staticData] this is an O(1) map lookup.
  Future<Country?> getCountryByCode(String code) async {
    final upper = code.toUpperCase();
    if (source == CountrySource.staticData) {
      return CountryData.byCode[upper];
    }
    final result = await getAllCountries();
    if (!result.success) return null;
    try {
      return result.countries.firstWhere((c) => c.code == upper);
    } catch (_) {
      return null;
    }
  }

  /// Case-insensitive search across name, ISO code, and dial code.
  ///
  /// For [CountrySource.staticData] this uses [CountryData.search] directly —
  /// no network call, O(n) with early-exit.
  Future<List<Country>> searchCountries(String query, {int? limit}) async {
    if (source == CountrySource.staticData) {
      return CountryData.search(query, limit: limit);
    }
    // Search against the cached/fetched list
    final result = await getAllCountries();
    if (!result.success) return [];
    if (query.isEmpty) return result.countries;
    final q = query.toLowerCase().trim();
    final out = <Country>[];
    for (final c in result.countries) {
      if (c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase() == q ||
          c.dialCode.contains(q)) {
        out.add(c);
        if (limit != null && out.length >= limit) break;
      }
    }
    return out;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // States
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns states / administrative regions for [countryCode].
  ///
  /// For the countries below, offline data is available regardless of [source]:
  /// `NG` (37), `US` (51), `GB` (4), `CA` (13), `AU` (8), `ZA` (9),
  /// `GH` (16), `KE` (47).
  ///
  /// For all other countries, [CountrySource.countryStateCityApi] is required.
  Future<StateListResult> getStates(String countryCode) async {
    final code = countryCode.toUpperCase();

    // Always serve from local data when available — faster + offline
    final local = _offlineStates(code);
    if (local != null) {
      return StateListResult(
        success: true,
        states: local,
        countryCode: code,
      );
    }

    if (source != CountrySource.countryStateCityApi) {
      return StateListResult(
        success: false,
        states: [],
        countryCode: code,
        message: 'No offline data for $code. '
            'Use CountrySource.countryStateCityApi to fetch live state data.',
      );
    }

    try {
      final states = await _fetchCSCStates(code);
      return StateListResult(success: true, states: states, countryCode: code);
    } catch (e) {
      debugPrint('[CountryService] getStates($code) error: $e');
      return StateListResult(
        success: false,
        states: [],
        countryCode: code,
        message: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cities
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns cities in [stateCode] within [countryCode].
  /// Requires [CountrySource.countryStateCityApi].
  Future<CityListResult> getCities({
    required String countryCode,
    required String stateCode,
  }) async {
    final cc = countryCode.toUpperCase();
    final sc = stateCode.toUpperCase();

    if (source != CountrySource.countryStateCityApi) {
      return CityListResult(
        success: false,
        cities: [],
        countryCode: cc,
        stateCode: sc,
        message: 'City data requires CountrySource.countryStateCityApi.',
      );
    }

    try {
      final cities = await _fetchCSCCities(cc, sc);
      return CityListResult(
        success: true,
        cities: cities,
        countryCode: cc,
        stateCode: sc,
      );
    } catch (e) {
      debugPrint('[CountryService] getCities($cc/$sc) error: $e');
      return CityListResult(
        success: false,
        cities: [],
        countryCode: cc,
        stateCode: sc,
        message: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Convenience accessors
  // ─────────────────────────────────────────────────────────────────────────

  /// Curated popular countries — instant, no network call.
  List<Country> get popularCountries => CountryData.popular;

  /// All countries as dial-code entries — instant from static data.
  List<DialCode> getDialCodes() =>
      CountryData.all.map(DialCode.fromCountry).toList();

  /// All countries grouped by region, sorted A→Z within each group.
  Map<String, List<Country>> get byRegion {
    final m = <String, List<Country>>{};
    for (final c in CountryData.all) {
      (m[c.region ?? 'Other'] ??= []).add(c);
    }
    return m;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private — REST Countries
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Country>> _fetchRestCountries() async {
    final client = _requireClient();
    final json = await client.get('$_restBase/all') as List;
    return (json.cast<Map<String, dynamic>>())
        .map(Country.fromRestCountriesJson)
        .where((c) => c.code.isNotEmpty && c.name.isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private — CountryStateCity
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, String> get _cscHeaders {
    _requireCSCKey();
    return {'X-CSCAPI-KEY': _cscApiKey!};
  }

  Future<List<Country>> _fetchCSCCountries() async {
    final client = _requireClient();
    final json = await client.get(
      '$_cscBase/countries',
      headers: _cscHeaders,
    ) as List;
    return (json.cast<Map<String, dynamic>>())
        .map(Country.fromCSCJson)
        .where((c) => c.code.isNotEmpty && c.name.isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<CountryState>> _fetchCSCStates(String countryCode) async {
    final client = _requireClient();
    final json = await client.get(
      '$_cscBase/countries/$countryCode/states',
      headers: _cscHeaders,
    ) as List;
    return (json.cast<Map<String, dynamic>>())
        .map(CountryState.fromJson)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<CountryCity>> _fetchCSCCities(
    String countryCode,
    String stateCode,
  ) async {
    final client = _requireClient();
    final json = await client.get(
      '$_cscBase/countries/$countryCode/states/$stateCode/cities',
      headers: _cscHeaders,
    ) as List;
    return (json.cast<Map<String, dynamic>>())
        .map(CountryCity.fromJson)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Guards
  // ─────────────────────────────────────────────────────────────────────────

  CountryHttpClient _requireClient() {
    if (_httpClient == null) {
      throw CountryServiceException(
        'No HTTP client provided.\n\n'
        'Pass a CountryHttpClient when calling CountryService.init():\n\n'
        '  CountryService.init(\n'
        '    source: CountrySource.restCountriesApi,\n'
        '    httpClient: MyHttpClient(),\n'
        '  );\n\n'
        'See CountryHttpClient for implementation examples.',
      );
    }
    return _httpClient!;
  }

  void _requireCSCKey() {
    if (_cscApiKey == null || _cscApiKey!.isEmpty) {
      throw CountryServiceException(
        'No CountryStateCity API key provided.\n\n'
        'Pass cscApiKey when calling CountryService.init():\n\n'
        '  CountryService.init(\n'
        '    source: CountrySource.countryStateCityApi,\n'
        '    cscApiKey: "your-key",\n'
        '    httpClient: MyHttpClient(),\n'
        '  );\n\n'
        'Get a free key at https://countrystatecity.in/',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offline state data
  // ─────────────────────────────────────────────────────────────────────────

  static List<CountryState>? _offlineStates(String code) => switch (code) {
        'NG' => _ngStates,
        'US' => _usStates,
        'GB' => _gbRegions,
        'CA' => _caProvinces,
        'AU' => _auStates,
        'ZA' => _zaProvinces,
        'GH' => _ghRegions,
        'KE' => _keCounties,
        _ => null,
      };

  // Nigeria — 36 states + FCT
  static const _ngStates = [
    CountryState(name: 'Abia',        code: 'AB', countryCode: 'NG'),
    CountryState(name: 'Adamawa',     code: 'AD', countryCode: 'NG'),
    CountryState(name: 'Akwa Ibom',   code: 'AK', countryCode: 'NG'),
    CountryState(name: 'Anambra',     code: 'AN', countryCode: 'NG'),
    CountryState(name: 'Bauchi',      code: 'BA', countryCode: 'NG'),
    CountryState(name: 'Bayelsa',     code: 'BY', countryCode: 'NG'),
    CountryState(name: 'Benue',       code: 'BE', countryCode: 'NG'),
    CountryState(name: 'Borno',       code: 'BO', countryCode: 'NG'),
    CountryState(name: 'Cross River', code: 'CR', countryCode: 'NG'),
    CountryState(name: 'Delta',       code: 'DE', countryCode: 'NG'),
    CountryState(name: 'Ebonyi',      code: 'EB', countryCode: 'NG'),
    CountryState(name: 'Edo',         code: 'ED', countryCode: 'NG'),
    CountryState(name: 'Ekiti',       code: 'EK', countryCode: 'NG'),
    CountryState(name: 'Enugu',       code: 'EN', countryCode: 'NG'),
    CountryState(name: 'FCT Abuja',   code: 'FC', countryCode: 'NG'),
    CountryState(name: 'Gombe',       code: 'GO', countryCode: 'NG'),
    CountryState(name: 'Imo',         code: 'IM', countryCode: 'NG'),
    CountryState(name: 'Jigawa',      code: 'JI', countryCode: 'NG'),
    CountryState(name: 'Kaduna',      code: 'KD', countryCode: 'NG'),
    CountryState(name: 'Kano',        code: 'KN', countryCode: 'NG'),
    CountryState(name: 'Katsina',     code: 'KT', countryCode: 'NG'),
    CountryState(name: 'Kebbi',       code: 'KE', countryCode: 'NG'),
    CountryState(name: 'Kogi',        code: 'KO', countryCode: 'NG'),
    CountryState(name: 'Kwara',       code: 'KW', countryCode: 'NG'),
    CountryState(name: 'Lagos',       code: 'LA', countryCode: 'NG'),
    CountryState(name: 'Nasarawa',    code: 'NA', countryCode: 'NG'),
    CountryState(name: 'Niger',       code: 'NI', countryCode: 'NG'),
    CountryState(name: 'Ogun',        code: 'OG', countryCode: 'NG'),
    CountryState(name: 'Ondo',        code: 'ON', countryCode: 'NG'),
    CountryState(name: 'Osun',        code: 'OS', countryCode: 'NG'),
    CountryState(name: 'Oyo',         code: 'OY', countryCode: 'NG'),
    CountryState(name: 'Plateau',     code: 'PL', countryCode: 'NG'),
    CountryState(name: 'Rivers',      code: 'RI', countryCode: 'NG'),
    CountryState(name: 'Sokoto',      code: 'SO', countryCode: 'NG'),
    CountryState(name: 'Taraba',      code: 'TA', countryCode: 'NG'),
    CountryState(name: 'Yobe',        code: 'YO', countryCode: 'NG'),
    CountryState(name: 'Zamfara',     code: 'ZA', countryCode: 'NG'),
  ];

  // United States — 50 states + DC
  static const _usStates = [
    CountryState(name: 'Alabama',              code: 'AL', countryCode: 'US'),
    CountryState(name: 'Alaska',               code: 'AK', countryCode: 'US'),
    CountryState(name: 'Arizona',              code: 'AZ', countryCode: 'US'),
    CountryState(name: 'Arkansas',             code: 'AR', countryCode: 'US'),
    CountryState(name: 'California',           code: 'CA', countryCode: 'US'),
    CountryState(name: 'Colorado',             code: 'CO', countryCode: 'US'),
    CountryState(name: 'Connecticut',          code: 'CT', countryCode: 'US'),
    CountryState(name: 'Delaware',             code: 'DE', countryCode: 'US'),
    CountryState(name: 'District of Columbia', code: 'DC', countryCode: 'US'),
    CountryState(name: 'Florida',              code: 'FL', countryCode: 'US'),
    CountryState(name: 'Georgia',              code: 'GA', countryCode: 'US'),
    CountryState(name: 'Hawaii',               code: 'HI', countryCode: 'US'),
    CountryState(name: 'Idaho',                code: 'ID', countryCode: 'US'),
    CountryState(name: 'Illinois',             code: 'IL', countryCode: 'US'),
    CountryState(name: 'Indiana',              code: 'IN', countryCode: 'US'),
    CountryState(name: 'Iowa',                 code: 'IA', countryCode: 'US'),
    CountryState(name: 'Kansas',               code: 'KS', countryCode: 'US'),
    CountryState(name: 'Kentucky',             code: 'KY', countryCode: 'US'),
    CountryState(name: 'Louisiana',            code: 'LA', countryCode: 'US'),
    CountryState(name: 'Maine',                code: 'ME', countryCode: 'US'),
    CountryState(name: 'Maryland',             code: 'MD', countryCode: 'US'),
    CountryState(name: 'Massachusetts',        code: 'MA', countryCode: 'US'),
    CountryState(name: 'Michigan',             code: 'MI', countryCode: 'US'),
    CountryState(name: 'Minnesota',            code: 'MN', countryCode: 'US'),
    CountryState(name: 'Mississippi',          code: 'MS', countryCode: 'US'),
    CountryState(name: 'Missouri',             code: 'MO', countryCode: 'US'),
    CountryState(name: 'Montana',              code: 'MT', countryCode: 'US'),
    CountryState(name: 'Nebraska',             code: 'NE', countryCode: 'US'),
    CountryState(name: 'Nevada',               code: 'NV', countryCode: 'US'),
    CountryState(name: 'New Hampshire',        code: 'NH', countryCode: 'US'),
    CountryState(name: 'New Jersey',           code: 'NJ', countryCode: 'US'),
    CountryState(name: 'New Mexico',           code: 'NM', countryCode: 'US'),
    CountryState(name: 'New York',             code: 'NY', countryCode: 'US'),
    CountryState(name: 'North Carolina',       code: 'NC', countryCode: 'US'),
    CountryState(name: 'North Dakota',         code: 'ND', countryCode: 'US'),
    CountryState(name: 'Ohio',                 code: 'OH', countryCode: 'US'),
    CountryState(name: 'Oklahoma',             code: 'OK', countryCode: 'US'),
    CountryState(name: 'Oregon',               code: 'OR', countryCode: 'US'),
    CountryState(name: 'Pennsylvania',         code: 'PA', countryCode: 'US'),
    CountryState(name: 'Rhode Island',         code: 'RI', countryCode: 'US'),
    CountryState(name: 'South Carolina',       code: 'SC', countryCode: 'US'),
    CountryState(name: 'South Dakota',         code: 'SD', countryCode: 'US'),
    CountryState(name: 'Tennessee',            code: 'TN', countryCode: 'US'),
    CountryState(name: 'Texas',                code: 'TX', countryCode: 'US'),
    CountryState(name: 'Utah',                 code: 'UT', countryCode: 'US'),
    CountryState(name: 'Vermont',              code: 'VT', countryCode: 'US'),
    CountryState(name: 'Virginia',             code: 'VA', countryCode: 'US'),
    CountryState(name: 'Washington',           code: 'WA', countryCode: 'US'),
    CountryState(name: 'West Virginia',        code: 'WV', countryCode: 'US'),
    CountryState(name: 'Wisconsin',            code: 'WI', countryCode: 'US'),
    CountryState(name: 'Wyoming',              code: 'WY', countryCode: 'US'),
  ];

  // United Kingdom
  static const _gbRegions = [
    CountryState(name: 'England',          code: 'ENG', countryCode: 'GB'),
    CountryState(name: 'Northern Ireland', code: 'NIR', countryCode: 'GB'),
    CountryState(name: 'Scotland',         code: 'SCT', countryCode: 'GB'),
    CountryState(name: 'Wales',            code: 'WLS', countryCode: 'GB'),
  ];

  // Canada — 10 provinces + 3 territories
  static const _caProvinces = [
    CountryState(name: 'Alberta',                  code: 'AB', countryCode: 'CA'),
    CountryState(name: 'British Columbia',          code: 'BC', countryCode: 'CA'),
    CountryState(name: 'Manitoba',                  code: 'MB', countryCode: 'CA'),
    CountryState(name: 'New Brunswick',             code: 'NB', countryCode: 'CA'),
    CountryState(name: 'Newfoundland and Labrador', code: 'NL', countryCode: 'CA'),
    CountryState(name: 'Northwest Territories',     code: 'NT', countryCode: 'CA'),
    CountryState(name: 'Nova Scotia',               code: 'NS', countryCode: 'CA'),
    CountryState(name: 'Nunavut',                   code: 'NU', countryCode: 'CA'),
    CountryState(name: 'Ontario',                   code: 'ON', countryCode: 'CA'),
    CountryState(name: 'Prince Edward Island',      code: 'PE', countryCode: 'CA'),
    CountryState(name: 'Quebec',                    code: 'QC', countryCode: 'CA'),
    CountryState(name: 'Saskatchewan',              code: 'SK', countryCode: 'CA'),
    CountryState(name: 'Yukon',                     code: 'YT', countryCode: 'CA'),
  ];

  // Australia — 6 states + 2 territories
  static const _auStates = [
    CountryState(name: 'Australian Capital Territory', code: 'ACT', countryCode: 'AU'),
    CountryState(name: 'New South Wales',              code: 'NSW', countryCode: 'AU'),
    CountryState(name: 'Northern Territory',           code: 'NT',  countryCode: 'AU'),
    CountryState(name: 'Queensland',                   code: 'QLD', countryCode: 'AU'),
    CountryState(name: 'South Australia',              code: 'SA',  countryCode: 'AU'),
    CountryState(name: 'Tasmania',                     code: 'TAS', countryCode: 'AU'),
    CountryState(name: 'Victoria',                     code: 'VIC', countryCode: 'AU'),
    CountryState(name: 'Western Australia',            code: 'WA',  countryCode: 'AU'),
  ];

  // South Africa — 9 provinces
  static const _zaProvinces = [
    CountryState(name: 'Eastern Cape',  code: 'EC',  countryCode: 'ZA'),
    CountryState(name: 'Free State',    code: 'FS',  countryCode: 'ZA'),
    CountryState(name: 'Gauteng',       code: 'GT',  countryCode: 'ZA'),
    CountryState(name: 'KwaZulu-Natal', code: 'KZN', countryCode: 'ZA'),
    CountryState(name: 'Limpopo',       code: 'LP',  countryCode: 'ZA'),
    CountryState(name: 'Mpumalanga',    code: 'MP',  countryCode: 'ZA'),
    CountryState(name: 'North West',    code: 'NW',  countryCode: 'ZA'),
    CountryState(name: 'Northern Cape', code: 'NC',  countryCode: 'ZA'),
    CountryState(name: 'Western Cape',  code: 'WC',  countryCode: 'ZA'),
  ];

  // Ghana — 16 regions
  static const _ghRegions = [
    CountryState(name: 'Ahafo',          code: 'AF', countryCode: 'GH'),
    CountryState(name: 'Ashanti',        code: 'AH', countryCode: 'GH'),
    CountryState(name: 'Bono',           code: 'BO', countryCode: 'GH'),
    CountryState(name: 'Bono East',      code: 'BE', countryCode: 'GH'),
    CountryState(name: 'Central',        code: 'CP', countryCode: 'GH'),
    CountryState(name: 'Eastern',        code: 'EP', countryCode: 'GH'),
    CountryState(name: 'Greater Accra',  code: 'AA', countryCode: 'GH'),
    CountryState(name: 'North East',     code: 'NE', countryCode: 'GH'),
    CountryState(name: 'Northern',       code: 'NP', countryCode: 'GH'),
    CountryState(name: 'Oti',            code: 'OT', countryCode: 'GH'),
    CountryState(name: 'Savannah',       code: 'SV', countryCode: 'GH'),
    CountryState(name: 'Upper East',     code: 'UE', countryCode: 'GH'),
    CountryState(name: 'Upper West',     code: 'UW', countryCode: 'GH'),
    CountryState(name: 'Volta',          code: 'TV', countryCode: 'GH'),
    CountryState(name: 'Western',        code: 'WP', countryCode: 'GH'),
    CountryState(name: 'Western North',  code: 'WN', countryCode: 'GH'),
  ];

  // Kenya — 47 counties
  static const _keCounties = [
    CountryState(name: 'Baringo',         code: '30', countryCode: 'KE'),
    CountryState(name: 'Bomet',           code: '36', countryCode: 'KE'),
    CountryState(name: 'Bungoma',         code: '39', countryCode: 'KE'),
    CountryState(name: 'Busia',           code: '40', countryCode: 'KE'),
    CountryState(name: 'Elgeyo-Marakwet', code: '28', countryCode: 'KE'),
    CountryState(name: 'Embu',            code: '14', countryCode: 'KE'),
    CountryState(name: 'Garissa',         code: '07', countryCode: 'KE'),
    CountryState(name: 'Homa Bay',        code: '43', countryCode: 'KE'),
    CountryState(name: 'Isiolo',          code: '11', countryCode: 'KE'),
    CountryState(name: 'Kajiado',         code: '34', countryCode: 'KE'),
    CountryState(name: 'Kakamega',        code: '37', countryCode: 'KE'),
    CountryState(name: 'Kericho',         code: '35', countryCode: 'KE'),
    CountryState(name: 'Kiambu',          code: '22', countryCode: 'KE'),
    CountryState(name: 'Kilifi',          code: '03', countryCode: 'KE'),
    CountryState(name: 'Kirinyaga',       code: '20', countryCode: 'KE'),
    CountryState(name: 'Kisii',           code: '45', countryCode: 'KE'),
    CountryState(name: 'Kisumu',          code: '42', countryCode: 'KE'),
    CountryState(name: 'Kitui',           code: '15', countryCode: 'KE'),
    CountryState(name: 'Kwale',           code: '02', countryCode: 'KE'),
    CountryState(name: 'Laikipia',        code: '31', countryCode: 'KE'),
    CountryState(name: 'Lamu',            code: '05', countryCode: 'KE'),
    CountryState(name: 'Machakos',        code: '16', countryCode: 'KE'),
    CountryState(name: 'Makueni',         code: '17', countryCode: 'KE'),
    CountryState(name: 'Mandera',         code: '09', countryCode: 'KE'),
    CountryState(name: 'Marsabit',        code: '10', countryCode: 'KE'),
    CountryState(name: 'Meru',            code: '12', countryCode: 'KE'),
    CountryState(name: 'Migori',          code: '44', countryCode: 'KE'),
    CountryState(name: 'Mombasa',         code: '01', countryCode: 'KE'),
    CountryState(name: "Murang'a",        code: '21', countryCode: 'KE'),
    CountryState(name: 'Nairobi',         code: '47', countryCode: 'KE'),
    CountryState(name: 'Nakuru',          code: '32', countryCode: 'KE'),
    CountryState(name: 'Nandi',           code: '29', countryCode: 'KE'),
    CountryState(name: 'Narok',           code: '33', countryCode: 'KE'),
    CountryState(name: 'Nyamira',         code: '46', countryCode: 'KE'),
    CountryState(name: 'Nyandarua',       code: '18', countryCode: 'KE'),
    CountryState(name: 'Nyeri',           code: '19', countryCode: 'KE'),
    CountryState(name: 'Samburu',         code: '25', countryCode: 'KE'),
    CountryState(name: 'Siaya',           code: '41', countryCode: 'KE'),
    CountryState(name: 'Taita-Taveta',    code: '06', countryCode: 'KE'),
    CountryState(name: 'Tana River',      code: '04', countryCode: 'KE'),
    CountryState(name: 'Tharaka-Nithi',   code: '13', countryCode: 'KE'),
    CountryState(name: 'Trans Nzoia',     code: '26', countryCode: 'KE'),
    CountryState(name: 'Turkana',         code: '23', countryCode: 'KE'),
    CountryState(name: 'Uasin Gishu',     code: '27', countryCode: 'KE'),
    CountryState(name: 'Vihiga',          code: '38', countryCode: 'KE'),
    CountryState(name: 'Wajir',           code: '08', countryCode: 'KE'),
    CountryState(name: 'West Pokot',      code: '24', countryCode: 'KE'),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// HTTP client interface
// ─────────────────────────────────────────────────────────────────────────────

/// Inject your HTTP implementation to enable live API sources.
///
/// Zero dependencies — bring your own client.
///
/// ## With package:http
/// ```dart
/// import 'dart:convert';
/// import 'package:http/http.dart' as http;
///
/// class HttpClient implements CountryHttpClient {
///   @override
///   Future<dynamic> get(String url, {Map<String, String>? headers}) async {
///     final res = await http.get(Uri.parse(url), headers: headers);
///     if (res.statusCode != 200) {
///       throw CountryServiceException('HTTP ${res.statusCode}: $url');
///     }
///     return jsonDecode(res.body);
///   }
/// }
/// ```
///
/// ## With package:dio
/// ```dart
/// import 'package:dio/dio.dart';
///
/// class DioClient implements CountryHttpClient {
///   final _dio = Dio();
///
///   @override
///   Future<dynamic> get(String url, {Map<String, String>? headers}) async {
///     final res = await _dio.get<dynamic>(
///       url,
///       options: Options(headers: headers),
///     );
///     return res.data;
///   }
/// }
/// ```
abstract interface class CountryHttpClient {
  Future<dynamic> get(String url, {Map<String, String>? headers});
}

// ─────────────────────────────────────────────────────────────────────────────
// Exception
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown by [CountryService] when a required resource or configuration
/// is missing, or when a network request fails.
class CountryServiceException implements Exception {
  final String message;
  const CountryServiceException(this.message);

  @override
  String toString() => 'CountryServiceException: $message';
}