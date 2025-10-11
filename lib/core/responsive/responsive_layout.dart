// lib/core/responsive/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getMainContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) return width - 32;
    if (isTablet(context)) return width * 0.8;
    return width * 0.6; // Desktop
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4; // Desktop
  }

  static EdgeInsets getPagePadding(BuildContext context) {
    if (isMobile(context)) return EdgeInsets.all(16);
    if (isTablet(context)) return EdgeInsets.all(24);
    return EdgeInsets.symmetric(horizontal: 48, vertical: 24); // Desktop
  }
}

// ويدجت للتجاوب
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    if (size.width >= 1200 && desktop != null) {
      return desktop!;
    } else if (size.width >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}