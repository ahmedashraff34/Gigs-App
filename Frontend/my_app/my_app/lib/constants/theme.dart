import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand color
  static const Color primaryColor = Color(0xff11366b);

  // Secondary colors
  static const Color accentColor = Color(0xFF5D576B);
  static const Color lightAccentColor = Color(0xFFEAEBEF);

  // Text colors
  static const Color textColor = Color(0xFF000000);
  static const Color textColor1 = Color(0xFF717479);
  static const Color textColor2 = Color(0xFFFFFFFF);

  static const TextStyle headerTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle textStyle0 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle textStyle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textStyle2 =
      TextStyle(fontSize: 14, color: textColor1, fontWeight: FontWeight.bold);

  // Backgrounds & UI Elements
  static const Color backgroundColor = Color(0xFFFFFfff);
  static const Color sectionBgColor = Color(0xFFFFFAE3);
  static const Color cardColor = Color(0xfff3f4f6);
  static const Color dividerColor = Color(0xffF5F6FA);
  static const Color disabledColor = Color(0xFFe0e0e0);

  // Status colors
  static const Color urgentColor = Color(0xFFD15C5C);
  static const Color successColor = Color(0xFF18a249);
  static const Color warningColor = Color(0xFFffc10e);
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];

  static Border cardBorder =
      Border.all(color: primaryColor.withValues(alpha: 0), width: 1);

  // Border radius
  static final BorderRadius borderRadius = BorderRadius.circular(16);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(24);
  static final BorderRadius borderRadiusPill = BorderRadius.circular(64);

  // Paddings
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingHuge = 32.0;

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
}
