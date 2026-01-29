import 'package:intl/intl.dart';

/// Format Utilities
/// Helper methods for formatting various data types
class FormatUtils {
  FormatUtils._();

  // ==================== Number Formatting ====================

  /// Format number with thousand separators
  static String formatNumber(num number, {String locale = 'en_US'}) {
    final formatter = NumberFormat('#,###', locale);
    return formatter.format(number);
  }

  /// Format as currency
  static String formatCurrency(
    num amount, {
    String symbol = '₦',
    int decimalDigits = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
      locale: locale,
    );
    return formatter.format(amount);
  }

  /// Format as compact currency (1K, 1M, 1B)
  static String formatCompactCurrency(
    num amount, {
    String symbol = '₦',
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.compactCurrency(
      symbol: symbol,
      locale: locale,
    );
    return formatter.format(amount);
  }

  /// Format as percentage
  static String formatPercentage(
    num value, {
    int decimalDigits = 0,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.percentPattern(locale);
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  /// Format decimal number
  static String formatDecimal(
    num number, {
    int decimalDigits = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.decimalPattern(locale);
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(number);
  }

  // ==================== Phone Number Formatting ====================

  /// Format Nigerian phone number
  /// Converts 08012345678 to +234 801 234 5678
  static String formatNigerianPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.startsWith('234')) {
      // Already has country code
      final number = cleaned.substring(3);
      return '+234 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
    } else if (cleaned.startsWith('0')) {
      // Remove leading 0
      final number = cleaned.substring(1);
      return '+234 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
    }
    
    return phone;
  }

  /// Format US phone number
  /// Converts 1234567890 to (123) 456-7890
  static String formatUSPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      final number = cleaned.substring(1);
      return '+1 (${number.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6)}';
    }
    
    return phone;
  }

  /// Format international phone number (generic)
  static String formatInternationalPhone(String phone, String countryCode) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return '+$countryCode ${cleaned.substring(0, 3)} ${cleaned.substring(3)}';
  }

  // ==================== Credit Card Formatting ====================

  /// Format credit card number with spaces
  /// Converts 1234567890123456 to 1234 5678 9012 3456
  static String formatCreditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    
    return buffer.toString();
  }

  /// Format expiry date (MM/YY)
  static String formatCardExpiry(String expiry) {
    final cleaned = expiry.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    
    return cleaned;
  }

  // ==================== Date & Time Formatting ====================

  /// Format date to readable string
  static String formatDate(
    DateTime date, {
    String format = 'MMM dd, yyyy',
    String locale = 'en_US',
  }) {
    final formatter = DateFormat(format, locale);
    return formatter.format(date);
  }

  /// Format time
  static String formatTime(
    DateTime time, {
    bool use24Hour = false,
    String locale = 'en_US',
  }) {
    final format = use24Hour ? 'HH:mm' : 'hh:mm a';
    final formatter = DateFormat(format, locale);
    return formatter.format(time);
  }

  /// Format date and time
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'MMM dd, yyyy HH:mm',
    String locale = 'en_US',
  }) {
    final formatter = DateFormat(format, locale);
    return formatter.format(dateTime);
  }

  /// Format relative time (time ago)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // ==================== File Size Formatting ====================

  /// Format bytes to human-readable string
  static String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    final value = bytes / (1 << (i * 10));
    return '${value.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // ==================== Duration Formatting ====================

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format duration in a compact way
  static String formatDurationCompact(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // ==================== Name Formatting ====================

  /// Format name to title case
  static String formatName(String name) {
    return name
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Get initials from name
  static String getInitials(String name, {int maxInitials = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(maxInitials)
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase())
        .join();
    return initials;
  }

  // ==================== Address Formatting ====================

  /// Format address from components
  static String formatAddress({
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) {
    final parts = <String>[];
    
    if (street != null && street.isNotEmpty) parts.add(street);
    if (city != null && city.isNotEmpty) parts.add(city);
    if (state != null && state.isNotEmpty) parts.add(state);
    if (zipCode != null && zipCode.isNotEmpty) parts.add(zipCode);
    if (country != null && country.isNotEmpty) parts.add(country);
    
    return parts.join(', ');
  }

  // ==================== List Formatting ====================

  /// Join list with commas and "and" for last item
  static String formatList(
    List<String> items, {
    String separator = ', ',
    String lastSeparator = ' and ',
  }) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    if (items.length == 2) return items.join(lastSeparator);
    
    final allButLast = items.take(items.length - 1).join(separator);
    return '$allButLast$lastSeparator${items.last}';
  }

  // ==================== Misc Formatting ====================

  /// Truncate text with ellipsis
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Format boolean as Yes/No
  static String formatBoolean(bool value) {
    return value ? 'Yes' : 'No';
  }

  /// Format null value
  static String formatNullable(dynamic value, {String nullValue = 'N/A'}) {
    return value?.toString() ?? nullValue;
  }
}

/// Common date format patterns
class DateFormats {
  DateFormats._();

  static const String fullDate = 'EEEE, MMMM dd, yyyy';
  static const String longDate = 'MMMM dd, yyyy';
  static const String mediumDate = 'MMM dd, yyyy';
  static const String shortDate = 'MM/dd/yyyy';
  static const String isoDate = 'yyyy-MM-dd';
  
  static const String fullTime = 'hh:mm:ss a';
  static const String mediumTime = 'hh:mm a';
  static const String shortTime = 'HH:mm';
  
  static const String fullDateTime = 'EEEE, MMMM dd, yyyy hh:mm a';
  static const String longDateTime = 'MMMM dd, yyyy hh:mm a';
  static const String mediumDateTime = 'MMM dd, yyyy HH:mm';
  static const String shortDateTime = 'MM/dd/yyyy HH:mm';
  static const String isoDateTime = "yyyy-MM-dd'T'HH:mm:ss";
}