# Common Utils2

[![pub package](https://img.shields.io/pub/v/common_utils2.svg)](https://pub.dev/packages/common_utils2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive, production-ready Flutter utilities package designed to accelerate development by providing a vast collection of essential tools, services, and widgets. From advanced media management and push notifications to robust storage solutions and internationalization—`common_utils2` covers it all.

---

## ✨ Features at a Glance

### 🎥 Advanced Media & Video
- **Video Preloading**: Smart viewport-aware preloading (ahead/behind) for TikTok-style feeds.
- **Lazy Loading**: Automatic initialization/disposal of video controllers to optimize memory.
- **Mixed Media**: Seamlessly handle feeds containing images, videos, and documents.
- **Image Preloading**: Efficient pre-caching of network images for smooth scrolling.
- **Pagination**: Built-in Cubit-based pagination for endless scrolling content.

### 🔔 Complete Notification System
- **FCM & Local**: Unified API for Firebase Cloud Messaging and local notifications.
- **In-App Overlays**: Elegant slide-down notification toasts that work over any screen.
- **Notification Centre**: Persistent history tracking with read/unread states.
- **Topic Management**: Simplified subscription/unsubscription logic.

### 📥 Robust Download Manager
- **Concurrent Downloads**: Intelligent queue system with configurable concurrency.
- **Lifecycle Control**: Pause, resume, cancel, and retry downloads.
- **Progress Tracking**: Real-time progress updates, speed, and ETA calculation.

### 💾 Multi-Engine Storage
- **Hive Storage**: High-performance, user-isolated persistent storage.
- **Secure Storage**: AES-256 encrypted storage for tokens and sensitive credentials.
- **Shared Preferences**: Lightweight key-value persistence for simple settings.

### 🌐 Network & Location
- **Connectivity Monitoring**: Real-time internet status, connection type (WiFi, Mobile), and quality estimation (Ping/Latency).
- **Location Services**: High-level API for GPS coordinates, distance calculations, geocoding (Address ↔ Coordinates), and geofencing.
- **HTTP Client**: Dio-based client with built-in interceptors for automatic token management and error handling.

### 🛠️ Core Utilities & Performance
- **Debouncer & Throttler**: Multiple variants (Basic, Typed, Async) and `RateLimiter` for performance optimization.
- **Encryption**: AES, RSA, SHA-256, MD5, and secure password hashing.
- **Maths & Color**: Advanced mathematical operations and color manipulation (Hex, brightness, contrast).
- **Result Type**: Functional error handling for cleaner, type-safe code.

### 📱 Responsive & Device Utils
- **Breakpoint System**: Mobile, Tablet, Desktop, and Ultrawide layout helpers.
- **Responsive Values**: Fluid UI scaling with `valueWhen`, `responsiveValue`, and `fontSize`.
- **System Controls**: Easy control over status bar, orientation, and device information.

### 🇳🇬 Nigerian & International Features
- **Banking**: NUBAN validation, bank discovery for Nigeria, Ghana, SA, and Kenya.
- **Internationalization**: 194+ countries data, state/city support (offline & live API).
- **Validators**: Robust form validation including Nigerian-specific (BVN, NIN, Phone).

---

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  common_utils2: ^2.0.0
```

---

## 🚀 Quick Start: Initialization

The easiest way to set up the package is using the `CommonUtilsInitializer`.

```dart
import 'package:common_utils2/common_utils2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Core Services (Optional but recommended)
  await HiveStorageService.init();
  await SecureStorageService.init();
  await LoggerService.init(enabled: true, logLevel: LoggerLevel.debug);
  
  // 2. Initialize Common Utils Features
  final initializer = await CommonUtilsInitializer.initialize(
    notificationConfig: NotificationConfig.withDefaults(
      onNotificationTap: (payload) => print('Tapped: ${payload.title}'),
    ),
    enableDownloads: true,
    enableNotifications: true,
  );

  runApp(
    MultiBlocProvider(
      providers: initializer.providers, 
      child: const MyApp(),
    ),
  );
}
```

---

## 📚 Detailed Usage

### 1. Responsive UI with `ResponsiveHelper`

Build fluid layouts that work perfectly on any screen size.

```dart
// Get values based on screen type
double padding = ResponsiveHelper.valueWhen(
  context: context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);

// Responsive Font Size (automatically scales)
double titleSize = ResponsiveHelper.fontSize(
  context: context,
  mobile: 18.0,
  tablet: 22.0,
);
```

### 2. Network Connectivity & Monitoring

Stay informed about the device's internet status with high precision.

```dart
// Initialize monitoring
await NetworkConnectivity.init(
  onConnectivityChanged: (status) {
    print('Type: ${status.connectionType.name}, Connected: ${status.isConnected}');
  },
);

// Check connection quality (Excellent, Good, Fair, Poor)
final quality = await NetworkConnectivity.getConnectionQuality();
print('Quality: ${quality.name} ${quality.icon}');

// Wait for connection before proceeding
await NetworkConnectivity.waitForConnection(timeout: Duration(seconds: 10));
```

### 3. Location & Geocoding

Easily handle GPS and address conversions.

```dart
// Get current location
final latLng = await LocationService.instance.getCurrentLatLng();

// Reverse Geocoding: Coordinates to Address
final address = await LocationService.instance.getFormattedAddress(6.5244, 3.3792);

// Calculate distance between two points
double distance = LocationService.instance.calculateDistance(lat1, lon1, lat2, lon2);
```

### 4. Performance: Debouncer, Throttler & Rate Limiter

Optimize expensive operations like search or button clicks.

```dart
final searchDebouncer = Debouncer(delay: Duration(milliseconds: 500));
final loginThrottler = Throttler(duration: Duration(seconds: 2));
final apiLimiter = RateLimiter(maxCalls: 5, period: Duration(minutes: 1));

// Usage in UI
onChanged: (val) => searchDebouncer(() => performSearch(val));
onPressed: () => loginThrottler(() => attemptLogin());

// Rate Limiter check
if (apiLimiter(() => callExpensiveAPI())) {
  print('API Call Successful');
} else {
  print('Rate limit exceeded. Try again in ${apiLimiter.timeUntilNextCall}');
}
```

### 5. Storage Options

```dart
// Persistent Storage (Hive) - Ideal for large data
await HiveStorageService.instance.setString('user_name', 'Innocent');

// Secure Storage - Ideal for Tokens/Secrets
await SecureStorageService.instance.setString('auth_token', 'eyJhbGci...');

// SharedPreferences - Ideal for UI Settings
await SharedPrefStorage.instance.setBool('is_dark_mode', true);
```

### 6. Advanced Extensions

```dart
// String Validations & Masking
'dev@example.com'.isValidEmail;       // true
'admin@gmail.com'.maskEmail;         // a****@gmail.com

// Currency & Formatting
1500000.toCurrency();                // ₦1,500,000.00
DateTime.now().toReadableString();   // 2 minutes ago

// Collections
List items = [1, 2, 2, 3].distinct(); // [1, 2, 3]
```

### 7. Encryption & Security

```dart
// AES Encryption
String encrypted = EncryptionUtils.aesEncrypt('Sensitive Data', 'my-secret-key');
String decrypted = EncryptionUtils.aesDecrypt(encrypted, 'my-secret-key');

// Generate Secure Tokens
String otp = EncryptionUtils.generateOTP(6);
String uuid = EncryptionUtils.generateUUID();
```

---

## 🇳🇬 Nigerian-Specific Features

- **NUBAN Validation**: Validate bank account numbers with `BankUtils.validateAccount`.
- **Full Bank List**: Access all commercial and microfinance banks in Nigeria.
- **Identity Validation**: Built-in validators for **BVN**, **NIN**, and **Phone Numbers**.
- **Geography**: Complete offline list of all 36 Nigerian states + FCT.
- **Currency**: Native support for the `₦` symbol and local formatting.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## ⭐ Support

If you find this package useful, please consider giving it a star on [GitHub](https://github.com/mhista/common_utils)!

**Author**: Diwe Innocent  
**Email**: diweesomchi@gmail.com  
**Website**: [https://innocentdiwe.qzz.io](https://innocentdiwe.qzz.io)
