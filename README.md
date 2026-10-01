# common_utils2

[![pub package](https://img.shields.io/pub/v/common_utils2.svg)](https://pub.dev/packages/common_utils2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-focused Flutter utilities package: **push / local / in-app notifications**, **storage** (Hive CE, secure storage, shared preferences), **connectivity**, **logging**, a type-safe **`Result`**, **countries & dial codes**, **currency**, **validators**, **media & files**, **location**, and a set of everyday extensions.

> **Upgrading from 3.x?** Read [UPGRADING.md](UPGRADING.md) — 4.0.0 needs Flutter 3.47 / Dart 3.13 and has a few small API changes.

---

## Contents

1. [Requirements & installation](#1-requirements--installation)
2. [Quick start](#2-quick-start)
3. [Module map — what to use when](#3-module-map--what-to-use-when)
4. [Notifications](#4-notifications)
5. [Result & error handling](#5-result--error-handling)
6. [Storage](#6-storage)
7. [Connectivity](#7-connectivity)
8. [Logging](#8-logging)
9. [Countries, dial codes & currency](#9-countries-dial-codes--currency)
10. [Validators & extensions](#10-validators--extensions)
11. [Media, images & files](#11-media-images--files)
12. [Location](#12-location)
13. [Performance helpers](#13-performance-helpers)
14. [Name collisions to know about](#14-name-collisions-to-know-about)
15. [Platform setup checklist](#15-platform-setup-checklist)

---

## 1. Requirements & installation

| | Minimum |
|---|---|
| Flutter | **3.47.0** |
| Dart | **3.13.0** |
| Android | minSdk **24**, compileSdk **37** (required by `flutter_secure_storage` 11 / `permission_handler` 13) |
| iOS | **13.0** |

```yaml
dependencies:
  common_utils2: ^4.0.0
  material_ui: ^1.4.0   # Flutter 3.47+: Material lives here now
```

The package's widgets use `package:material_ui/material_ui.dart`. New apps should import `material_ui` instead of `package:flutter/material.dart` (existing apps can run `dart fix --apply --code=migrate_design_widgets`).

```dart
import 'package:common_utils2/common_utils2.dart';
```

---

## 2. Quick start

Initialise the services you use **once**, in `main()`, before `runApp`. Everything is optional — only call what you need.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Core services
  LoggerService.init(logLevel: LogLevel.debug);
  await StorageService.init();                         // SharedPreferences
  await SecureStorageService.init(namespace: 'myapp'); // tokens & secrets
  await HiveStorageService.init();                     // larger offline data
  await DeviceInfoHelper.init();
  await NetworkConnectivity.init();

  // Push + in-app notifications (needs Firebase for push)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final utils = await CommonUtilsInitializer.initialize(
    notificationConfig: NotificationConfig.withDefaults(
      requestPermissionOnInit: false, // ask later, in context
      onTokenRefreshed: (token) => api.saveDeviceToken(token),
    ),
  );

  Bloc.observer = LoggerService.getBlocObserver();

  runApp(MultiBlocProvider(providers: utils.providers, child: const MyApp()));
}
```

---

## 3. Module map — what to use when

| Need | Use | Notes |
|---|---|---|
| Push notifications (FCM) + local display | `CommonNotificationService` | Channels, taps, cold-start routing, topics, tokens, per-channel mute |
| Notification inbox / badge / centre UI | `NotificationCubit`, `NotificationBadge`, `NotificationCentrePage`, `InAppNotificationOverlay` | Persistent, per-account scopes |
| Return success/failure without throwing | `Result<T>`, `Result.guard` | Works with your own typed exceptions |
| Loading/error/data state for a widget | `AsyncState<T>` | Lightweight alternative to a freezed state |
| Tokens, secrets | `SecureStorageService` | Keychain / Android Keystore |
| Settings, flags | `StorageService` | SharedPreferences wrapper, typed getters |
| Offline data, per-user isolation | `HiveStorageService` | `setUser(id)` opens that user's box |
| Online/offline + connection quality | `NetworkConnectivity` | Stream + quality/latency |
| Logs, Bloc/HTTP/route logging | `LoggerService` (Talker) | `TalkerRouteObserver` for go_router |
| Country pickers, dial codes | `CountryData`, `CountryService`, `DialCode` | 194 countries offline |
| Money formatting / conversion | `CurrencyUtils`, `num.toCurrency()` | NGN default; live rates optional |
| Form validation | `CommonValidators` | Email, phone, NG phone, BVN, NIN, password… |
| Pick/compress images & video | `MediaUtils` | Compression, thumbnails, size checks |
| Pick / save arbitrary files | `FileUtils` | file_picker 13 API |
| GPS & geocoding | `LocationService` | Permissions handled |
| Debounce search, throttle taps | `Debouncer`, `Throttler`, `RateLimiter` | |
| REST calls (non-Supabase APIs) | `HttpClient` (Dio) | Auth interceptor + token manager |
| Nigerian banks / NUBAN | `BankUtils` | Needs a Paystack key |
| Video feeds | `LazyVideoCubit`, `VideoPreloadCubit` | TikTok-style preloading |

---

## 4. Notifications

### 4.1 Setup

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

await CommonNotificationService.instance.initialize(
  NotificationConfig.withDefaults(
    androidIcon: '@drawable/ic_notification', // white on transparent
    extraChannels: const [
      NotificationChannelDef(
        id: 'calls',
        name: 'Calls',
        description: 'Incoming voice and video calls',
        importance: Importance.max,
      ),
    ],
    requestPermissionOnInit: false,
    onTokenRefreshed: (token) async => api.saveDeviceToken(token),
    onNotificationTap: (payload) async {
      final link = payload.deepLink;
      if (link == null) return false;  // fall through to payloadHandler
      router.push(link);
      return true;                     // handled
    },
  ),
);
```

Default channels: `general`, `orders`, `messages`, `promotions`, `alerts`. Add your own with `extraChannels`. The server chooses the channel with `data.channel`.

### 4.2 Ask for permission in context

```dart
// e.g. on an onboarding screen that explains why
final allowed = await CommonNotificationService.instance.requestPermission();
```

### 4.3 Cold start (app opened from a notification)

The router isn't ready during `initialize`, so the tap is stored. Consume it once your router can navigate:

```dart
redirect: (context, state) {
  final tap = CommonNotificationService.instance.consumePendingTap();
  if (tap?.deepLink != null) return tap!.deepLink;
  return null;
}
```

Works for both FCM and **local** notifications (new in 4.0).

### 4.4 Payload conventions

Everything in FCM `data` lands in `payload.data`. Recognised keys:

| Key | Purpose |
|---|---|
| `type` | Your event type, e.g. `order.shipped` → `payload.type` |
| `id` / `orderId` / `productId` / `userId` | → `payload.entityId` |
| `deepLink` / `deep_link` | → `payload.deepLink` |
| `channel` | Android channel / category ID |
| `notificationId` / `tag` / `threadId` / `conversationId` | **Stable key**: a new notification with the same key replaces the old one (chat threads, order status). Clear it with `cancelByKey(key)` |
| `groupKey` | Android group / iOS thread grouping |

Typed access: `payload.get<double>('amount')`, `payload.typed(MyModel.fromJson)`.

### 4.5 Per-category mute (new)

```dart
final prefs = CommonNotificationService.instance.preferences;
await prefs.setMuted('promotions', true);
prefs.isMuted('promotions');              // true
prefs.changes.listen(syncToBackend);      // keep your server in sync
await prefs.switchScope(activeAccountId); // per-account preferences
```

Muting stops the app from **displaying** foreground and local notifications on that channel. Background FCM notification messages are drawn by the OS, so also store the preference server-side and skip sending.

### 4.6 In-app inbox, badge & centre

`CommonUtilsInitializer` creates a `NotificationCubit` and, by default, pipes every foreground push into it.

```dart
NotificationBadge(child: Icon(Icons.notifications_outlined));   // total unread
NotificationBadge(channelId: 'orders', child: Icon(Icons.receipt)); // per category

context.read<NotificationCubit>().switchScope(accountId); // per-account inbox
context.read<NotificationCubit>().markChannelRead('orders');
state.unreadByChannel; // {'orders': 2, 'messages': 5}
```

Toasts over any screen:

```dart
MaterialApp.router(builder: (c, child) => InAppNotificationOverlay(child: child!));
InAppNotificationController.instance.show(title: 'Saved', body: 'Draft stored offline');
```

### 4.7 Custom routing class

Implement `INotificationHandler` for larger apps and pass it as `payloadHandler`. Order of evaluation: config callback → handler → default behaviour. Replace at runtime with `setHandler`.

### 4.8 Logout

```dart
await CommonNotificationService.instance.unsubscribeAll();
await CommonNotificationService.instance.deleteToken();
```

---

## 5. Result & error handling

```dart
final result = await Result.guard(() => repo.fetchProfile());

switch (result) {
  case Success(:final data):   show(data);
  case Failure(:final message): showError(message);
}
```

* `Result.guard` / `Result.guardSync` capture errors **and stack traces**; non-`Exception` errors are wrapped, so building a failure never throws.
* Put a typed error in `exception` (anything that `implements Exception`) and read it with `result.exceptionOrNull`.
* `mapError` turns raw errors into friendly messages:

```dart
Result.guard(
  () => api.call(),
  mapError: (e, st) => (message: 'Could not reach the server', exception: MyNetworkFailure()),
);
```

Also: `map`, `flatMap`, `fold`, `when`, `onSuccess`, `onFailure`, `getOrDefault`, `getOrElse`, `recover`, `dataOrNull`, `errorOrNull`, `stackTraceOrNull`.

---

## 6. Storage

| Service | Backing store | Use for |
|---|---|---|
| `StorageService` | SharedPreferences | Settings, flags, small JSON |
| `SecureStorageService` | Keychain / Keystore | Tokens, secrets, PINs |
| `HiveStorageService` | Hive CE | Offline caches, drafts, per-user data |

```dart
await StorageService.instance.setBool('onboarded', true);
StorageService.instance.getBoolOrDefault('onboarded', false);

await SecureStorageService.instance.setString('refresh_token', token);

await HiveStorageService.instance.setUser(accountId);            // opens user_<id> box
await HiveStorageService.instance.setGlobalBool('seen_intro', true);
```

**New apps:** call `SecureStorageService.init(namespace: 'yourapp')` so values never collide with another app. Leaving the defaults keeps the 3.x (`grascope_*`) location, which is only needed for existing installs.

---

## 7. Connectivity

```dart
await NetworkConnectivity.init(onConnectivityChanged: (s) => print(s.isConnected));
NetworkConnectivity.isConnected;
NetworkConnectivity.onConnectivityChanged.listen((status) { ... });
await NetworkConnectivity.getConnectionQuality(); // excellent/good/fair/poor
await NetworkConnectivity.waitForConnection(timeout: const Duration(seconds: 10));
```

`hasInternetConnection()` is now bounded by a 3-second timeout, so a slow or captive network can't stall start-up.

---

## 8. Logging

```dart
LoggerService.init(logLevel: LogLevel.debug, enabled: !kReleaseMode);
final log = LoggerService.instance;
log.info('Loaded');
log.error('Failed', error, stackTrace);
Bloc.observer = LoggerService.getBlocObserver();

GoRouter(observers: [TalkerRouteObserver(LoggerService.instance.talker)]);
// In-app log viewer: TalkerScreen(talker: LoggerService.instance.talker)
```

---

## 9. Countries, dial codes & currency

```dart
CountryData.all;                 // 194 countries, offline
CountryData.byCode['NG'];        // Country
CountryData.search('nig');       // name / code / dial code
CountryData.popular;             // NG, GH, ZA, KE, US, GB…
CountryService.init();           // optional: switch to a live source
CountryService.instance.getDialCodes(); // List<DialCode> for phone pickers ("🇳🇬 +234")

1500000.toCurrency();                        // ₦1,500,000.00
CurrencyUtils.formatAmount(2500, 'NGN');     // ₦2,500.00
CurrencyUtils.formatCompact(2450000, 'NGN'); // ₦2.45M
```

---

## 10. Validators & extensions

```dart
TextFormField(validator: CommonValidators.nigerianPhoneValidator);
TextFormField(validator: CommonValidators.combine([
  (v) => CommonValidators.required(v, fieldName: 'Username'),
  (v) => CommonValidators.minLengthValidator(v, 3),
]));

'dev@example.com'.isValidEmail;   // true
'08012345678'.isValidNigerianPhone;
'hello world'.toTitleCase;        // Hello World
DateTime.now().toTimeAgo;         // "Just now"
[1, 2, 2, 3].distinct();          // [1, 2, 3]
```

---

## 11. Media, images & files

```dart
final picked = await MediaUtils.pickImageFromGallery();
final compressed = await MediaUtils.compressImage(file, quality: 70);  // data-saver uploads
final thumb = await MediaUtils.extractThumbnailBytes(videoFile);

// file_picker 13 based (see UPGRADING.md)
final doc = await FileUtils.pickDocument();
final many = await FileUtils.pickMultipleFiles(type: FilePickerType.image, compressionQuality: 70);
final uri = await FileUtils.saveFile(fileName: 'invoice.pdf', bytes: pdfBytes);
```

---

## 12. Location

```dart
final latLng = await LocationService.instance.getCurrentLatLng();
final address = await LocationService.instance.getFormattedAddress(6.5244, 3.3792);
final metres = LocationService.instance.calculateDistance(lat1, lon1, lat2, lon2);
LocationService.instance.setGeocodingLocale(const Locale('fr'));
```

---

## 13. Performance helpers

```dart
final search = Debouncer(delay: const Duration(milliseconds: 400));
onChanged: (q) => search(() => cubit.search(q));

final tap = Throttler(duration: const Duration(seconds: 1));
onPressed: () => tap(submit);

final limiter = RateLimiter(maxCalls: 5, period: const Duration(minutes: 1));
if (!limiter(() => sendOtp())) showWait(limiter.timeUntilNextCall);
```

---

## 14. Name collisions to know about

The barrel exports a few short, common names. If they clash with your code, hide them:

| Export | Clashes with |
|---|---|
| `Failure`, `Success` (Result) | your own failure classes |
| `Initial`, `Loading` (AsyncState) | generic state names |
| `HttpClient` | `dart:io` `HttpClient` |
| `Location` (geocoding) | other location models |

```dart
import 'package:common_utils2/common_utils2.dart' hide Failure, HttpClient;
```

Prefer naming your own types `AppFailure`, `ApiClient`, etc.

---

## 15. Platform setup checklist

**Android** (`android/app/build.gradle.kts`)

```kotlin
android {
    compileSdk = 37
    defaultConfig { minSdk = 24 }
    compileOptions {
        isCoreLibraryDesugaringEnabled = true   // flutter_local_notifications
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
```

`AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.INTERNET"/>
<!-- inside <application> -->
<meta-data android:name="com.google.firebase.messaging.default_notification_channel_id"
           android:value="general"/>
```

**iOS**: enable *Push Notifications* and *Background Modes → Remote notifications* in Xcode, upload your APNs key to Firebase, and set the deployment target to 13.0.

---

## License

MIT — see [LICENSE](LICENSE).

**Author**: Diwe Innocent · [innocentdiwe.qzz.io](https://innocentdiwe.qzz.io) · diweesomchi@gmail.com
