/// String Extensions
/// Provides useful extensions for String manipulation
extension StringExtensions on String {
  // ==================== Validation ====================
  
  /// Validates if the string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Validates if the string is a valid phone number
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[\s-]'), ''));
  }

  /// Validates if the string is a valid URL
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Validates if the string is a valid credit card number (Luhn algorithm)
  bool get isValidCreditCard {
    final cleaned = replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 13 || cleaned.length > 19) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Validates if string contains only numbers
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Validates if string contains only letters
  bool get isAlphabetic {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Validates if string contains only alphanumeric characters
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  // ==================== Capitalization ====================

  /// Capitalizes the first letter of the string
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts string to title case (first letter of each word capitalized)
  String get toTitleCase {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalizeFirst)
        .join(' ');
  }

  /// Converts string to sentence case (first letter capitalized, rest lowercase)
  String get toSentenceCase {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Converts to camelCase
  String get toCamelCase {
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalizeFirst).join();
  }

  /// Converts to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'[\s-]+'), '_').replaceFirst(RegExp(r'^_'), '');
  }

  /// Converts to kebab-case
  String get toKebabCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '-${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'[\s_]+'), '-').replaceFirst(RegExp(r'^-'), '');
  }

  // ==================== Truncation & Formatting ====================

  /// Truncates string to specified length and adds ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Truncates to word boundary
  String truncateWords(int maxWords, {String ellipsis = '...'}) {
    final words = split(' ');
    if (words.length <= maxWords) return this;
    return '${words.take(maxWords).join(' ')}$ellipsis';
  }

  /// Removes all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Removes extra whitespace (multiple spaces to single space)
  String get removeExtraWhitespace {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Removes special characters, keeping only alphanumeric and spaces
  String get removeSpecialCharacters {
    return replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  // ==================== Masking ====================

  /// Masks email (e.g., j***@example.com)
  String get maskEmail {
    if (!isValidEmail) return this;
    final parts = split('@');
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return this;
    return '${username[0]}${'*' * (username.length - 1)}@$domain';
  }

  /// Masks phone number (e.g., +234***1234)
  String get maskPhone {
    if (length < 4) return this;
    final lastFour = substring(length - 4);
    final masked = '*' * (length - 4);
    return '$masked$lastFour';
  }

  /// Masks credit card (e.g., **** **** **** 1234)
  String get maskCreditCard {
    final cleaned = replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 4) return this;
    final lastFour = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $lastFour';
  }

  /// Generic masking with custom pattern
  String mask({
    int visibleStart = 0,
    int visibleEnd = 4,
    String maskChar = '*',
  }) {
    if (length <= visibleStart + visibleEnd) return this;
    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final masked = maskChar * (length - visibleStart - visibleEnd);
    return '$start$masked$end';
  }

  // ==================== URL & Slug ====================

  /// Converts string to URL-friendly slug
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceFirst(RegExp(r'^-'), '')
        .replaceFirst(RegExp(r'-$'), '');
  }

  // ==================== Counting & Analysis ====================

  /// Counts words in string
  int get wordCount {
    return trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  /// Counts characters excluding whitespace
  int get characterCountNoSpaces {
    return replaceAll(RegExp(r'\s'), '').length;
  }

  /// Checks if string is a palindrome
  bool get isPalindrome {
    final cleaned = toLowerCase().removeWhitespace;
    return cleaned == cleaned.split('').reversed.join();
  }

  /// Reverses the string
  String get reverse {
    return split('').reversed.join();
  }

  // ==================== Parsing ====================

  /// Safely parses to int, returns null if invalid
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// Safely parses to double, returns null if invalid
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// Parses to int with default value
  int toInt({int defaultValue = 0}) {
    return int.tryParse(this) ?? defaultValue;
  }

  /// Parses to double with default value
  double toDouble({double defaultValue = 0.0}) {
    return double.tryParse(this) ?? defaultValue;
  }

  // ==================== Nigerian-Specific Validators ====================

  /// Validates Nigerian phone number
  bool get isValidNigerianPhone {
    final cleaned = replaceAll(RegExp(r'[\s-]'), '');
    // Matches: 080, 081, 070, 090, 091, +234, etc.
    final nigerianPhoneRegex = RegExp(
      r'^(\+?234|0)?[7-9][0-1]\d{8}$',
    );
    return nigerianPhoneRegex.hasMatch(cleaned);
  }

  /// Validates BVN (Bank Verification Number - 11 digits)
  bool get isValidBVN {
    return RegExp(r'^\d{11}$').hasMatch(this);
  }

  /// Validates NIN (National Identification Number - 11 digits)
  bool get isValidNIN {
    return RegExp(r'^\d{11}$').hasMatch(this);
  }

  // ==================== Utilities ====================

  /// Extracts numbers from string
  String get extractNumbers {
    return replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Extracts letters from string
  String get extractLetters {
    return replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// Checks if string is blank (null, empty or whitespace)
  bool get isBlank {
    return trim().isEmpty;
  }

  /// Checks if string is not blank
  bool get isNotBlank {
    return !isBlank;
  }

  /// Returns the string or a default value if blank
  String or(String defaultValue) {
    return isBlank ? defaultValue : this;
  }

  
}
