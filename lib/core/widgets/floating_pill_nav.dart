import 'dart:ui';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class FloatingPillNavItem {
  const FloatingPillNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}

class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<FloatingPillNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pill = ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.pillNavDark.withValues(alpha: 0.92)
                : AppColors.pillNavLight.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorderDark
                  : AppColors.border.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: _PillNavItem(
                    item: item,
                    selected: selected,
                    isDark: isDark,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: pill,
    );
  }
}

class _PillNavItem extends StatelessWidget {
  const _PillNavItem({
    required this.item,
    required this.selected,
    required this.isDark,
  });

  final FloatingPillNavItem item;
  final bool selected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.accent : AppColors.primary;
    final inactiveColor =
        isDark ? const Color(0xFF92A7C5) : AppColors.textSoft;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      padding: selected
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 5)
          : const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: selected
            ? LinearGradient(
                colors: isDark
                    ? [
                        AppColors.accent.withValues(alpha: 0.32),
                        AppColors.primary.withValues(alpha: 0.20),
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.16),
                        AppColors.accent.withValues(alpha: 0.08),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: selected
            ? Border.all(
                color: isDark
                    ? AppColors.accent.withValues(alpha: 0.28)
                    : AppColors.primary.withValues(alpha: 0.20),
                width: 1,
              )
            : null,
      ),
      child: selected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? [AppColors.accent, AppColors.auroraCyan]
                        : [AppColors.primary, AppColors.accent],
                  ).createShader(bounds),
                  child: Icon(item.activeIcon ?? item.icon, size: 20),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isDark
                          ? [AppColors.accent, AppColors.auroraCyan]
                          : [AppColors.primary, AppColors.accent],
                    ).createShader(bounds),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Icon(item.icon, size: 22, color: inactiveColor),
            ),
    );
  }
}
