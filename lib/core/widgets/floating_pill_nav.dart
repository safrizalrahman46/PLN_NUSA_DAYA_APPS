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
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.pillNavDark.withValues(alpha: 0.94)
                : AppColors.pillNavLight.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorderDark
                  : AppColors.border.withValues(alpha: 0.5),
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
            color: (isDark ? AppColors.accent : AppColors.primary)
                .withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
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
    final inactiveColor =
        isDark ? const Color(0xFF8BA3C0) : AppColors.textSoft;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
      padding: selected
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: selected
            ? LinearGradient(
                colors: isDark
                    ? [AppColors.accent, AppColors.auroraBlue]
                    : [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: (isDark ? AppColors.accent : AppColors.primary)
                      .withValues(alpha: 0.40),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: selected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.activeIcon ?? item.icon,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Flexible(
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
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 22, color: inactiveColor),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: inactiveColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
    );
  }
}
