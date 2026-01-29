import 'dart:math' as math;

/// Number Extensions
/// Provides useful extensions for num, int, and double types
extension NumExtensions on num {
  // ==================== Formatting ====================

  /// Formats number with thousand separators
  /// Example: 1000000 => 1,000,000
  String toFormattedString({String separator = ','}) {
    final parts = toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final formatted = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formatted.write(separator);
      }
      formatted.write(integerPart[i]);
    }

    if (decimalPart.isNotEmpty) {
      formatted.write('.$decimalPart');
    }

    return formatted.toString();
  }

  /// Formats as currency (Nigerian Naira by default)
  /// Example: 1000 => ₦1,000.00
  String toCurrency({
    String symbol = '₦',
    int decimalPlaces = 2,
    String separator = ',',
  }) {
    final rounded = toStringAsFixed(decimalPlaces);
    final parts = rounded.split('.');
    final integerPart = int.parse(parts[0]).toFormattedString(separator: separator);
    final decimalPart = parts.length > 1 ? parts[1] : '';

    return '$symbol$integerPart${decimalPart.isNotEmpty ? '.$decimalPart' : ''}';
  }

  /// Formats as percentage
  /// Example: 0.75 => 75%
  String toPercentage({int decimalPlaces = 0}) {
    return '${(this * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// Formats with K, M, B suffixes
  /// Example: 1000000 => 1M
  String toCompactString({int decimalPlaces = 1}) {
    if (this < 1000) return toStringAsFixed(decimalPlaces);
    if (this < 1000000) {
      return '${(this / 1000).toStringAsFixed(decimalPlaces)}K';
    }
    if (this < 1000000000) {
      return '${(this / 1000000).toStringAsFixed(decimalPlaces)}M';
    }
    return '${(this / 1000000000).toStringAsFixed(decimalPlaces)}B';
  }

  // ==================== Rounding ====================

  /// Rounds to specified decimal places
  double roundToDecimal(int places) {
    final mod = math.pow(10.0, places);
    return ((this * mod).round().toDouble() / mod);
  }

  /// Rounds up to nearest integer
  int roundUp() => ceil();

  /// Rounds down to nearest integer
  int roundDown() => floor();

  // ==================== Range Validation ====================

  /// Checks if number is in range (inclusive)
  bool inRange(num min, num max) => this >= min && this <= max;

  /// Checks if number is between values (exclusive)
  bool between(num min, num max) => this > min && this < max;

  /// Clamps number between min and max
  num clamp(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  // ==================== Calculations ====================

  /// Calculates percentage of this number
  /// Example: 100.percentOf(20) => 20
  double percentOf(num percent) => this * (percent / 100);

  /// Calculates what percentage this number is of another
  /// Example: 25.percentageOf(100) => 25
  double percentageOf(num total) => (this / total) * 100;

  /// Adds percentage to this number
  /// Example: 100.addPercentage(10) => 110
  double addPercentage(num percent) => this + percentOf(percent);

  /// Subtracts percentage from this number
  /// Example: 100.subtractPercentage(10) => 90
  double subtractPercentage(num percent) => this - percentOf(percent);

  // ==================== Comparisons ====================

  /// Checks if number is even
  bool get isEven => this % 2 == 0;

  /// Checks if number is odd
  bool get isOdd => this % 2 != 0;

  /// Checks if number is positive
  bool get isPositive => this > 0;

  /// Checks if number is negative
  bool get isNegative => this < 0;

  /// Checks if number is zero
  bool get isZero => this == 0;

  // ==================== Conversions ====================

  /// Converts bytes to human-readable format
  /// Example: 1024 => 1 KB
  String toBytesString({int decimalPlaces = 2}) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    if (this <= 0) return '0 B';

    final digitGroups = (math.log(this) / math.log(1024)).floor();
    final value = this / math.pow(1024, digitGroups);

    return '${value.toStringAsFixed(decimalPlaces)} ${units[digitGroups]}';
  }
}
