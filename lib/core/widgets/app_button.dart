import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'glass_card.dart';

enum AppButtonType { filled, outlined, tonal, glass }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.type = AppButtonType.filled,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonType type;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (isLoading || icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    switch (type) {
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: fullWidth ? const Size.fromHeight(52) : null,
            side: const BorderSide(color: AppColors.primary, width: 1.2),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: child,
        );
      case AppButtonType.tonal:
        return FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: fullWidth ? const Size.fromHeight(52) : null,
            backgroundColor: AppColors.accentSoft,
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: child,
        );
      case AppButtonType.filled:
        final isDisabled = isLoading || onPressed == null;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: isDisabled ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.36),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(18),
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: SizedBox(
                height: fullWidth ? 52 : null,
                width: fullWidth ? double.infinity : null,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: isDisabled ? Colors.grey.shade600 : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color:
                              isDisabled ? Colors.grey.shade600 : Colors.white,
                          size: 18,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      case AppButtonType.glass:
        return GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 18,
          onTap: isLoading ? null : onPressed,
          child: SizedBox(
            height: fullWidth ? 52 : null,
            width: fullWidth ? double.infinity : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
    }
  }
}
