/// Regex Patterns
/// Common regex patterns for validation and parsing
class RegexPatterns {
  RegexPatterns._();

  // ==================== Email Patterns ====================

  /// Standard email pattern
  static final email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Stricter email pattern
  static final emailStrict = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  // ==================== Phone Patterns ====================

  /// International phone number
  static final phoneInternational = RegExp(r'^\+?[1-9]\d{1,14}$');

  /// US phone number
  static final phoneUS = RegExp(
    r'^(\+1)?[-.\s]?\(?[2-9]\d{2}\)?[-.\s]?\d{3}[-.\s]?\d{4}$',
  );

  /// Nigerian phone number
  static final phoneNigerian = RegExp(
    r'^(\+?234|0)?[7-9][0-1]\d{8}$',
  );

  /// UK phone number
  static final phoneUK = RegExp(r'^(\+44|0)?[1-9]\d{9,10}$');

  // ==================== URL Patterns ====================

  /// Basic URL pattern
  static final url = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// URL with optional protocol
  static final urlOptionalProtocol = RegExp(
    r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  // ==================== Password Patterns ====================

  /// At least 8 characters
  static final passwordMinLength = RegExp(r'^.{8,}$');

  /// Contains uppercase letter
  static final passwordUppercase = RegExp(r'[A-Z]');

  /// Contains lowercase letter
  static final passwordLowercase = RegExp(r'[a-z]');

  /// Contains digit
  static final passwordDigit = RegExp(r'\d');

  /// Contains special character
  static final passwordSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Strong password (8+ chars, upper, lower, digit, special)
  static final passwordStrong = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
  );

  // ==================== Credit Card Patterns ====================

  /// Visa
  static final creditCardVisa = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');

  /// Mastercard
  static final creditCardMastercard = RegExp(
    r'^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$',
  );

  /// American Express
  static final creditCardAmex = RegExp(r'^3[47][0-9]{13}$');

  /// Discover
  static final creditCardDiscover = RegExp(
    r'^65[4-9][0-9]{13}|64[4-9][0-9]{13}|6011[0-9]{12}|(622(?:12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[01][0-9]|92[0-5])[0-9]{10})$',
  );

  /// Any credit card (generic)
  static final creditCardGeneric = RegExp(r'^\d{13,19}$');

  /// CVV
  static final cvv = RegExp(r'^\d{3,4}$');

  // ==================== Nigerian-Specific Patterns ====================

  /// BVN (Bank Verification Number) - 11 digits
  static final bvn = RegExp(r'^\d{11}$');

  /// NIN (National Identification Number) - 11 digits
  static final nin = RegExp(r'^\d{11}$');

  /// Nigerian bank account number - 10 digits
  static final bankAccountNigeria = RegExp(r'^\d{10}$');

  // ==================== Name Patterns ====================

  /// Only letters and spaces
  static final nameBasic = RegExp(r"^[a-zA-Z\s]+$");

  /// Letters, spaces, hyphens, apostrophes
  static final nameExtended = RegExp(r"^[a-zA-Z\s'-]+$");

  // ==================== Number Patterns ====================

  /// Integer
  static final integer = RegExp(r'^-?\d+$');

  /// Positive integer
  static final positiveInteger = RegExp(r'^\d+$');

  /// Decimal number
  static final decimal = RegExp(r'^-?\d*\.?\d+$');

  /// Only digits
  static final digitsOnly = RegExp(r'^\d+$');

  // ==================== Alphanumeric Patterns ====================

  /// Alphanumeric only
  static final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  /// Alphanumeric with spaces
  static final alphanumericWithSpaces = RegExp(r'^[a-zA-Z0-9\s]+$');

  /// Username (alphanumeric, underscore, hyphen, 3-16 chars)
  static final username = RegExp(r'^[a-zA-Z0-9_-]{3,16}$');

  // ==================== Color Patterns ====================

  /// Hex color (#RGB or #RRGGBB)
  static final hexColor = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');

  /// Hex color with alpha (#AARRGGBB)
  static final hexColorWithAlpha = RegExp(r'^#?[A-Fa-f0-9]{8}$');

  // ==================== Date Patterns ====================

  /// Date in format YYYY-MM-DD
  static final dateYMD = RegExp(
    r'^\d{4}-\d{2}-\d{2}$',
  );

  /// Date in format DD/MM/YYYY
  static final dateDMY = RegExp(
    r'^\d{2}/\d{2}/\d{4}$',
  );

  /// Date in format MM/DD/YYYY
  static final dateMDY = RegExp(
    r'^\d{2}/\d{2}/\d{4}$',
  );

  /// Time in format HH:MM
  static final time24Hour = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

  /// Time in format HH:MM AM/PM
  static final time12Hour = RegExp(
    r'^(0?[1-9]|1[0-2]):([0-5]\d)\s?(AM|PM|am|pm)$',
  );

  // ==================== IP Address Patterns ====================

  /// IPv4 address
  static final ipv4 = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );

  /// IPv6 address
  static final ipv6 = RegExp(
    r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$',
  );

  // ==================== File Patterns ====================

  /// File extension
  static final fileExtension = RegExp(r'\.([a-zA-Z0-9]+)$');

  /// Image file extensions
  static final imageFile = RegExp(
    r'\.(jpg|jpeg|png|gif|bmp|svg|webp)$',
    caseSensitive: false,
  );

  /// Video file extensions
  static final videoFile = RegExp(
    r'\.(mp4|avi|mkv|mov|wmv|flv|webm)$',
    caseSensitive: false,
  );

  /// Document file extensions
  static final documentFile = RegExp(
    r'\.(pdf|doc|docx|txt|xls|xlsx|ppt|pptx)$',
    caseSensitive: false,
  );

  // ==================== Social Media Patterns ====================

  /// Twitter/X username
  static final twitterUsername = RegExp(r'^@?[A-Za-z0-9_]{1,15}$');

  /// Instagram username
  static final instagramUsername = RegExp(r'^@?[A-Za-z0-9._]{1,30}$');

  /// Facebook URL
  static final facebookUrl = RegExp(
    r'^https?:\/\/(www\.)?facebook\.com\/.*$',
  );

  /// Twitter/X URL
  static final twitterUrl = RegExp(
    r'^https?:\/\/(www\.)?(twitter|x)\.com\/.*$',
  );

  /// Instagram URL
  static final instagramUrl = RegExp(
    r'^https?:\/\/(www\.)?instagram\.com\/.*$',
  );

  // ==================== Misc Patterns ====================

  /// UUID
  static final uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Slug (URL-friendly string)
  static final slug = RegExp(r'^[a-z0-9-]+$');

  /// HTML tags
  static final htmlTags = RegExp(r'<[^>]*>');

  /// Whitespace only
  static final whitespaceOnly = RegExp(r'^\s+$');

  /// Contains emoji
  static final containsEmoji = RegExp(
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
  );
}

/// Helper methods for regex patterns
class RegexHelper {
  RegexHelper._();

  /// Test if string matches pattern
  static bool matches(String input, RegExp pattern) {
    return pattern.hasMatch(input);
  }

  /// Extract first match
  static String? extractFirst(String input, RegExp pattern) {
    final match = pattern.firstMatch(input);
    return match?.group(0);
  }

  /// Extract all matches
  static List<String> extractAll(String input, RegExp pattern) {
    return pattern.allMatches(input).map((m) => m.group(0)!).toList();
  }

  /// Replace all matches
  static String replaceAll(String input, RegExp pattern, String replacement) {
    return input.replaceAll(pattern, replacement);
  }

  /// Remove all matches
  static String removeAll(String input, RegExp pattern) {
    return input.replaceAll(pattern, '');
  }

  /// Count matches
  static int countMatches(String input, RegExp pattern) {
    return pattern.allMatches(input).length;
  }
}