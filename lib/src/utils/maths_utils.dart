
import 'dart:math' as math;

/// Math Utilities
/// Provides common mathematical operations and helpers
class MathUtils {
  MathUtils._();

  // ==================== Random Number Generation ====================

  /// Generates random integer between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + math.Random().nextInt(max - min + 1);
  }

  /// Generates random double between min and max
  static double randomDouble(double min, double max) {
    return min + math.Random().nextDouble() * (max - min);
  }

  /// Generates random boolean
  static bool randomBool() => math.Random().nextBool();

  // ==================== Number to Words ====================

  /// Converts number to words (supports up to billions)
  /// Example: 1234 => "one thousand two hundred thirty-four"
  static String numberToWords(int number) {
    if (number == 0) return 'zero';

    const ones = [
      '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
      'seventeen', 'eighteen', 'nineteen'
    ];

    const tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
    ];

    String convertHundreds(int n) {
      if (n == 0) return '';
      if (n < 20) return ones[n];
      if (n < 100) {
        return tens[n ~/ 10] + (n % 10 != 0 ? '-${ones[n % 10]}' : '');
      }
      return '${ones[n ~/ 100]} hundred${n % 100 != 0 ? ' ${convertHundreds(n % 100)}' : ''}';
    }

    if (number < 0) return 'negative ${numberToWords(-number)}';
    if (number < 1000) return convertHundreds(number);
    if (number < 1000000) {
      return '${convertHundreds(number ~/ 1000)} thousand${number % 1000 != 0 ? ' ${convertHundreds(number % 1000)}' : ''}';
    }
    if (number < 1000000000) {
      return '${convertHundreds(number ~/ 1000000)} million${number % 1000000 != 0 ? ' ${numberToWords(number % 1000000)}' : ''}';
    }
    return '${convertHundreds(number ~/ 1000000000)} billion${number % 1000000000 != 0 ? ' ${numberToWords(number % 1000000000)}' : ''}';
  }

  // ==================== Calculations ====================

  /// Calculates average of a list of numbers
  static double average(List<num> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce((a, b) => a + b) / numbers.length;
  }

  /// Calculates median of a list of numbers
  static double median(List<num> numbers) {
    if (numbers.isEmpty) return 0;
    final sorted = List<num>.from(numbers)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle].toDouble();
    }
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }

  /// Calculates mode of a list of numbers
  static num? mode(List<num> numbers) {
    if (numbers.isEmpty) return null;
    final frequency = <num, int>{};
    for (final num in numbers) {
      frequency[num] = (frequency[num] ?? 0) + 1;
    }
    final maxFrequency = frequency.values.reduce(math.max);
    return frequency.entries
        .firstWhere((entry) => entry.value == maxFrequency)
        .key;
  }

  /// Calculates sum of a list of numbers
  static num sum(List<num> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce((a, b) => a + b);
  }

  /// Calculates factorial
  static int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }

  /// Checks if number is prime
  static bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;

    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  /// Greatest common divisor
  static int gcd(int a, int b) {
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  /// Least common multiple
  static int lcm(int a, int b) {
    return (a * b) ~/ gcd(a, b);
  }

  // ==================== Distance & Geometry ====================

  /// Calculates distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }

  /// Converts degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Converts radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  // ==================== Financial Calculations ====================

  /// Calculates compound interest
  /// P = principal, r = rate (as decimal), t = time in years, n = compounds per year
  static double compoundInterest({
    required double principal,
    required double rate,
    required double time,
    int compoundsPerYear = 1,
  }) {
    return principal * math.pow(1 + (rate / compoundsPerYear), compoundsPerYear * time);
  }

  /// Calculates simple interest
  static double simpleInterest({
    required double principal,
    required double rate,
    required double time,
  }) {
    return principal * rate * time;
  }

  /// Calculates loan payment (EMI)
  static double loanPayment({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    final monthlyRate = annualRate / 12;
    if (monthlyRate == 0) return principal / months;
    return principal *
        (monthlyRate * math.pow(1 + monthlyRate, months)) /
        (math.pow(1 + monthlyRate, months) - 1);
  }

  // ==================== Statistics ====================

  /// Calculates standard deviation
  static double standardDeviation(List<num> numbers) {
    if (numbers.isEmpty) return 0;
    final avg = average(numbers);
    final variance = numbers
        .map((n) => math.pow(n - avg, 2))
        .reduce((a, b) => a + b) /
        numbers.length;
    return math.sqrt(variance);
  }

  /// Calculates variance
  static double variance(List<num> numbers) {
    if (numbers.isEmpty) return 0;
    final avg = average(numbers);
    return numbers
        .map((n) => math.pow(n - avg, 2))
        .reduce((a, b) => a + b) /
        numbers.length;
  }
}