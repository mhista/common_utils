# Changelog


## 2.0.2

### 🌍Bug fix

### 🌍 Color, File utilities (Major upgrade)

The file and color utilities upgraded to be more extensive.

## 2.0.1

### 🌍Bug fix


## 2.0.0

### 🌍 Country, State & City Utilities (complete rewrite)

The country utilities have been fully redesigned — 194 countries, three switchable
data sources, lazy loading, and offline state lists for 8 countries.

**New classes**
- `Country` — rich model with name, ISO code, dial code, emoji flag, region,
  sub-region, capital, currency, languages, population. Works with all three sources.
- `CountryState` — state/region model with `fromJson` for live API responses.
- `CountryCity` — city model with `fromJson` for live API responses.
- `DialCode` — lightweight view of a country used in dial-code pickers
  (`display` → "🇳🇬 +234", `fullDisplay` → "🇳🇬 Nigeria (+234)").
- `CountryListResult`, `StateListResult`, `CityListResult` — typed result wrappers
  matching the existing pattern in the package.

**New: `CountryData` (static, offline, zero setup)**
- 194 sovereign states — all UN member + observer states, matching Google's list.
- Raw data stored as a compile-time `const` list — zero allocation at startup.
- `CountryData.all` — full A→Z list, materialised and cached on first access.
- `CountryData.byCode` — `Map<String, Country>`, O(1) lookup by ISO 3166-1 alpha-2.
- `CountryData.byDialCode` — `Map<String, List<Country>>`, handles shared codes (+1).
- `CountryData.search(query, limit:)` — O(n) search across name, code, dial code.
- `CountryData.withPopularFirst(list)` — reorders by a curated popular-countries list.
- `CountryData.byRegion(region)` — filter by continent string.
- `CountryData.popular` — curated shortlist (NG, GH, ZA, KE, UG, RW, US, GB, CA…).

**New: `CountryService` (switchable source)**
- `CountryService.init(source:, httpClient:, cscApiKey:)` — configure global instance once in `main()`.
- `CountryService.instance` — global singleton after `init()`.
- Three sources via `CountrySource` enum:
  - `staticData` — offline, instant, default, no setup needed.
  - `restCountriesApi` — restcountries.com v3.1, free, no key required. Adds capital,
    currency, languages, population.
  - `countryStateCityApi` — countrystatecity.in, requires API key. Enables states +
    cities for any country in the world.
- `getAllCountries()` — returns `CountryListResult`, API results cached per session.
- `getCountryByCode(code)` — O(1) on static source, filtered list on API sources.
- `searchCountries(query, limit:)` — unified search regardless of active source.
- `getStates(countryCode)` — offline lists for NG, US, GB, CA, AU, ZA, GH, KE;
  live API call for all other countries.
- `getCities(countryCode:, stateCode:)` — requires `countryStateCityApi` source.
- `getDialCodes()` — always instant, returns `List<DialCode>` from static data.
- `popularCountries` — always instant, curated shortlist.
- `byRegion` — `Map<String, List<Country>>` grouped by continent.
- `CountryService.clearCache()` — force a fresh API fetch on next call.

**New: `CountryHttpClient` interface**
- Inject any HTTP implementation — `package:http`, `package:dio`, or a mock.
- Not required for `CountrySource.staticData`.

**Offline state lists now included**
| Country | Subdivisions |
|---------|-------------|
| Nigeria (NG) | 36 states + FCT Abuja |
| United States (US) | 50 states + District of Columbia |
| United Kingdom (GB) | England, Scotland, Wales, Northern Ireland |
| Canada (CA) | 10 provinces + 3 territories |
| Australia (AU) | 6 states + 2 territories |
| South Africa (ZA) | 9 provinces |
| Ghana (GH) | 16 regions |
| Kenya (KE) | 47 counties |

**Breaking changes from previous `CountryUtils`**
- `CountryUtils` static class replaced by `CountryData` (static) + `CountryService` (dynamic).
- `CountryUtils.init(cscApiKey:)` → `CountryService.init(source:, cscApiKey:, httpClient:)`.
- `CountryUtils.getAllCountries()` → `CountryService.instance.getAllCountries()`.
- `CountryUtils.getNigerianStates()` → `CountryService.instance.getStates('NG')` (still offline).
- `CountryUtils.getStates(code)` → `CountryService.instance.getStates(code)`.
- `CountryUtils.getCities(...)` → `CountryService.instance.getCities(...)`.
- `CountryUtils.getDialCodes()` → `CountryService.instance.getDialCodes()`.
- `CountryUtils.popularCountries` → `CountryService.instance.popularCountries`.
- `Country` model now sourced from `CountryData` — dial code and flag no longer
  need to be hardcoded per-entry; emoji flag is computed from ISO code.

---

## 1.0.3

- Added Notification and video utilities

## 1.0.1

- Updated HTTP client methods

## 1.0.0

- Initial release
- 24 comprehensive utilities for Flutter development
- String extensions with 50+ methods
- Number formatting and math utilities
- Banking utilities with Paystack integration
- Real-time currency conversion
- Country, state, and city data
- Network connectivity monitoring
- Image and file utilities
- Encryption and security tools
- Responsive design helpers
- Logger with Talker integration
- Nigerian-specific features (BVN, NIN, banks, states)