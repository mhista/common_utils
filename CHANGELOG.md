# Changelog

## 4.0.0

Toolchain refresh for **Flutter 3.47 / Dart 3.13** plus notification upgrades for
multi-account, category-heavy apps. See [UPGRADING.md](UPGRADING.md).

### ⚠️ Breaking
- **SDK**: requires Dart `^3.13.0` and Flutter `>=3.47.0`.
- **Material → `material_ui`**: all widgets now import `package:material_ui/material_ui.dart`
  (Flutter 3.47 decoupled Material; `package:flutter/material.dart` is frozen and scheduled
  for deprecation). Apps should run `dart fix --apply --code=migrate_design_widgets`.
  See UPGRADING.md.
- **Android**: minSdk 24, compileSdk 37 (flutter_secure_storage 11, permission_handler 13).
- **Storage**: `hive_flutter` → `hive_ce` / `hive_ce_flutter` (drop-in, same on-disk format).
- **SecureStorageService**: uses `storageNamespace` (flutter_secure_storage 11 removed
  `sharedPreferencesName`). Defaults are unchanged, so existing values are still read.
  New `namespace`, `keyPrefix`, `sharedKeychainGroup`, `sharedAccountName` parameters.
- **FileUtils** (file_picker 13): `saveFile` now requires `bytes` and returns `Uri?`;
  `allowCompression` → `compressionQuality` (0–100); picked files no longer pre-load
  bytes — pass `withBytes: true` when you need them (web).
- **Removed demo code from the public API**: `User`, `UserRepository`,
  `HiveStorageExample`, `StorageExample`, `resultExamples`, `asyncStateExamples`,
  `debouncerExamples`, `throttlerExamples`, `rateLimiterExamples`,
  `networkConnectivityExamples`, `bankUtilsExamples`. (`User` clashed with app entities.)
- **Dependencies removed** (declared but unused): `injectable`, `pdfx`.
- `CommonNotificationService.setBadgeCount` is deprecated →
  `setForegroundPresentationOptions(...)`.

### 🔔 Notifications
- **Per-category mute**: new `NotificationPreferences` (`service.preferences`) with
  per-account scopes and a `changes` stream for backend sync.
- **Permission timing**: `NotificationConfig.requestPermissionOnInit` (default `true`) and
  `requestPermission()` / `hasPermission()` so apps can ask in context.
- **Cold-start local taps**: a *local* notification that launches the app is now captured
  as a pending tap (previously only FCM taps were).
- **Stable notification IDs**: payload keys `notificationId` / `tag` / `threadId` /
  `conversationId` replace an existing notification instead of stacking;
  `cancelByKey(key)` clears it. `groupKey` bundles related notifications.
- Channel **name, description, importance, sound and vibration** are now applied when
  displaying (the channel ID was previously used as the name, importance was always high).
- New `NotificationChannelDef.showBadge`.
- New `messages` and `taps` streams; `CommonUtilsInitializer` pipes foreground pushes into
  the in-app inbox automatically (`pipeForegroundToInbox`).
- `NotificationCubit`: per-account `scope` / `switchScope`, `markChannelRead`, configurable
  `maxEntries`. `NotificationState`: `entriesFor`, `unreadCountFor`, `unreadByChannel`.
- `NotificationBadge(channelId: ...)` for per-category badges, with screen-reader labels.
- Fixed duplicate inbox IDs for local notifications created in the same millisecond.
- **Fixed `InAppNotificationOverlay` crash** when placed in `MaterialApp.builder` (the
  documented usage): it now hosts its own `Overlay` instead of `Overlay.of(context)`.
- Platform checks use `defaultTargetPlatform`/`kIsWeb` (no `dart:io` in the service).

### ✅ Result
- `Result.guard` / `Result.guardSync` capture errors **with stack traces**; non-`Exception`
  errors are wrapped (previously `e as Exception` could throw).
- `Failure.stackTrace`, `stackTraceOrNull`, `fold`.

### 🧰 Other fixes
- `NetworkConnectivity.hasInternetConnection` has a timeout (default 3 s) — no more
  start-up stalls on slow networks; guards against empty connectivity result lists.
- `LocationService` migrated to geocoding 5 (`Geocoding` instance) and geolocator
  `LocationSettings`; new `setGeocodingLocale`.
- Replaced deprecated `Color.withOpacity` / `Color.value`.
- Barrel now exports `LogLevel`, `TalkerRouteObserver`, `TalkerScreen`.
- All dependencies bumped to their latest stable releases.
- New tests: `test/result_test.dart`, `test/notifications/notification_preferences_test.dart`.

## 3.0.4
- Switched video engine back to `video_player` (media_kit removed). See git history for 3.0.x.



## 2.0.3

### 🌍 Image utilities (Major upgrade)

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