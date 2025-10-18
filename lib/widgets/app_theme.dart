import 'package:flutter/material.dart';

class AppColors {
  // Primary colors (Purple scheme - matching Utils.mainThemeColor)
  static const Color primary = Color(0xFFE53935);
  static const Color primaryLight = Color(0xFFFF6F60);
  static const Color primaryDark = Color(0xFFAB000D);
  static const Color secondary = Color(0xFFFCE4EC);
  
  // Dangerous action colors (Red scheme)
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFFCE4EC);
  
  // Neutral colors
  static const Color background = Color(0xFFFFF6F5);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  
  // Grey scale
  static const Color grey50 = Color(0xFFFCE4EC);
  static const Color grey100 = Color(0xFFFFCDD2);
  static const Color grey200 = Color(0xFFEF9A9A);
  static const Color grey300 = Color(0xFFE57373);
  static const Color grey400 = Color(0xFFEF5350);
  static const Color grey500 = Color(0xFFB71C1C);
  static const Color grey600 = Color(0xFF8E1519);
  static const Color grey700 = Color(0xFF5D0F11);
  static const Color grey800 = Color(0xFF3E080A);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 12.0;
  static const double xl = 12.0;
  static const double full = 50.0;
}

class AppShadows {
  static List<BoxShadow> light = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> heavy = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
