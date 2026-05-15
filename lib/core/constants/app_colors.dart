import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0A6FD8);
  static const Color primaryDark = Color(0xFF0C2F73);
  static const Color accent = Color(0xFF23B7FF);
  static const Color accentSoft = Color(0xFFE7F5FF);
  static const Color highlight = Color(0xFFF6A23C);
  static const Color highlightSoft = Color(0xFFFFF0DD);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color background = Color(0xFFF2F6FC);
  static const Color backgroundSoft = Color(0xFFF8FBFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF111B2F);
  static const Color text = Color(0xFF12233D);
  static const Color textSoft = Color(0xFF5E6C84);
  static const Color border = Color(0xFFD5E3F4);
  static const Color darkBackground = Color(0xFF09101F);
  static const Color darkSurface = Color(0xFF101A2B);
  static const Color darkBorder = Color(0xFF1F314E);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A3D8E), Color(0xFF0A6FD8), Color(0xFF23B7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGlow = LinearGradient(
    colors: [Color(0xFFFFDDB7), Color(0xFFFFAF69), Color(0xFFF68A3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softSurfaceGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF6FAFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF05224F), Color(0xFF0B58B7), Color(0xFF1CB3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF09101F), Color(0xFF0E1A31), Color(0xFF113B67)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
