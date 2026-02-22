// ============================================================================
// COMMON UTILITIES LIBRARY - PUBLIC API EXPORTS
// ============================================================================
// This file serves as the main entry point for the common utilities package.
// All public APIs are exported here for easy access throughout the application.
// ============================================================================

// ============================================================================
// HELPERS
// ============================================================================

library;

/// Commerce helper functions for e-commerce operations like cart, pricing, etc.
export 'src/helpers/commerce_helper_functions.dart';

/// Date and time manipulation utilities for formatting, parsing, and calculations
export 'src/helpers/date_helper.dart';

/// Pricing calculation utilities for discounts, taxes, shipping costs, etc.
export 'src/helpers/pricing_calculator.dart';

/// Debouncer and throttler utilities for rate-limiting function calls
/// Useful for search inputs, API calls, and performance optimization
export 'src/helpers/debouncer_throttler.dart';

/// Device information helper for getting device details, model, OS version, etc.
export 'src/helpers/device_info_helper.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// Common enumerations used across the application
/// Includes status types, categories, and other shared enum values
export 'src/enums/common_enums.dart';

// ============================================================================
// SERVICES
// ============================================================================

/// Hive-based local storage service with user-specific data isolation
/// Singleton pattern for persistent data storage using Hive
export 'src/services/storage/hive_storage.dart';

/// SharedPreferences-based storage service for simple key-value persistence
/// Alternative to Hive for lightweight storage needs
export 'src/services/storage/shared_pref_storage.dart';


/// Secured storage storage service for secured key-value persistence
/// Alternative to Hive and sharedpreferences for secure storage needs
export 'src/services/storage/secure_storage_service.dart';
export 'src/services/storage/secure_storage_exports.dart';

/// HTTP client service for making API requests with built-in error handling
/// Supports GET, POST, PUT, DELETE with authentication and interceptors
export 'src/services/http/http_client.dart';

/// Location service for getting device GPS coordinates and location updates
/// Handles permissions and provides both one-time and continuous location tracking
export 'src/services/location_service.dart';

/// Logger service for centralized logging throughout the application
/// Supports different log levels (debug, info, warning, error)
export 'src/services/logger_service.dart';

/// Network connectivity service for monitoring internet connection status
/// Provides real-time connectivity updates and connection type detection
export 'src/services/network_connectivity.dart';

/// HTTP auth interceptor for attaching tokens and handling auth errors
/// Used by `http_client` to automatically add authorization headers
export 'src/services/auth/auth_interceptor.dart';

/// Token manager for storing and refreshing authentication tokens
/// Provides secure token lifetime management and expiry checks
export 'src/services/auth/token_manager.dart';

// ============================================================================
// VALIDATORS
// ============================================================================

/// Form validation utilities for email, phone, password, etc.
/// Provides reusable validators for common input validation scenarios
export 'src/validators/validators.dart';

// ============================================================================
// EXCEPTIONS
// ============================================================================

/// Custom Firebase exception handling with user-friendly error messages
/// Wraps Firebase errors into readable exceptions
export 'src/exceptions/firebase_exception.dart';

/// Firebase Authentication specific exception handling
/// Provides detailed error messages for auth-related failures
export 'src/exceptions/firebase_auth_exceptions.dart';

/// Format exception handling for parsing and data conversion errors
/// Used when data format doesn't match expected structure
export 'src/exceptions/format_exceptions.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

/// Storage key constants for consistent data persistence across the app
/// Centralized location for all SharedPreferences and Hive storage keys
export 'src/constants/storage_keys.dart';

// ============================================================================
// DEVICE & RESPONSIVE
// ============================================================================

/// Comprehensive responsive design and device utilities
/// Includes breakpoints, responsive values, device detection, and system UI controls
/// Merged utility combining responsive design, device info, and platform detection
export 'src/device/responsive_helper.dart';

// ============================================================================
// EXTENSIONS
// ============================================================================

/// Collection extensions for List, Set, Map operations
/// Adds utility methods like firstWhereOrNull, groupBy, safeGet, etc.
export 'src/extensions/collection_extensions.dart';

/// Number extensions (int, double) for formatting and calculations
/// Provides methods like toCurrency, toPercent, isEven, isOdd, etc.
export 'src/extensions/num_extensions.dart';

/// String extensions for common string operations
/// Includes capitalization, validation, formatting, and parsing utilities
export 'src/extensions/string_extensions.dart';

/// Text widget extensions for easier styling and formatting
/// Simplifies TextStyle application and common text modifications
export 'src/extensions/text_extensions.dart';

// ============================================================================
// MODELS
// ============================================================================

/// Result type for handling success/failure operations
/// Provides a type-safe way to handle operations that can succeed or fail
/// Usage: Result<T> where T is the success data type
export 'src/models/result.dart';

// ============================================================================
// NOTIFICATIONS
// ============================================================================

/// Notification payload model for standardized message content
export 'src/notifications/notification_payload.dart';

/// Notification configuration utilities for channels and behavior
export 'src/notifications/notification_config.dart';

/// Notification channel helpers for platform-specific channel creation
export 'src/notifications/notification_channel.dart';

/// High-level notifications API for scheduling and showing notifications
export 'src/notifications/notifications.dart';

/// Common notification service abstraction for platform implementations
export 'src/notifications/common_notification_service.dart';

/// Notification managers (topic, token, display) for handling subscriptions
export 'src/notifications/managers/topic_manager.dart';
export 'src/notifications/managers/notification_token_manager.dart';
export 'src/notifications/managers/display_manager.dart';

/// Notification handler interfaces and default implementations
export 'src/notifications/handlers/i_notification_handler.dart';
export 'src/notifications/handlers/default_notification_handler.dart';

// ============================================================================
// UTILITIES
// ============================================================================

/// Bank-related utilities for account validation, routing numbers, etc.
/// Supports validation of bank account numbers, sort codes, and IBAN
export 'src/utils/bank_utils.dart';

/// Color manipulation utilities for hex conversion, brightness, contrast, etc.
/// Provides methods for color parsing, generation, and manipulation
export 'src/utils/color_utils.dart';

/// Country-related utilities including country codes, flags, phone prefixes
/// Comprehensive country data for internationalization
export 'src/utils/country_utils.dart';

/// Currency utilities for formatting, conversion, and symbol handling
/// Supports multiple currencies with proper formatting and symbols
export 'src/utils/currency_utils.dart';

/// Encryption and decryption utilities for securing sensitive data
/// Provides AES, RSA encryption and secure hashing methods
export 'src/utils/encryption_utils.dart';

/// File operation utilities for reading, writing, copying, and deleting files
/// Handles file system operations with error handling
export 'src/utils/file_utils.dart';

/// Formatting utilities for dates, numbers, phone numbers, etc.
/// Centralized location for all formatting operations
export 'src/utils/format_utils.dart';

/// Image processing utilities for compression, resizing, and conversion
/// Handles image manipulation and optimization
export 'src/utils/image_utils.dart';

/// Mathematical utilities for common calculations and operations
/// Includes percentage, average, median, rounding, and more
export 'src/utils/maths_utils.dart';

/// Regular expression patterns for validation
/// Centralized regex patterns for email, phone, URL, etc.
/// Reusable patterns to ensure consistent validation across the app
export 'src/utils/regex_patterns.dart';

// ============================================================================
// USAGE NOTES
// ============================================================================
// 
// To use this package in your project:
// 
// 1. Import the entire package:
//    import 'package:your_package_name/your_package_name.dart';
//
// 2. Or import specific utilities:
//    import 'package:your_package_name/your_package_name.dart' show ResponsiveHelper, HiveStorageService;
//
// 3. Initialize services in main.dart:
//    await HiveStorageService.init();
//    await NetworkConnectivity.instance.initialize();
//
// 4. Access singletons:
//    final storage = HiveStorageService.instance;
//    final logger = LoggerService.instance;
//
// ============================================================================