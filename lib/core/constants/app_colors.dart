import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0072CE);
  static const Color primaryDark = Color(0xFF0B3A82);
  static const Color accent = Color(0xFF16C6FF);
  static const Color accentSoft = Color(0xFFE6F8FF);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color background = Color(0xFFF3F7FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF111B2F);
  static const Color text = Color(0xFF10233D);
  static const Color textSoft = Color(0xFF5D6B82);
  static const Color border = Color(0xFFD7E3F1);
  static const Color darkBackground = Color(0xFF09101F);
  static const Color darkSurface = Color(0xFF101A2B);
  static const Color darkBorder = Color(0xFF1F314E);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0B4DA2), Color(0xFF0189E0), Color(0xFF16C6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF09101F), Color(0xFF0E1A31), Color(0xFF113B67)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
