# Your Company Utils

[![pub package](https://img.shields.io/pub/v/your_company_utils.svg)](https://pub.dev/packages/your_company_utils)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter utilities package that provides essential tools for rapid app development. From string manipulation to network monitoring, currency conversion to bank validation - everything you need in one package.

## ✨ Features

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
  common_utils: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Initialize in your app

```dart
import 'package:common_utils/common_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  
  runApp(MyApp());
}
```

## 📚 Usage Examples

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

### Storage

```dart
final storage = StorageService.instance;

// Simple storage
await storage.setString('username', 'John');
final username = storage.getString('username');

// JSON storage
await storage.setJson('user', {'name': 'John', 'age': 30});
final user = storage.getJson('user');

// Batch operations
await storage.setBatch({
  'key1': 'value1',
  'key2': 123,
  'key3': true,
});
```

### HTTP Client

```dart
final client = HttpClient(baseUrl: 'https://api.example.com');

// GET request
final response = await client.get<Map<String, dynamic>>('/users');

if (response.isSuccess) {
  print(response.data);
}

// POST with authentication
client.setAuthToken(token);
final result = await client.post<User>(
  '/users',
  data: {'name': 'John', 'email': 'john@example.com'},
  parser: (data) => User.fromJson(data),
);

// File upload
await client.uploadFile('/upload', imageFile);
```

### Logger (Talker)

```dart
final logger = LoggerService.instance;

// Basic logging
logger.info('User logged in');
logger.error('Failed to load data');
logger.debug('API response received');

// HTTP logging
logger.logHttpRequest(
  method: 'GET',
  url: 'https://api.example.com/users',
);

// Performance logging
final stopwatch = Stopwatch()..start();
// ... perform operation
stopwatch.stop();

logger.logPerformance(
  operation: 'Data Processing',
  duration: stopwatch.elapsed,
);

// Navigation logging
logger.logNavigation(from: '/home', to: '/profile');
```

### Responsive Design

```dart
// Check device type
if (ResponsiveHelper.isMobile(context)) {
  // Mobile layout
}

// Responsive values
final padding = ResponsiveHelper.responsivePadding(
  context: context,
  mobile: 16,
  tablet: 24,
  desktop: 32,
);

// Responsive widget
ResponsiveBuilder(
  builder: (context, screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return MobileLayout();
      case ScreenType.tablet:
        return TabletLayout();
      case ScreenType.desktop:
        return DesktopLayout();
    }
  },
)
```

### Image Utilities

```dart
// Pick image
final image = await ImageUtils.pickFromGallery();

// Compress image
final compressed = await ImageUtils.compressImage(
  imageFile,
  quality: 85,
);

// Convert to base64
final base64 = await ImageUtils.fileToBase64(imageFile);

// Validate size
final isValid = await ImageUtils.validateImageSize(
  imageFile,
  5.0, // Max 5MB
);
```

### Encryption

```dart
// Hash password
final hashed = EncryptionUtils.hashPassword('password123');
final isValid = EncryptionUtils.verifyPassword('password123', hashed);

// AES encryption
final encrypted = EncryptionUtils.aesEncrypt('secret data', 'key');
final decrypted = EncryptionUtils.aesDecrypt(encrypted, 'key');

// Generate tokens
final apiKey = EncryptionUtils.generateAPIKey();
final otp = EncryptionUtils.generateOTP(6);

// SHA-256 hash
final hash = EncryptionUtils.sha256Hash('data');
```

### Format Utilities

```dart
// Phone numbers
FormatUtils.formatNigerianPhone('08012345678');
// Output: +234 801 234 5678

// Dates
FormatUtils.formatDate(DateTime.now()); // Jan 29, 2026
FormatUtils.formatRelativeTime(yesterday); // 1 day ago

// File sizes
FormatUtils.formatFileSize(1048576); // 1.00 MB

// Lists
FormatUtils.formatList(['a', 'b', 'c']); // "a, b, and c"
```

## 🔧 API Keys Setup

Some utilities require API keys (all have free tiers):

### Paystack (Bank Utils)
```dart
BankUtils.init(
  paystackSecretKey: 'sk_test_xxxxx', // Get from paystack.com
);
```

### CountryStateCity (States/Cities)
```dart
CountryUtils.init(
  cscApiKey: 'your_key', // Get from countrystatecity.in
);
```

### Note on Currency Utils
- **No API key required!** 
- Uses free exchangerate-api.com and frankfurter.app
- 1500+ requests per month on free tier

## 📱 Form Field Widgets

### Bank Account Form

```dart
DropdownButtonFormField<Bank>(
  items: banks.map((bank) {
    return DropdownMenuItem(
      value: bank,
      child: Text(bank.name),
    );
  }).toList(),
  onChanged: (bank) => selectedBank = bank,
)
```

### Country Selector

```dart
DropdownButtonFormField<Country>(
  items: countries.map((country) {
    return DropdownMenuItem(
      value: country,
      child: Text('${country.flag} ${country.name}'),
    );
  }).toList(),
  onChanged: (country) => selectedCountry = country,
)
```

### Phone Number with Dial Code

```dart
Row(
  children: [
    DropdownButton<DialCode>(
      value: selectedDialCode,
      items: dialCodes.map((dc) {
        return DropdownMenuItem(
          value: dc,
          child: Text('${dc.flag} ${dc.dialCode}'),
        );
      }).toList(),
    ),
    Expanded(
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Phone Number'),
      ),
    ),
  ],
)
```

## 🎯 Nigerian-Specific Features

- ✅ Nigerian phone number validation
- ✅ BVN (Bank Verification Number) validation
- ✅ NIN (National ID) validation
- ✅ Nigerian banks list (Access, GTBank, Zenith, etc.)
- ✅ Account number verification
- ✅ Nigerian states (all 36 + FCT) - offline
- ✅ Naira (₦) currency formatting
- ✅ Nigerian bank account format (10 digits)

<!-- ## 📖 Documentation

Full documentation available at [your-docs-url.com](https://your-docs-url.com) -->

## 🤝 Contributing

Contributions are welcome! 
<!-- Please read our [contributing guidelines](CONTRIBUTING.md). -->

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues

Found a bug? Please [open an issue](https://github.com/mhista/common_utils/issues).

## ⭐ Support

If you find this package helpful, please give it a star on [GitHub](https://github.com/mhista/common_utils)!

## 📮 Contact

- **Author**: Diwe Innocent
- **Email**: diweesomchi@gmail.com
- **Website**: [https://innocentdiwe.qzz.io](https://.com)

---

Made with ❤️ in Nigeria 🇳🇬