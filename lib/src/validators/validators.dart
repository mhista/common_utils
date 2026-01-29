/// Validators
/// Comprehensive validation utilities for forms and data
class CommonValidators {
  CommonValidators._();

  // ==================== Email Validators ====================

  /// Validates email address
  static bool email(String? value) {
    if (value == null || value.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(value);
  }

  /// Email validator for TextFormField
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!email(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ==================== Phone Validators ====================

  /// Validates phone number (international format)
  static bool phone(String? value) {
    if (value == null || value.isEmpty) return false;
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''));
  }

  /// Phone validator for TextFormField
  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!phone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates Nigerian phone number
  static bool nigerianPhone(String? value) {
    if (value == null || value.isEmpty) return false;
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    final nigerianPhoneRegex = RegExp(
      r'^(\+?234|0)?[7-9][0-1]\d{8}$',
    );
    return nigerianPhoneRegex.hasMatch(cleaned);
  }

  /// Nigerian phone validator for TextFormField
  static String? nigerianPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!nigerianPhone(value)) {
      return 'Please enter a valid Nigerian phone number';
    }
    return null;
  }

  // ==================== Password Validators ====================

  /// Validates password strength
  /// Returns a PasswordStrength enum value
  static PasswordStrength passwordStrength(String? value) {
    if (value == null || value.isEmpty) return PasswordStrength.empty;
    if (value.length < 6) return PasswordStrength.weak;

    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;
    if (value.length >= 8) strength++;
    if (value.length >= 12) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Basic password validator
  static String? passwordValidator(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Strong password validator
  static String? strongPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates password confirmation
  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ==================== Name Validators ====================

  /// Validates name (only letters and spaces)
  static bool name(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value);
  }

  /// Name validator for TextFormField
  static String? nameValidator(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (!name(value)) {
      return 'Please enter a valid $fieldName';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  // ==================== URL Validators ====================

  /// Validates URL
  static bool url(String? value) {
    if (value == null || value.isEmpty) return false;
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(value);
  }

  /// URL validator for TextFormField
  static String? urlValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    if (!url(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // ==================== Credit Card Validators ====================

  /// Validates credit card using Luhn algorithm
  static bool creditCard(String? value) {
    if (value == null || value.isEmpty) return false;
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
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

  /// Credit card validator for TextFormField
  static String? creditCardValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }
    if (!creditCard(value)) {
      return 'Please enter a valid credit card number';
    }
    return null;
  }

  /// Validates CVV
  static bool cvv(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^\d{3,4}$').hasMatch(value);
  }

  /// CVV validator for TextFormField
  static String? cvvValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (!cvv(value)) {
      return 'Please enter a valid CVV';
    }
    return null;
  }

  // ==================== Nigerian-Specific Validators ====================

  /// Validates BVN (11 digits)
  static bool bvn(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^\d{11}$').hasMatch(value);
  }

  /// BVN validator for TextFormField
  static String? bvnValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'BVN is required';
    }
    if (!bvn(value)) {
      return 'Please enter a valid 11-digit BVN';
    }
    return null;
  }

  /// Validates NIN (11 digits)
  static bool nin(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^\d{11}$').hasMatch(value);
  }

  /// NIN validator for TextFormField
  static String? ninValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIN is required';
    }
    if (!nin(value)) {
      return 'Please enter a valid 11-digit NIN';
    }
    return null;
  }

  // ==================== Number Validators ====================

  /// Validates if string is a number
  static bool number(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Number validator for TextFormField
  static String? numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!number(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validates if number is in range
  static bool numberInRange(String? value, double min, double max) {
    if (value == null || value.isEmpty) return false;
    final num = double.tryParse(value);
    if (num == null) return false;
    return num >= min && num <= max;
  }

  /// Number range validator for TextFormField
  static String? numberRangeValidator(String? value, double min, double max) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!number(value)) {
      return 'Please enter a valid number';
    }
    if (!numberInRange(value, min, max)) {
      return 'Please enter a number between $min and $max';
    }
    return null;
  }

  // ==================== Length Validators ====================

  /// Validates minimum length
  static String? minLengthValidator(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLengthValidator(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates exact length
  static String? exactLengthValidator(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length != length) {
      return '${fieldName ?? 'This field'} must be exactly $length characters';
    }
    return null;
  }

  // ==================== Required Field Validators ====================

  /// Required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // ==================== Custom Validators ====================

  /// Custom regex validator
  static String? regexValidator(
    String? value,
    String pattern, {
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!RegExp(pattern).hasMatch(value)) {
      return errorMessage ?? 'Invalid format';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

/// Password strength enum
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

/// Extension on PasswordStrength
extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return 'Empty';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}