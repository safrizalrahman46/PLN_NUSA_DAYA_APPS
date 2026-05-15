import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class TextStyles {
  TextStyles._();

  static const String fontFamily = 'sans-serif';

  static TextStyle headlineLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w800,
    color: color,
    letterSpacing: -0.6,
  );

  static TextStyle headlineMedium(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: color,
    letterSpacing: -0.4,
  );

  static TextStyle titleLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle titleMedium(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle bodyLarge(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle bodyMedium(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle bodySmall(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static BoxShadow get softShadow => BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.08),
    blurRadius: 30,
    offset: const Offset(0, 12),
  );
}
