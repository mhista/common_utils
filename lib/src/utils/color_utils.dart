import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Color Utilities
/// Provides color conversion, manipulation, and generation utilities
class ColorUtils {
  ColorUtils._();

  // ==================== Hex Conversion ====================

  /// Convert hex string to Color
  /// Supports formats: #RGB, #ARGB, #RRGGBB, #AARRGGBB
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert Color to hex string
  static String toHex(Color color, {bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  // ==================== Color Brightness ====================

  /// Calculate luminance (0.0 - 1.0)
  static double getLuminance(Color color) {
    return color.computeLuminance();
  }

  /// Check if color is dark
  static bool isDark(Color color) {
    return getLuminance(color) < 0.5;
  }

  /// Check if color is light
  static bool isLight(Color color) {
    return !isDark(color);
  }

  /// Get contrasting color (black or white) for text
  static Color getContrastColor(Color backgroundColor) {
    return isDark(backgroundColor) ? Colors.white : Colors.black;
  }

  /// Calculate contrast ratio between two colors (1-21)
  static double getContrastRatio(Color color1, Color color2) {
    final lum1 = getLuminance(color1);
    final lum2 = getLuminance(color2);
    final lighter = math.max(lum1, lum2);
    final darker = math.min(lum1, lum2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast ratio meets WCAG AA standard (4.5:1)
  static bool meetsWCAG_AA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast ratio meets WCAG AAA standard (7:1)
  static bool meetsWCAG_AAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 7.0;
  }

  // ==================== Color Manipulation ====================

  /// Lighten color by percentage (0-100)
  static Color lighten(Color color, int percentage) {
    assert(percentage >= 0 && percentage <= 100);
    final hsl = HSLColor.fromColor(color);
    final lightness = math.min(1.0, hsl.lightness + (percentage / 100));
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken color by percentage (0-100)
  static Color darken(Color color, int percentage) {
    assert(percentage >= 0 && percentage <= 100);
    final hsl = HSLColor.fromColor(color);
    final lightness = math.max(0.0, hsl.lightness - (percentage / 100));
    return hsl.withLightness(lightness).toColor();
  }

  /// Saturate color by percentage (0-100)
  static Color saturate(Color color, int percentage) {
    assert(percentage >= 0 && percentage <= 100);
    final hsl = HSLColor.fromColor(color);
    final saturation = math.min(1.0, hsl.saturation + (percentage / 100));
    return hsl.withSaturation(saturation).toColor();
  }

  /// Desaturate color by percentage (0-100)
  static Color desaturate(Color color, int percentage) {
    assert(percentage >= 0 && percentage <= 100);
    final hsl = HSLColor.fromColor(color);
    final saturation = math.max(0.0, hsl.saturation - (percentage / 100));
    return hsl.withSaturation(saturation).toColor();
  }

  /// Adjust opacity
  static Color withOpacity(Color color, double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return color.withOpacity(opacity);
  }

  // ==================== Color Shades ====================

  /// Generate color shades (50, 100, 200, ..., 900)
  static Map<int, Color> generateShades(Color baseColor) {
    return {
      50: lighten(baseColor, 45),
      100: lighten(baseColor, 40),
      200: lighten(baseColor, 30),
      300: lighten(baseColor, 20),
      400: lighten(baseColor, 10),
      500: baseColor,
      600: darken(baseColor, 10),
      700: darken(baseColor, 20),
      800: darken(baseColor, 30),
      900: darken(baseColor, 40),
    };
  }

  /// Generate MaterialColor from base color
  static MaterialColor generateMaterialColor(Color color) {
    final shades = generateShades(color);
    return MaterialColor(
      color.value,
      {
        50: shades[50]!,
        100: shades[100]!,
        200: shades[200]!,
        300: shades[300]!,
        400: shades[400]!,
        500: shades[500]!,
        600: shades[600]!,
        700: shades[700]!,
        800: shades[800]!,
        900: shades[900]!,
      },
    );
  }

  // ==================== Color Palettes ====================

  /// Generate monochromatic color palette
  static List<Color> generateMonochromatic(Color baseColor, {int count = 5}) {
    final colors = <Color>[];
    final step = 100 / (count + 1);
    
    for (var i = 0; i < count; i++) {
      final percentage = (i + 1) * step;
      colors.add(lighten(baseColor, percentage.toInt()));
    }
    
    return colors;
  }

  /// Generate analogous colors
  static List<Color> generateAnalogous(Color baseColor, {int count = 2}) {
    final hsl = HSLColor.fromColor(baseColor);
    final colors = <Color>[baseColor];
    final step = 30.0; // 30 degrees apart

    for (var i = 1; i <= count; i++) {
      final hue = (hsl.hue + (i * step)) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }

    return colors;
  }

  /// Generate complementary color
  static Color getComplementary(Color color) {
    final hsl = HSLColor.fromColor(color);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }

  /// Generate triadic colors
  static List<Color> generateTriadic(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return [
      baseColor,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  /// Generate tetradic colors
  static List<Color> generateTetradic(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return [
      baseColor,
      hsl.withHue((hsl.hue + 90) % 360).toColor(),
      hsl.withHue((hsl.hue + 180) % 360).toColor(),
      hsl.withHue((hsl.hue + 270) % 360).toColor(),
    ];
  }

  // ==================== Random Colors ====================

  /// Generate random color
  static Color randomColor({int? seed}) {
    final random = seed != null ? math.Random(seed) : math.Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  /// Generate random pastel color
  static Color randomPastelColor({int? seed}) {
    final random = seed != null ? math.Random(seed) : math.Random();
    return Color.fromARGB(
      255,
      (random.nextInt(128) + 127),
      (random.nextInt(128) + 127),
      (random.nextInt(128) + 127),
    );
  }

  // ==================== Color Interpolation ====================

  /// Interpolate between two colors
  static Color lerp(Color color1, Color color2, double t) {
    return Color.lerp(color1, color2, t)!;
  }

  /// Generate gradient colors between two colors
  static List<Color> generateGradient(
    Color startColor,
    Color endColor, {
    int steps = 5,
  }) {
    final colors = <Color>[];
    for (var i = 0; i < steps; i++) {
      final t = i / (steps - 1);
      colors.add(lerp(startColor, endColor, t));
    }
    return colors;
  }

  // ==================== Color from String ====================

  /// Generate consistent color from string (useful for avatars)
  static Color fromString(String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final hue = hash.abs() % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.6, 0.6).toColor();
  }

  // ==================== Named Color Palettes ====================

  /// Material Design colors
  static final materialColors = {
    'red': Colors.red,
    'pink': Colors.pink,
    'purple': Colors.purple,
    'deepPurple': Colors.deepPurple,
    'indigo': Colors.indigo,
    'blue': Colors.blue,
    'lightBlue': Colors.lightBlue,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'green': Colors.green,
    'lightGreen': Colors.lightGreen,
    'lime': Colors.lime,
    'yellow': Colors.yellow,
    'amber': Colors.amber,
    'orange': Colors.orange,
    'deepOrange': Colors.deepOrange,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'blueGrey': Colors.blueGrey,
  };
}

/// Extension on Color
extension ColorExtension on Color {
  /// Convert color to hex string
  String toHex({bool includeAlpha = false}) {
    return ColorUtils.toHex(this, includeAlpha: includeAlpha);
  }

  /// Check if color is dark
  bool get isDark => ColorUtils.isDark(this);

  /// Check if color is light
  bool get isLight => ColorUtils.isLight(this);

  /// Get contrasting color (black or white)
  Color get contrastColor => ColorUtils.getContrastColor(this);

  /// Lighten color
  Color lighten([int percentage = 10]) {
    return ColorUtils.lighten(this, percentage);
  }

  /// Darken color
  Color darken([int percentage = 10]) {
    return ColorUtils.darken(this, percentage);
  }

  /// Saturate color
  Color saturate([int percentage = 10]) {
    return ColorUtils.saturate(this, percentage);
  }

  /// Desaturate color
  Color desaturate([int percentage = 10]) {
    return ColorUtils.desaturate(this, percentage);
  }

  /// Generate shades
  Map<int, Color> get shades => ColorUtils.generateShades(this);

  /// Get complementary color
  Color get complementary => ColorUtils.getComplementary(this);

  /// Generate triadic colors
  List<Color> get triadic => ColorUtils.generateTriadic(this);

  /// Generate tetradic colors
  List<Color> get tetradic => ColorUtils.generateTetradic(this);

  /// Get RGB values as map
  Map<String, int> get rgb => {
        'r': red,
        'g': green,
        'b': blue,
      };

  /// Get HSL values as map
  Map<String, double> get hsl {
    final hslColor = HSLColor.fromColor(this);
    return {
      'h': hslColor.hue,
      's': hslColor.saturation,
      'l': hslColor.lightness,
    };
  }
}