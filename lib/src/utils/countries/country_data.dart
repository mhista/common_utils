import 'country_model.dart';

/// Static country dataset — 194 sovereign states.
///
/// ## What's included
/// All 193 UN member states + 2 UN observer states (Palestine, Vatican City).
///
/// ## What's excluded  (matching Google's published country list policy)
/// | Territory        | Reason                                              |
/// |------------------|-----------------------------------------------------|
/// | Kosovo (XK)      | Not universally recognised; Google lists separately |
/// | Taiwan (TW)      | Listed as a region, not a country, by Google        |
/// | Western Sahara   | Disputed, non-self-governing territory              |
/// | Overseas territories, dependencies, and uninhabited islands |        |
///
/// ## Performance
/// - [_raw] is a compile-time `const List` — zero heap allocation at startup.
/// - [all] is computed **once** on first access and cached as an unmodifiable
///   list sorted A→Z.
/// - [byCode] and [byDialCode] are also lazy singletons — each built once on
///   first access.
/// - [search] is O(n) with early-exit; for exact lookups use [byCode].
///
/// ```dart
/// // Just want the list:
/// final countries = CountryData.all;
///
/// // Exact lookup — O(1):
/// final ng = CountryData.byCode['NG'];
///
/// // Search — O(n), with optional limit:
/// final hits = CountryData.search('nige', limit: 5);
///
/// // Popular countries first:
/// final list = CountryData.withPopularFirst(CountryData.all);
///
/// // Filter by region:
/// final africa = CountryData.byRegion('Africa');
/// ```
abstract final class CountryData {
  CountryData._();

  // ── Lazy cache fields ──────────────────────────────────────────────────────

  static List<Country>? _all;
  static Map<String, Country>? _byCode;
  static Map<String, List<Country>>? _byDialCode;

  // ── Public accessors ───────────────────────────────────────────────────────

  /// Full country list, sorted A→Z. Built once, then cached.
  static List<Country> get all {
    if (_all != null) return _all!;
    final built = List<Country>.generate(
      _raw.length,
      (i) => _raw[i].toCountry(),
      growable: false,
    )..sort((a, b) => a.name.compareTo(b.name));
    return _all = List<Country>.unmodifiable(built);
  }

  /// Map from ISO 3166-1 alpha-2 → [Country]. Built once, then cached.
  static Map<String, Country> get byCode {
    if (_byCode != null) return _byCode!;
    return _byCode = {for (final c in all) c.code: c};
  }

  /// Map from dial code (e.g. "+1") → countries sharing that code.
  /// Built once, then cached.
  static Map<String, List<Country>> get byDialCode {
    if (_byDialCode != null) return _byDialCode!;
    final m = <String, List<Country>>{};
    for (final c in all) {
      (m[c.dialCode] ??= []).add(c);
    }
    return _byDialCode = Map.unmodifiable(m);
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  /// Case-insensitive search across name, ISO code, and dial code.
  /// Pass [limit] to cap results (useful for async autocomplete).
  static List<Country> search(String query, {int? limit}) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase().trim();
    final out = <Country>[];
    for (final c in all) {
      if (c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase() == q ||
          c.dialCode.contains(q)) {
        out.add(c);
        if (limit != null && out.length >= limit) break;
      }
    }
    return out;
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  /// Returns countries in [list] re-ordered so [popularCodes] appear first,
  /// followed by the remaining entries in their original order.
  static List<Country> withPopularFirst(
    List<Country> list, {
    List<String> popularCodes = const [
      'NG', 'GH', 'ZA', 'KE', 'UG', 'RW', // Africa
      'US', 'GB', 'CA', 'AU',              // English-speaking
      'IN', 'AE', 'FR', 'DE',              // Global
    ],
  }) {
    final popularSet = popularCodes.toSet();
    final popular = <Country>[];
    final rest = <Country>[];
    for (final c in list) {
      (popularSet.contains(c.code) ? popular : rest).add(c);
    }
    popular.sort(
      (a, b) =>
          popularCodes.indexOf(a.code) - popularCodes.indexOf(b.code),
    );
    return [...popular, ...rest];
  }

  /// Filters to only countries whose [Country.region] matches [region]
  /// (e.g. "Africa", "Europe", "Asia", "Americas", "Oceania").
  static List<Country> byRegion(String region) =>
      all.where((c) => c.region == region).toList();

  /// Returns the total number of countries in the static list.
  static int get count => _raw.length;

  // ── Popular countries shortcut ─────────────────────────────────────────────

  /// Curated list of globally popular countries for quick-access UI sections.
  static List<Country> get popular => withPopularFirst(
        all
            .where((c) => _popularCodes.contains(c.code))
            .toList(),
      );

  static const _popularCodes = [
    'NG', 'GH', 'ZA', 'KE', 'UG', 'RW',
    'US', 'GB', 'CA', 'AU',
    'IN', 'AE', 'FR', 'DE',
  ];

  // ── Raw data ───────────────────────────────────────────────────────────────
  //
  // Stored as compact const tuples to minimise memory footprint.
  // Country objects are materialised lazily in [all].
  //
  // Columns: name | ISO-2 | dial | region | sub-region

  static const List<_R> _raw = [
    // ── A ───────────────────────────────────────────────────────────────────
    _R('Afghanistan',                     'AF', '+93',   'Asia',    'Southern Asia'),
    _R('Albania',                         'AL', '+355',  'Europe',  'Southern Europe'),
    _R('Algeria',                         'DZ', '+213',  'Africa',  'Northern Africa'),
    _R('Andorra',                         'AD', '+376',  'Europe',  'Southern Europe'),
    _R('Angola',                          'AO', '+244',  'Africa',  'Middle Africa'),
    _R('Antigua and Barbuda',             'AG', '+1268', 'Americas','Caribbean'),
    _R('Argentina',                       'AR', '+54',   'Americas','South America'),
    _R('Armenia',                         'AM', '+374',  'Asia',    'Western Asia'),
    _R('Australia',                       'AU', '+61',   'Oceania', 'Australia and New Zealand'),
    _R('Austria',                         'AT', '+43',   'Europe',  'Western Europe'),
    _R('Azerbaijan',                      'AZ', '+994',  'Asia',    'Western Asia'),

    // ── B ───────────────────────────────────────────────────────────────────
    _R('Bahamas',                         'BS', '+1242', 'Americas','Caribbean'),
    _R('Bahrain',                         'BH', '+973',  'Asia',    'Western Asia'),
    _R('Bangladesh',                      'BD', '+880',  'Asia',    'Southern Asia'),
    _R('Barbados',                        'BB', '+1246', 'Americas','Caribbean'),
    _R('Belarus',                         'BY', '+375',  'Europe',  'Eastern Europe'),
    _R('Belgium',                         'BE', '+32',   'Europe',  'Western Europe'),
    _R('Belize',                          'BZ', '+501',  'Americas','Central America'),
    _R('Benin',                           'BJ', '+229',  'Africa',  'Western Africa'),
    _R('Bhutan',                          'BT', '+975',  'Asia',    'Southern Asia'),
    _R('Bolivia',                         'BO', '+591',  'Americas','South America'),
    _R('Bosnia and Herzegovina',          'BA', '+387',  'Europe',  'Southern Europe'),
    _R('Botswana',                        'BW', '+267',  'Africa',  'Southern Africa'),
    _R('Brazil',                          'BR', '+55',   'Americas','South America'),
    _R('Brunei',                          'BN', '+673',  'Asia',    'South-Eastern Asia'),
    _R('Bulgaria',                        'BG', '+359',  'Europe',  'Eastern Europe'),
    _R('Burkina Faso',                    'BF', '+226',  'Africa',  'Western Africa'),
    _R('Burundi',                         'BI', '+257',  'Africa',  'Eastern Africa'),

    // ── C ───────────────────────────────────────────────────────────────────
    _R('Cabo Verde',                      'CV', '+238',  'Africa',  'Western Africa'),
    _R('Cambodia',                        'KH', '+855',  'Asia',    'South-Eastern Asia'),
    _R('Cameroon',                        'CM', '+237',  'Africa',  'Middle Africa'),
    _R('Canada',                          'CA', '+1',    'Americas','Northern America'),
    _R('Central African Republic',        'CF', '+236',  'Africa',  'Middle Africa'),
    _R('Chad',                            'TD', '+235',  'Africa',  'Middle Africa'),
    _R('Chile',                           'CL', '+56',   'Americas','South America'),
    _R('China',                           'CN', '+86',   'Asia',    'Eastern Asia'),
    _R('Colombia',                        'CO', '+57',   'Americas','South America'),
    _R('Comoros',                         'KM', '+269',  'Africa',  'Eastern Africa'),
    _R('Congo',                           'CG', '+242',  'Africa',  'Middle Africa'),
    _R('Costa Rica',                      'CR', '+506',  'Americas','Central America'),
    _R("Côte d'Ivoire",                   'CI', '+225',  'Africa',  'Western Africa'),
    _R('Croatia',                         'HR', '+385',  'Europe',  'Southern Europe'),
    _R('Cuba',                            'CU', '+53',   'Americas','Caribbean'),
    _R('Cyprus',                          'CY', '+357',  'Asia',    'Western Asia'),
    _R('Czech Republic',                  'CZ', '+420',  'Europe',  'Eastern Europe'),

    // ── D ───────────────────────────────────────────────────────────────────
    _R('DR Congo',                        'CD', '+243',  'Africa',  'Middle Africa'),
    _R('Denmark',                         'DK', '+45',   'Europe',  'Northern Europe'),
    _R('Djibouti',                        'DJ', '+253',  'Africa',  'Eastern Africa'),
    _R('Dominica',                        'DM', '+1767', 'Americas','Caribbean'),
    _R('Dominican Republic',              'DO', '+1809', 'Americas','Caribbean'),

    // ── E ───────────────────────────────────────────────────────────────────
    _R('East Timor',                      'TL', '+670',  'Asia',    'South-Eastern Asia'),
    _R('Ecuador',                         'EC', '+593',  'Americas','South America'),
    _R('Egypt',                           'EG', '+20',   'Africa',  'Northern Africa'),
    _R('El Salvador',                     'SV', '+503',  'Americas','Central America'),
    _R('Equatorial Guinea',               'GQ', '+240',  'Africa',  'Middle Africa'),
    _R('Eritrea',                         'ER', '+291',  'Africa',  'Eastern Africa'),
    _R('Estonia',                         'EE', '+372',  'Europe',  'Northern Europe'),
    _R('Eswatini',                        'SZ', '+268',  'Africa',  'Southern Africa'),
    _R('Ethiopia',                        'ET', '+251',  'Africa',  'Eastern Africa'),

    // ── F ───────────────────────────────────────────────────────────────────
    _R('Fiji',                            'FJ', '+679',  'Oceania', 'Melanesia'),
    _R('Finland',                         'FI', '+358',  'Europe',  'Northern Europe'),
    _R('France',                          'FR', '+33',   'Europe',  'Western Europe'),

    // ── G ───────────────────────────────────────────────────────────────────
    _R('Gabon',                           'GA', '+241',  'Africa',  'Middle Africa'),
    _R('Gambia',                          'GM', '+220',  'Africa',  'Western Africa'),
    _R('Georgia',                         'GE', '+995',  'Asia',    'Western Asia'),
    _R('Germany',                         'DE', '+49',   'Europe',  'Western Europe'),
    _R('Ghana',                           'GH', '+233',  'Africa',  'Western Africa'),
    _R('Greece',                          'GR', '+30',   'Europe',  'Southern Europe'),
    _R('Grenada',                         'GD', '+1473', 'Americas','Caribbean'),
    _R('Guatemala',                       'GT', '+502',  'Americas','Central America'),
    _R('Guinea',                          'GN', '+224',  'Africa',  'Western Africa'),
    _R('Guinea-Bissau',                   'GW', '+245',  'Africa',  'Western Africa'),
    _R('Guyana',                          'GY', '+592',  'Americas','South America'),

    // ── H ───────────────────────────────────────────────────────────────────
    _R('Haiti',                           'HT', '+509',  'Americas','Caribbean'),
    _R('Honduras',                        'HN', '+504',  'Americas','Central America'),
    _R('Hungary',                         'HU', '+36',   'Europe',  'Eastern Europe'),

    // ── I ───────────────────────────────────────────────────────────────────
    _R('Iceland',                         'IS', '+354',  'Europe',  'Northern Europe'),
    _R('India',                           'IN', '+91',   'Asia',    'Southern Asia'),
    _R('Indonesia',                       'ID', '+62',   'Asia',    'South-Eastern Asia'),
    _R('Iran',                            'IR', '+98',   'Asia',    'Southern Asia'),
    _R('Iraq',                            'IQ', '+964',  'Asia',    'Western Asia'),
    _R('Ireland',                         'IE', '+353',  'Europe',  'Northern Europe'),
    _R('Israel',                          'IL', '+972',  'Asia',    'Western Asia'),
    _R('Italy',                           'IT', '+39',   'Europe',  'Southern Europe'),

    // ── J ───────────────────────────────────────────────────────────────────
    _R('Jamaica',                         'JM', '+1876', 'Americas','Caribbean'),
    _R('Japan',                           'JP', '+81',   'Asia',    'Eastern Asia'),
    _R('Jordan',                          'JO', '+962',  'Asia',    'Western Asia'),

    // ── K ───────────────────────────────────────────────────────────────────
    _R('Kazakhstan',                      'KZ', '+7',    'Asia',    'Central Asia'),
    _R('Kenya',                           'KE', '+254',  'Africa',  'Eastern Africa'),
    _R('Kiribati',                        'KI', '+686',  'Oceania', 'Micronesia'),
    _R('Kuwait',                          'KW', '+965',  'Asia',    'Western Asia'),
    _R('Kyrgyzstan',                      'KG', '+996',  'Asia',    'Central Asia'),

    // ── L ───────────────────────────────────────────────────────────────────
    _R('Laos',                            'LA', '+856',  'Asia',    'South-Eastern Asia'),
    _R('Latvia',                          'LV', '+371',  'Europe',  'Northern Europe'),
    _R('Lebanon',                         'LB', '+961',  'Asia',    'Western Asia'),
    _R('Lesotho',                         'LS', '+266',  'Africa',  'Southern Africa'),
    _R('Liberia',                         'LR', '+231',  'Africa',  'Western Africa'),
    _R('Libya',                           'LY', '+218',  'Africa',  'Northern Africa'),
    _R('Liechtenstein',                   'LI', '+423',  'Europe',  'Western Europe'),
    _R('Lithuania',                       'LT', '+370',  'Europe',  'Northern Europe'),
    _R('Luxembourg',                      'LU', '+352',  'Europe',  'Western Europe'),

    // ── M ───────────────────────────────────────────────────────────────────
    _R('Madagascar',                      'MG', '+261',  'Africa',  'Eastern Africa'),
    _R('Malawi',                          'MW', '+265',  'Africa',  'Eastern Africa'),
    _R('Malaysia',                        'MY', '+60',   'Asia',    'South-Eastern Asia'),
    _R('Maldives',                        'MV', '+960',  'Asia',    'Southern Asia'),
    _R('Mali',                            'ML', '+223',  'Africa',  'Western Africa'),
    _R('Malta',                           'MT', '+356',  'Europe',  'Southern Europe'),
    _R('Marshall Islands',                'MH', '+692',  'Oceania', 'Micronesia'),
    _R('Mauritania',                      'MR', '+222',  'Africa',  'Western Africa'),
    _R('Mauritius',                       'MU', '+230',  'Africa',  'Eastern Africa'),
    _R('Mexico',                          'MX', '+52',   'Americas','Central America'),
    _R('Micronesia',                      'FM', '+691',  'Oceania', 'Micronesia'),
    _R('Moldova',                         'MD', '+373',  'Europe',  'Eastern Europe'),
    _R('Monaco',                          'MC', '+377',  'Europe',  'Western Europe'),
    _R('Mongolia',                        'MN', '+976',  'Asia',    'Eastern Asia'),
    _R('Montenegro',                      'ME', '+382',  'Europe',  'Southern Europe'),
    _R('Morocco',                         'MA', '+212',  'Africa',  'Northern Africa'),
    _R('Mozambique',                      'MZ', '+258',  'Africa',  'Eastern Africa'),
    _R('Myanmar',                         'MM', '+95',   'Asia',    'South-Eastern Asia'),

    // ── N ───────────────────────────────────────────────────────────────────
    _R('Namibia',                         'NA', '+264',  'Africa',  'Southern Africa'),
    _R('Nauru',                           'NR', '+674',  'Oceania', 'Micronesia'),
    _R('Nepal',                           'NP', '+977',  'Asia',    'Southern Asia'),
    _R('Netherlands',                     'NL', '+31',   'Europe',  'Western Europe'),
    _R('New Zealand',                     'NZ', '+64',   'Oceania', 'Australia and New Zealand'),
    _R('Nicaragua',                       'NI', '+505',  'Americas','Central America'),
    _R('Niger',                           'NE', '+227',  'Africa',  'Western Africa'),
    _R('Nigeria',                         'NG', '+234',  'Africa',  'Western Africa'),
    _R('North Korea',                     'KP', '+850',  'Asia',    'Eastern Asia'),
    _R('North Macedonia',                 'MK', '+389',  'Europe',  'Southern Europe'),
    _R('Norway',                          'NO', '+47',   'Europe',  'Northern Europe'),

    // ── O ───────────────────────────────────────────────────────────────────
    _R('Oman',                            'OM', '+968',  'Asia',    'Western Asia'),

    // ── P ───────────────────────────────────────────────────────────────────
    _R('Pakistan',                        'PK', '+92',   'Asia',    'Southern Asia'),
    _R('Palau',                           'PW', '+680',  'Oceania', 'Micronesia'),
    _R('Palestine',                       'PS', '+970',  'Asia',    'Western Asia'),
    _R('Panama',                          'PA', '+507',  'Americas','Central America'),
    _R('Papua New Guinea',                'PG', '+675',  'Oceania', 'Melanesia'),
    _R('Paraguay',                        'PY', '+595',  'Americas','South America'),
    _R('Peru',                            'PE', '+51',   'Americas','South America'),
    _R('Philippines',                     'PH', '+63',   'Asia',    'South-Eastern Asia'),
    _R('Poland',                          'PL', '+48',   'Europe',  'Eastern Europe'),
    _R('Portugal',                        'PT', '+351',  'Europe',  'Southern Europe'),

    // ── Q ───────────────────────────────────────────────────────────────────
    _R('Qatar',                           'QA', '+974',  'Asia',    'Western Asia'),

    // ── R ───────────────────────────────────────────────────────────────────
    _R('Romania',                         'RO', '+40',   'Europe',  'Eastern Europe'),
    _R('Russia',                          'RU', '+7',    'Europe',  'Eastern Europe'),
    _R('Rwanda',                          'RW', '+250',  'Africa',  'Eastern Africa'),

    // ── S ───────────────────────────────────────────────────────────────────
    _R('Saint Kitts and Nevis',           'KN', '+1869', 'Americas','Caribbean'),
    _R('Saint Lucia',                     'LC', '+1758', 'Americas','Caribbean'),
    _R('Saint Vincent and the Grenadines','VC', '+1784', 'Americas','Caribbean'),
    _R('Samoa',                           'WS', '+685',  'Oceania', 'Polynesia'),
    _R('San Marino',                      'SM', '+378',  'Europe',  'Southern Europe'),
    _R('São Tomé and Príncipe',           'ST', '+239',  'Africa',  'Middle Africa'),
    _R('Saudi Arabia',                    'SA', '+966',  'Asia',    'Western Asia'),
    _R('Senegal',                         'SN', '+221',  'Africa',  'Western Africa'),
    _R('Serbia',                          'RS', '+381',  'Europe',  'Southern Europe'),
    _R('Seychelles',                      'SC', '+248',  'Africa',  'Eastern Africa'),
    _R('Sierra Leone',                    'SL', '+232',  'Africa',  'Western Africa'),
    _R('Singapore',                       'SG', '+65',   'Asia',    'South-Eastern Asia'),
    _R('Slovakia',                        'SK', '+421',  'Europe',  'Eastern Europe'),
    _R('Slovenia',                        'SI', '+386',  'Europe',  'Southern Europe'),
    _R('Solomon Islands',                 'SB', '+677',  'Oceania', 'Melanesia'),
    _R('Somalia',                         'SO', '+252',  'Africa',  'Eastern Africa'),
    _R('South Africa',                    'ZA', '+27',   'Africa',  'Southern Africa'),
    _R('South Korea',                     'KR', '+82',   'Asia',    'Eastern Asia'),
    _R('South Sudan',                     'SS', '+211',  'Africa',  'Eastern Africa'),
    _R('Spain',                           'ES', '+34',   'Europe',  'Southern Europe'),
    _R('Sri Lanka',                       'LK', '+94',   'Asia',    'Southern Asia'),
    _R('Sudan',                           'SD', '+249',  'Africa',  'Northern Africa'),
    _R('Suriname',                        'SR', '+597',  'Americas','South America'),
    _R('Sweden',                          'SE', '+46',   'Europe',  'Northern Europe'),
    _R('Switzerland',                     'CH', '+41',   'Europe',  'Western Europe'),
    _R('Syria',                           'SY', '+963',  'Asia',    'Western Asia'),

    // ── T ───────────────────────────────────────────────────────────────────
    _R('Tajikistan',                      'TJ', '+992',  'Asia',    'Central Asia'),
    _R('Tanzania',                        'TZ', '+255',  'Africa',  'Eastern Africa'),
    _R('Thailand',                        'TH', '+66',   'Asia',    'South-Eastern Asia'),
    _R('Togo',                            'TG', '+228',  'Africa',  'Western Africa'),
    _R('Tonga',                           'TO', '+676',  'Oceania', 'Polynesia'),
    _R('Trinidad and Tobago',             'TT', '+1868', 'Americas','Caribbean'),
    _R('Tunisia',                         'TN', '+216',  'Africa',  'Northern Africa'),
    _R('Turkey',                          'TR', '+90',   'Asia',    'Western Asia'),
    _R('Turkmenistan',                    'TM', '+993',  'Asia',    'Central Asia'),
    _R('Tuvalu',                          'TV', '+688',  'Oceania', 'Polynesia'),

    // ── U ───────────────────────────────────────────────────────────────────
    _R('Uganda',                          'UG', '+256',  'Africa',  'Eastern Africa'),
    _R('Ukraine',                         'UA', '+380',  'Europe',  'Eastern Europe'),
    _R('United Arab Emirates',            'AE', '+971',  'Asia',    'Western Asia'),
    _R('United Kingdom',                  'GB', '+44',   'Europe',  'Northern Europe'),
    _R('United States',                   'US', '+1',    'Americas','Northern America'),
    _R('Uruguay',                         'UY', '+598',  'Americas','South America'),
    _R('Uzbekistan',                      'UZ', '+998',  'Asia',    'Central Asia'),

    // ── V ───────────────────────────────────────────────────────────────────
    _R('Vanuatu',                         'VU', '+678',  'Oceania', 'Melanesia'),
    _R('Vatican City',                    'VA', '+379',  'Europe',  'Southern Europe'),
    _R('Venezuela',                       'VE', '+58',   'Americas','South America'),
    _R('Vietnam',                         'VN', '+84',   'Asia',    'South-Eastern Asia'),

    // ── Y ───────────────────────────────────────────────────────────────────
    _R('Yemen',                           'YE', '+967',  'Asia',    'Western Asia'),

    // ── Z ───────────────────────────────────────────────────────────────────
    _R('Zambia',                          'ZM', '+260',  'Africa',  'Eastern Africa'),
    _R('Zimbabwe',                        'ZW', '+263',  'Africa',  'Eastern Africa'),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact immutable raw-data record
// ─────────────────────────────────────────────────────────────────────────────

/// Private compact tuple for the compile-time [CountryData._raw] const list.
/// Each entry costs ~5 string references on the heap — minimal overhead.
final class _R {
  final String n;   // name
  final String c;   // ISO-2 code
  final String d;   // dial code
  final String r;   // region
  final String s;   // sub-region

  const _R(this.n, this.c, this.d, this.r, this.s);

  Country toCountry() => Country(
        name: n,
        code: c,
        dialCode: d,
        flag: _flag(c),
        region: r,
        subregion: s,
      );

  static String _flag(String code) => String.fromCharCodes(
        code.codeUnits.map((u) => u - 0x41 + 0x1F1E6),
      );
}