# Common Utils2

[![pub package](https://img.shields.io/pub/v/common_utils2.svg)](https://pub.dev/packages/common_utils2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter utilities package that provides essential tools for rapid app development. From string manipulation to video preloading, currency conversion to push notifications - everything you need in one package.

## ✨ Features

### 🎥 Video & Media Management
*New in v2.0.0*
- **Video Preloading**: Smart video controller with configurable preload-ahead/behind
- **Pagination Support**: Automatic content loading as users scroll
- **Mixed Media Feeds**: Facebook-style feeds with videos, images, and documents
- **Lazy Video Loading**: Viewport-aware video initialization for optimal memory
- **State Preservation**: Like/unlike without reloading media
- **Generic Design**: Works with any data type (Posts, Reels, Stories)

### 📥 Download Manager
- **Queue System**: Max 3 concurrent downloads with automatic queueing
- **Pause/Resume**: Full control over download lifecycle
- **Progress Tracking**: Real-time progress with speed and ETA
- **Multi-Format**: Videos, images, documents, any file type
- **Storage Management**: Organized by type (Videos/, Images/, Documents/)
- **Batch Operations**: Pause all, resume all, cancel all

### 🔔 Push Notifications
- **FCM Integration**: Complete Firebase Cloud Messaging support
- **Local Notifications**: Flutter local notifications with channels
- **In-App Toasts**: Slide-down notification overlays
- **Notification Centre**: Full history with read/unread tracking
- **Badge Support**: Unread count badges for nav icons
- **Deep Linking**: Automatic routing from notification taps
- **Generic Handler**: Works with any app-specific routing logic

### 🖼️ Image Preloading
- **Smart Caching**: Two-layer caching (network + memory)
- **Scroll-Ahead**: Preloads images in scroll direction
- **CachedNetworkImage**: Optimized image display widgets
- **Memory Efficient**: Only keeps visible + buffer

### 📄 Document Previews
- **PDF Thumbnails**: Generate first-page previews
- **Multiple Formats**: PDF, DOCX, XLSX, PPTX support
- **Generic Icons**: Fallback for unsupported formats

### 🔤 String & Text Utilities
- **50+ String Extensions**: Validation, capitalization, masking, truncation
- **Validators**: Email, phone, passwords, Nigerian-specific (BVN, NIN)
- **Regex Patterns**: 50+ predefined patterns for common use cases
- **Format Utilities**: Phone numbers, credit cards, dates, file sizes

### 🔢 Number & Math
- **Number Extensions**: Currency formatting, percentages, compact notation
- **Math Utilities**: Statistics, financial calculations, random generation
- **Currency Converter**: Real-time exchange rates for 150+ currencies
- **Nigerian Naira Support**: Built-in ₦ formatting

### 🏦 Banking & Finance
- **Bank List**: Fetch banks for Nigeria, Ghana, South Africa, Kenya
- **Account Validation**: Real-time account verification via Paystack
- **Currency Conversion**: Live exchange rates with no API key required
- **Multi-Currency**: Convert between any currencies instantly

### 🌍 Location & Geography
- **250+ Countries**: With flags, dial codes, currencies
- **States & Cities**: Complete location data for forms
- **Nigerian States**: Offline access, no API needed
- **Geocoding**: GPS coordinates, distance calculations

### 📡 Network & Connectivity
- **Network Monitoring**: Real-time connection status
- **Connection Quality**: Measure latency and speed
- **Ping Test**: Check host connectivity
- **Auto-Retry**: Wait for connection with timeout

### 🎨 UI & Design
- **Responsive Helpers**: Breakpoints, adaptive layouts
- **Color Utilities**: Generate palettes, calculate contrast
- **Device Info**: Platform detection, screen sizes
- **Image Utils**: Compression, picking, base64 encoding

### 🔐 Security & Storage
- **Encryption**: AES, hashing (MD5, SHA-256), password hashing
- **Secure Storage**: Type-safe SharedPreferences wrapper
- **Data Masking**: Hide sensitive information
- **Token Generation**: API keys, OTP, UUID

### 📝 Logging & Debugging
- **Talker Integration**: Beautiful console logs
- **HTTP Logging**: Track all API requests/responses
- **Performance Monitoring**: Log operation durations
- **Custom Log Types**: Navigation, user actions, errors

### 🗂️ Collections & Data
- **List Extensions**: 40+ operations (groupBy, chunk, distinct)
- **Map Extensions**: Safe access, filtering, deep merge
- **Result Type**: Type-safe error handling
- **Async State**: Loading, success, error states

### 📁 File & Media
- **File Utilities**: Read, write, copy, move operations
- **Image Tools**: Pick, compress, validate
- **Path Helpers**: Cross-platform path management
- **Cleanup**: Auto-delete old files

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  common_utils2: ^2.0.0
  
  # Required for video features
  video_player: ^2.8.2
  chewie: ^1.7.5
  
  # Required for notifications
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
  
  # Required for downloads
  dio: ^5.4.0
  path_provider: ^2.1.1
  permission_handler: ^11.2.0
  
  # Required for caching
  cached_network_image: ^3.3.1
  flutter_cache_manager: ^3.3.1
```

Then run:

```bash
flutter pub get
flutter pub run build_runner build
```

## 🚀 Quick Start

### Initialize in your app

```dart
import 'package:common_utils2/common_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize notifications
  await CommonNotificationService.instance.initialize(
    NotificationConfig.withDefaults(
      onTokenRefreshed: (token) => myApi.updateFcmToken(token),
      onNotificationTap: (payload) async {
        myRouter.push(payload.deepLink!);
        return true;
      },
    ),
  );
  
  // Initialize notification store (for in-app notifications)
  final notificationCubit = NotificationCubit();
  await notificationCubit.initialize();
  
  // Initialize core services
  await StorageService.init();
  await DeviceInfoHelper.init();
  await LoggerService.init(
    logLevel: LoggerLevel.debug,
    enabled: true,
  );
  
  // Initialize network monitoring
  await NetworkConnectivity.init(
    onConnectivityChanged: (status) {
      print('Connection: ${status.connectionType.name}');
    },
  );
  
  // Initialize API-based utilities (optional)
  BankUtils.init(paystackSecretKey: 'your_key');
  CountryUtils.init(cscApiKey: 'your_key');
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: notificationCubit),
        BlocProvider(create: (_) => DownloadCubit()),
      ],
      child: MyApp(),
    ),
  );
}
```

## 📚 Usage Examples

### Video Preloading (TikTok/Reels Style)

```dart
// 1. Create your video item wrapper
class PostVideoItem extends VideoItem<PostModel> {
  PostVideoItem(PostModel post)
      : super(
          id: post.id,
          videoUrl: post.content.first.url,
          thumbnailUrl: post.thumbNail.isNotEmpty ? post.thumbNail.first : null,
          data: post,
        );

  @override
  PostVideoItem copyWithData(PostModel newData) => PostVideoItem(newData);
}

// 2. Create the cubit with pagination
final videoItems = posts.map((p) => PostVideoItem(p)).toList();

final videoCubit = VideoPaginationCubit<PostModel>(
  initialItems: videoItems,
  fetchPage: _fetchPage,  // Your API call
  videoConfig: VideoPreloadConfig(
    preloadAhead: 2,
    keepBehind: 1,
    maxConcurrentInits: 3,
  ),
  paginationConfig: PaginationConfig(
    fetchThreshold: 3,  // Fetch when 3 items from end
    pageSize: 10,
  ),
);

// 3. Use in PageView
PageView.builder(
  onPageChanged: (index) {
    videoCubit.onPageChanged(index);  // Handles everything
  },
  itemCount: state.items.length,
  itemBuilder: (context, index) {
    return VideoPlayerWidget(item: state.items[index]);
  },
)

// 4. Handle likes without reloading video
void _handleLike(PostModel post) {
  // Update cache
  cacheCubit.likePost(post.id, !post.liked);
  
  // Update video cubit (keeps controller alive)
  final updatedPost = post.copyWith(liked: !post.liked);
  videoCubit.updateItemData(post.id, updatedPost);
  
  // Fire API
  bloc.add(LikePostEvent(id: post.id));
}
```

### Download Manager

```dart
// Download a video
final downloadId = await context.read<DownloadCubit>().addDownload(
  url: 'https://example.com/video.mp4',
  fileName: 'my_video.mp4',
  type: DownloadType.video,
);

// Show downloads page
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const DownloadsListPage()),
);

// Listen to download completion
BlocListener<DownloadCubit, DownloadState>(
  listener: (context, state) {
    if (state.completedDownloads.isNotEmpty) {
      final latest = state.completedDownloads.last;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded: ${latest.fileName}')),
      );
    }
  },
)

// Pause/Resume/Cancel
context.read<DownloadCubit>().pauseDownload(downloadId);
context.read<DownloadCubit>().resumeDownload(downloadId);
context.read<DownloadCubit>().cancelDownload(downloadId);
```

### Push Notifications

```dart
// Initialize with config
await CommonNotificationService.instance.initialize(
  NotificationConfig.withDefaults(
    androidIcon: '@drawable/ic_notification',
    onTokenRefreshed: (token) => api.updateFcmToken(token),
    onNotificationTap: (payload) async {
      if (payload.deepLink != null) {
        router.push(payload.deepLink!);
        return true;
      }
      return false;
    },
    initialTopics: ['all_users'],
  ),
);

// Subscribe to topics after login
await CommonNotificationService.instance.subscribeMany([
  'user_${userId}',
  'vendors',
]);

// Show local notification
await CommonNotificationService.instance.show(
  title: 'New Message',
  body: 'You have a new message from John',
  channelId: 'messages',
);

// On logout
await CommonNotificationService.instance.unsubscribeAll();
await CommonNotificationService.instance.deleteToken();
```

### In-App Toast Notifications

```dart
// Wrap your MaterialApp
MaterialApp.router(
  builder: (context, child) => InAppNotificationOverlay(child: child!),
  routerConfig: router,
)

// Show toast anywhere
InAppNotificationController.instance.show(
  title: 'New Follower',
  body: '@john started following you',
  type: 'new_follower',
  onTap: () => router.push('/profile/john'),
);

// Add badge to nav icon
NavigationDestination(
  icon: NotificationBadge(
    child: Icon(Icons.notifications_outlined),
  ),
  label: 'Notifications',
)

// Show notification centre
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => NotificationCentrePage(
      onEntryTap: (entry) {
        if (entry.deepLink != null) router.push(entry.deepLink!);
      },
    ),
  ),
);
```

### Image Preloading

```dart
// Preload images
await ImagePreloadService().preloadRange(
  imageUrls,
  context,
  bufferSize: 5,
);

// Use cached image widget
CachedImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
)
```

### Mixed Media Feeds (Facebook Style)

```dart
// For feeds with mixed images and videos
final mediaItems = posts.map((p) => PostMediaItem(p)).toList();

final mediaCubit = MixedMediaCubit<PostModel>(items: mediaItems);
final videoCubit = LazyVideoCubit();

MultiBlocProvider(
  providers: [
    BlocProvider.value(value: mediaCubit),
    BlocProvider.value(value: videoCubit),
  ],
  child: MediaListView<PostModel>(
    items: mediaItems,
    overlayBuilder: (item) => _buildLikesCommentsUI(item),
    onItemTap: (item) => _openPost(item),
  ),
)
```

### String Extensions

```dart
// Validation
'test@example.com'.isValidEmail; // true
'+2348012345678'.isValidNigerianPhone; // true
'1234567890123456'.isValidCreditCard; // true

// Capitalization
'hello world'.toTitleCase; // "Hello World"
'some_variable'.toCamelCase; // "someVariable"

// Masking
'john@example.com'.maskEmail; // "j***@example.com"
'+2348012345678'.maskPhone; // "******5678"

// Truncation
'Very long text here'.truncate(10); // "Very long..."
```

### Validators

```dart
// In TextFormField
TextFormField(
  validator: Validators.emailValidator,
)

// Combine validators
TextFormField(
  validator: Validators.combine([
    Validators.required,
    (value) => Validators.minLengthValidator(value, 8),
    Validators.strongPasswordValidator,
  ]),
)

// Nigerian-specific
TextFormField(
  validator: Validators.bvnValidator, // 11-digit BVN
)
```

### Number Formatting

```dart
// Currency
1500000.toCurrency(); // "₦1,500,000.00"
1234567.toCompactString(); // "1.2M"

// Percentages
0.75.toPercentage(); // "75%"

// File sizes
1048576.toBytesString(); // "1.00 MB"

// Calculations
100.percentOf(20); // 20.0
100.addPercentage(10); // 110.0
```

### Bank Utilities

```dart
// Get banks list
final banks = await BankUtils.getNigerianBanks();

// Validate account
final validation = await BankUtils.validateAccount(
  accountNumber: '0123456789',
  bankCode: '058', // GTBank
);

if (validation.isValid) {
  print('Account Name: ${validation.accountName}');
}

// Search banks
final results = await BankUtils.searchBanks(
  query: 'Access',
  country: 'nigeria',
);
```

### Currency Conversion

```dart
// Convert currency
final conversion = await CurrencyUtils.convert(
  amount: 100,
  fromCurrency: 'USD',
  toCurrency: 'NGN',
);

print(conversion.formattedConversion);
// Output: $100.00 = ₦76,500.00

// Get exchange rates
final rates = await CurrencyUtils.getExchangeRates(baseCurrency: 'USD');
print('1 USD = ${rates.getRate('NGN')} NGN');

// Convert to multiple currencies
final multi = await CurrencyUtils.convertToMultiple(
  amount: 100,
  fromCurrency: 'USD',
  toCurrencies: ['NGN', 'GHS', 'EUR', 'GBP'],
);
```

### Country & Location

```dart
// Get all countries
final countries = await CountryUtils.getAllCountries();

// Get Nigerian states (offline, no API needed)
final states = CountryUtils.getNigerianStates();

// Get cities
final cities = await CountryUtils.getCities(
  countryCode: 'NG',
  stateCode: 'LA', // Lagos
);

// Get dial codes
final dialCodes = await CountryUtils.getDialCodes();
```

### Network Connectivity

```dart
// Check connection status
final status = await NetworkConnectivity.checkConnectivity();
print('Connected: ${status.isConnected}');
print('Type: ${status.connectionType.name}');

// Listen to changes
NetworkConnectivity.onConnectivityChanged.listen((status) {
  if (status.isConnected) {
    print('✓ Back online!');
  } else {
    print('✗ Connection lost');
  }
});

// Check connection quality
final quality = await NetworkConnectivity.getConnectionQuality();
print('Quality: ${quality.icon} ${quality.name}');

// Ping test
final ping = await NetworkConnectivity.ping(host: 'google.com');
print('Latency: ${ping.latencyMs}ms');

// Quick checks
if (NetworkConnectivity.isWifi) {
  print('Connected via WiFi');
}
```

## 🔧 Configuration

### FCM Setup (Android)

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Add to `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

Add `google-services.json` to `android/app/`

Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### FCM Setup (iOS)

1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Enable Push Notifications capability in Xcode
3. Enable Background Modes → Remote notifications
4. Upload APNs certificate to Firebase Console

## 🎯 Nigerian-Specific Features

- ✅ Nigerian phone number validation
- ✅ BVN (Bank Verification Number) validation
- ✅ NIN (National ID) validation
- ✅ Nigerian banks list (Access, GTBank, Zenith, etc.)
- ✅ Account number verification
- ✅ Nigerian states (all 36 + FCT) - offline
- ✅ Naira (₦) currency formatting
- ✅ Nigerian bank account format (10 digits)

## 📖 Documentation

Full documentation available at [your-docs-url.com](https://your-docs-url.com)

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues

Found a bug? Please [open an issue](https://github.com/mhista/common_utils/issues).

## ⭐ Support

If you find this package helpful, please give it a star on [GitHub](https://github.com/mhista/common_utils)!

## 📮 Contact

- **Author**: Diwe Innocent
- **Email**: diweesomchi@gmail.com
- **Website**: [https://innocentdiwe.qzz.io](https://innocentdiwe.qzz.io)

---

Made with ❤️ in Nigeria 🇳🇬