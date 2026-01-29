import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive Responsive Design and Device Utilities
/// Combines responsive design, device detection, and platform utilities
class ResponsiveHelper {
  ResponsiveHelper._();

  // ==================== Base Design Dimensions ====================
  
  static const double _baseWidth = 360.0;
  static const double _baseHeight = 690.0;

  // ==================== Screen Breakpoints ====================

  /// Mobile breakpoint (< 600)
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint (< 900)
  static const double tabletBreakpoint = 900;

  /// Desktop breakpoint (< 1200)
  static const double desktopBreakpoint = 1200;

  /// Large desktop breakpoint (>= 1200)
  static const double largeDesktopBreakpoint = 1200;

  // ==================== Device Type Detection ====================

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) return DeviceType.mobile;
    if (screenWidth < tabletBreakpoint) return DeviceType.tablet;
    if (screenWidth < largeDesktopBreakpoint) return DeviceType.desktop;
    return DeviceType.ultrawide;
  }

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Check if screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// Get screen type (legacy support)
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  // ==================== Screen Dimensions ====================

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get screen size
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get width percentage
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Get height percentage
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  // ==================== Scale Factor ====================

  /// Get scale factor based on current screen size
  static double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth / _baseWidth;
      case DeviceType.tablet:
        return (screenWidth / _baseWidth) * 0.8;
      case DeviceType.desktop:
        return (screenWidth / _baseWidth) * 0.6;
      case DeviceType.ultrawide:
        return (screenWidth / _baseWidth) * 0.4;
    }
  }

  // ==================== Orientation ====================

  /// Check if portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if landscape (from viewInsets)
  static bool isLandscapeOrientation(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom == 0;
  }

  /// Check if portrait (from viewInsets)
  static bool isPortraitOrientation(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom != 0;
  }

  // ==================== Responsive Values ====================

  /// Get value based on screen type
  static T valueWhen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive value (linear scaling)
  static double responsiveValue({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = screenWidth(context);
    
    if (width < mobileBreakpoint) {
      return mobile;
    } else if (width < desktopBreakpoint) {
      final tabletValue = tablet ?? mobile * 1.5;
      final t = (width - mobileBreakpoint) / (desktopBreakpoint - mobileBreakpoint);
      return mobile + (tabletValue - mobile) * t;
    } else {
      return desktop ?? tablet ?? mobile * 2;
    }
  }

  // ==================== Responsive Font Size ====================

  /// Get responsive font size with web/mobile optimization
  static double fontSize({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
    double? ultrawide,
    double? minSize,
    double? maxSize,
  }) {
    double size;
    final deviceType = getDeviceType(context);

    if (kIsWeb) {
      switch (deviceType) {
        case DeviceType.ultrawide:
          size = ultrawide ?? desktop ?? (mobile * 1.4);
          break;
        case DeviceType.desktop:
          size = desktop ?? (mobile * 1.2);
          break;
        case DeviceType.tablet:
          size = tablet ?? (mobile * 1.1);
          break;
        case DeviceType.mobile:
          size = mobile;
          break;
      }
    } else {
      final scaleFactor = getScaleFactor(context);
      size = mobile * scaleFactor;
    }

    if (minSize != null) size = size.clamp(minSize, double.infinity);
    if (maxSize != null) size = size.clamp(0, maxSize);

    return size;
  }

  /// Scale font size based on screen width
  static double scaledFontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    final scaleFactor = width / 375; // Base width (iPhone X)
    return baseSize * scaleFactor;
  }

  // ==================== Responsive Padding ====================

  /// Get responsive padding
  static EdgeInsets responsivePadding({
    required BuildContext context,
    double mobile = 16,
    double? tablet,
    double? desktop,
  }) {
    final padding = responsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.all(padding);
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding({
    required BuildContext context,
    double mobile = 16,
    double? tablet,
    double? desktop,
  }) {
    final padding = responsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get responsive vertical padding
  static EdgeInsets responsiveVerticalPadding({
    required BuildContext context,
    double mobile = 16,
    double? tablet,
    double? desktop,
  }) {
    final padding = responsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Get responsive padding with context-aware values
  static EdgeInsets getPadding({
    required BuildContext context,
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? ultrawide,
  }) {
    final deviceType = getDeviceType(context);
    final defaultMobile = mobile ?? const EdgeInsets.all(16);

    switch (deviceType) {
      case DeviceType.ultrawide:
        return ultrawide ??
            desktop ??
            const EdgeInsets.symmetric(horizontal: 60, vertical: 32);
      case DeviceType.desktop:
        return desktop ??
            const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
      case DeviceType.tablet:
        return tablet ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
      case DeviceType.mobile:
        if (kIsWeb) {
          return defaultMobile;
        } else {
          final scaleFactor = getScaleFactor(context);
          return EdgeInsets.all(defaultMobile.left * scaleFactor);
        }
    }
  }

  // ==================== Responsive Margin ====================

  /// Get responsive margin
  static EdgeInsets getMargin({
    required BuildContext context,
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? ultrawide,
  }) {
    final deviceType = getDeviceType(context);
    final defaultMobile = mobile ?? const EdgeInsets.all(8);

    switch (deviceType) {
      case DeviceType.ultrawide:
        return ultrawide ??
            desktop ??
            const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      case DeviceType.desktop:
        return desktop ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case DeviceType.tablet:
        return tablet ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case DeviceType.mobile:
        if (kIsWeb) {
          return defaultMobile;
        } else {
          final scaleFactor = getScaleFactor(context);
          return EdgeInsets.all(defaultMobile.left * scaleFactor);
        }
    }
  }

  // ==================== Responsive Spacing ====================

  /// Get responsive spacing
  static double spacing({
    required BuildContext context,
    double mobile = 8,
    double? tablet,
    double? desktop,
    double? ultrawide,
  }) {
    final deviceType = getDeviceType(context);

    if (kIsWeb) {
      switch (deviceType) {
        case DeviceType.ultrawide:
          return ultrawide ?? desktop ?? (mobile * 2.0);
        case DeviceType.desktop:
          return desktop ?? (mobile * 1.5);
        case DeviceType.tablet:
          return tablet ?? (mobile * 1.2);
        case DeviceType.mobile:
          return mobile;
      }
    } else {
      final scaleFactor = getScaleFactor(context);
      return mobile * scaleFactor;
    }
  }

  /// Get responsive gap for Flex widgets
  static SizedBox responsiveGap({
    required BuildContext context,
    double mobile = 8,
    double? tablet,
    double? desktop,
  }) {
    final gap = responsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return SizedBox(width: gap, height: gap);
  }

  // ==================== Responsive Width/Height ====================

  /// Get responsive width
  static double width({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
    double? ultrawide,
  }) {
    final deviceType = getDeviceType(context);

    if (kIsWeb) {
      switch (deviceType) {
        case DeviceType.ultrawide:
          return ultrawide ?? desktop ?? (mobile * 3.0);
        case DeviceType.desktop:
          return desktop ?? (mobile * 2.0);
        case DeviceType.tablet:
          return tablet ?? (mobile * 1.5);
        case DeviceType.mobile:
          return mobile;
      }
    } else {
      final scaleFactor = getScaleFactor(context);
      return mobile * scaleFactor;
    }
  }

  /// Get responsive height
  static double height({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
    double? ultrawide,
  }) {
    final deviceType = getDeviceType(context);

    if (kIsWeb) {
      switch (deviceType) {
        case DeviceType.ultrawide:
          return ultrawide ?? desktop ?? (mobile * 1.4);
        case DeviceType.desktop:
          return desktop ?? (mobile * 1.2);
        case DeviceType.tablet:
          return tablet ?? (mobile * 1.1);
        case DeviceType.mobile:
          return mobile;
      }
    } else {
      final scaleFactor = getScaleFactor(context);
      return mobile * scaleFactor;
    }
  }

  // ==================== Responsive Border Radius ====================

  /// Get responsive border radius
  static BorderRadius getBorderRadius({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
    double? ultrawide,
  }) {
    final deviceType = getDeviceType(context);
    double radius;

    switch (deviceType) {
      case DeviceType.ultrawide:
        radius = ultrawide ?? desktop ?? (mobile * 1.5);
        break;
      case DeviceType.desktop:
        radius = desktop ?? (mobile * 1.3);
        break;
      case DeviceType.tablet:
        radius = tablet ?? (mobile * 1.1);
        break;
      case DeviceType.mobile:
        if (kIsWeb) {
          radius = mobile;
        } else {
          final scaleFactor = getScaleFactor(context);
          radius = mobile * scaleFactor;
        }
        break;
    }

    return BorderRadius.circular(radius);
  }

  // ==================== Grid Columns ====================

  /// Get responsive grid columns
  static int gridColumns({
    required BuildContext context,
    int mobile = 2,
    int? tablet,
    int? desktop,
  }) {
    return valueWhen(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive grid columns with max
  static int getGridColumns(BuildContext context, {int maxColumns = 4}) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.ultrawide:
        return maxColumns;
      case DeviceType.desktop:
        return (maxColumns * 0.8).round().clamp(1, maxColumns);
      case DeviceType.tablet:
        return (maxColumns * 0.6).round().clamp(1, maxColumns);
      case DeviceType.mobile:
        return (maxColumns * 0.4).round().clamp(1, 2);
    }
  }

  // ==================== Safe Area ====================

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get top safe area padding
  static double topSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get bottom safe area padding
  static double bottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Get status bar height
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  // ==================== Device Pixel Ratio ====================

  /// Get device pixel ratio
  static double pixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Convert logical pixels to physical pixels
  static double toPhysicalPixels(BuildContext context, double logicalPixels) {
    return logicalPixels * pixelRatio(context);
  }

  /// Convert physical pixels to logical pixels
  static double toLogicalPixels(BuildContext context, double physicalPixels) {
    return physicalPixels / pixelRatio(context);
  }

  // ==================== Responsive Components ====================

  /// Get responsive icon size
  static double getIconSize({
    required BuildContext context,
    double mobile = 24,
    double? tablet,
    double? desktop,
    double? ultrawide,
  }) {
    return fontSize(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultrawide: ultrawide,
    );
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.ultrawide:
      case DeviceType.desktop:
        return 56;
      case DeviceType.tablet:
        return 52;
      case DeviceType.mobile:
        if (kIsWeb) {
          return 48;
        } else {
          final scaleFactor = getScaleFactor(context);
          return 48 * scaleFactor;
        }
    }
  }

  /// Get bottom navigation bar height
  static double getBottomNavigationHeight() {
    return 56.0;
  }

  /// Get app bar height
  static double getAppBarHeight() {
    return 56.0;
  }

  // ==================== Max Content Width ====================

  /// Get max width for content on web to prevent stretching
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.ultrawide:
        return 1600;
      case DeviceType.desktop:
        return 1200;
      case DeviceType.tablet:
        return 768;
      case DeviceType.mobile:
        return double.infinity;
    }
  }

  /// Get responsive container constraints
  static BoxConstraints getContainerConstraints(BuildContext context) {
    final maxWidth = getMaxContentWidth(context);
    final deviceType = getDeviceType(context);

    return BoxConstraints(
      maxWidth: maxWidth,
      minHeight: deviceType == DeviceType.mobile ? 0 : 200,
    );
  }

  // ==================== Keyboard ====================

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom > 0;
  }

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // ==================== Device Info ====================

  /// Check if touch device
  static bool isTouchDevice(BuildContext context) {
    return kIsWeb ? getDeviceType(context) == DeviceType.mobile : true;
  }

  /// Check if physical device
  static bool isPhysicalDevice() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Check if iOS
  static bool isIos() => !kIsWeb && Platform.isIOS;

  /// Check if Android
  static bool isAndroid() => !kIsWeb && Platform.isAndroid;

  /// Check if Web
  static bool isWeb() => kIsWeb;

  // ==================== Screen Breakpoint Info ====================

  /// Get screen breakpoint info
  static ScreenBreakpoint getBreakpointInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    return ScreenBreakpoint(
      width: screenWidth,
      height: screenHeight,
      deviceType: deviceType,
      scaleFactor: scaleFactor,
      isPortrait: screenHeight > screenWidth,
      isLandscape: screenWidth > screenHeight,
    );
  }

  // ==================== System UI ====================

  /// Set status bar color
  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  /// Set full screen
  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// Hide status bar
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  /// Show status bar
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Set preferred orientations
  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  /// Vibrate device
  static void vibrate(Duration duration) {
    HapticFeedback.vibrate();
    Future.delayed(duration, () => HapticFeedback.vibrate());
  }

  // ==================== Network ====================

  /// Check internet connection
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) return true; // Assume web has connection
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

// ==================== Enums ====================

/// Screen Type enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Device Type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  ultrawide,
}

// ==================== Data Classes ====================

/// Screen Breakpoint Info
class ScreenBreakpoint {
  final double width;
  final double height;
  final DeviceType deviceType;
  final double scaleFactor;
  final bool isPortrait;
  final bool isLandscape;

  const ScreenBreakpoint({
    required this.width,
    required this.height,
    required this.deviceType,
    required this.scaleFactor,
    required this.isPortrait,
    required this.isLandscape,
  });

  @override
  String toString() {
    return 'ScreenBreakpoint(${deviceType.name}, ${width}x$height, scale: ${scaleFactor.toStringAsFixed(2)})';
  }
}

// ==================== Widgets ====================

/// Responsive Builder Widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);
    return builder(context, screenType);
  }
}

/// Responsive Value Widget
class ResponsiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;
  final Widget Function(BuildContext, T) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final value = ResponsiveHelper.valueWhen(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
    return builder(context, value);
  }
}

/// Responsive Grid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.gridColumns(
      context: context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: runSpacing,
      crossAxisSpacing: spacing,
      children: children,
    );
  }
}