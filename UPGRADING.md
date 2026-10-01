# Upgrading to common_utils2 4.0.0

4.0.0 is a toolchain/dependency refresh with a handful of API changes. Most apps only need steps 1–3.

## 1. Update Flutter and your pubspec

```bash
flutter upgrade           # needs Flutter >= 3.47.0 / Dart >= 3.13.0
```

```yaml
environment:
  sdk: ^3.13.0

dependencies:
  common_utils2: ^4.0.0
```

If your app also lists any of these directly, bump them to at least these versions to avoid solver conflicts: `firebase_messaging ^16.7.0`, `firebase_core ^4.15.0`, `flutter_local_notifications ^22.3.1`, `cached_network_image ^4.0.2`, `video_player ^2.14.0`, `chewie ^1.17.1`, `file_picker ^13.1.0`, `equatable ^3.0.0`.

## 2. Migrate your app to `material_ui`

Flutter 3.47 moved Material out of the SDK into the standalone `material_ui` package.
common_utils2 4.0 uses `material_ui`, so its widgets (notification centre, badge, overlay,
download UI) read the theme from `material_ui`'s `Theme`. Migrate your app too:

```bash
flutter pub add material_ui cupertino_ui
dart fix --apply --code=migrate_design_widgets
```

If you can't migrate yet, the package's widgets still render, but they won't pick up your
app's `ThemeData` (the two `Theme` classes are different types).

## 3. Android build settings

```kotlin
// android/app/build.gradle.kts
android {
    compileSdk = 37
    defaultConfig { minSdk = 24 }
    compileOptions { isCoreLibraryDesugaringEnabled = true }
}
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
```

## 4. Regenerate code (only if you use build_runner)

```bash
dart run build_runner build --delete-conflicting-outputs
```

Freezed 4 no longer accepts `final` on constructor parameters. Remove it if your own freezed classes use it.

## 5. API changes

### Hive
`hive_flutter` → `hive_ce_flutter`. `HiveStorageService` is unchanged, and existing boxes open as before. If **your** code imports Hive directly:

```dart
// before
import 'package:hive_flutter/hive_flutter.dart';
// after
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
```

### SecureStorageService
No change is needed for existing apps: defaults still point at the 3.x storage. New apps should isolate their data:

```dart
await SecureStorageService.init(namespace: 'myapp', keyPrefix: 'myapp_');
```

If you build `AndroidOptions` yourself, replace `sharedPreferencesName:` with `storageNamespace:` and drop `encryptedSharedPreferences`.

### FileUtils

```dart
// before
final path = await FileUtils.saveFile(fileName: 'a.pdf');
await File(path!).writeAsBytes(bytes);
// after — file_picker writes the bytes for you
final uri = await FileUtils.saveFile(fileName: 'a.pdf', bytes: bytes);

// before
FileUtils.pickImage(allowCompression: true);
// after
FileUtils.pickImage(compressionQuality: 70);

// bytes are no longer pre-loaded
final f = await FileUtils.pickFile(withBytes: true); // web / in-memory use
```

### Removed example symbols
`User`, `UserRepository`, `HiveStorageExample`, `StorageExample` and the `*Examples()` functions were demo code and have been removed. If you were importing `User` from this package by accident, import your own model instead.

### Notifications

```dart
// deprecated
CommonNotificationService.instance.setBadgeCount(true);
// use
CommonNotificationService.instance.setForegroundPresentationOptions(badge: true);
```

Optional new features:
- Ask permission later: `NotificationConfig.withDefaults(requestPermissionOnInit: false)`, then `requestPermission()`.
- Mute categories: `CommonNotificationService.instance.preferences.setMuted('promotions', true)`.
- Per-account inbox: `NotificationCubit(scope: accountId)` / `switchScope(accountId)`.
- Replace instead of stack: send `data.threadId` (or `notificationId`/`tag`/`conversationId`).

### Result
Unchanged for existing callers. New: `Result.guard`, `Result.guardSync`, `fold`, `stackTraceOrNull`.

## 6. mycut note
mycut pins `common_utils2: 3.0.4` (and overrides it), so it keeps working until you choose to upgrade it. When you do, run the `material_ui` migration in step 2 first.
