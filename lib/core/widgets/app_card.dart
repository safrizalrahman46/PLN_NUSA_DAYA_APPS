import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (isDark ? AppColors.darkSurface : AppColors.card)
            : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              borderColor ?? (isDark ? AppColors.darkBorder : AppColors.border),
        ),
        boxShadow: isDark
            ? const []
            : [
                TextStyles.softShadow,
                const BoxShadow(
                  color: Color(0x0F0D2A52),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
