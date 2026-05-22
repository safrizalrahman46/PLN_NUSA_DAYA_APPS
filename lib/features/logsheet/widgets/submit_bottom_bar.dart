import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class SubmitBottomBar extends StatelessWidget {
  const SubmitBottomBar({
    super.key,
    required this.isSaving,
    required this.isSubmitting,
    required this.onSaveDraft,
    required this.onSubmit,
    this.filledParams = 0,
    this.totalParams = 13,
    this.warningCount = 0,
    this.secondaryStatus,
    this.submitLabel = 'Submit Logsheet',
    this.submitVisible = true,
  });

  final bool isSaving;
  final bool isSubmitting;
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;
  final int filledParams;
  final int totalParams;
  final int warningCount;
  final String? secondaryStatus;
  final String submitLabel;
  final bool submitVisible;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 380;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allFilled = filledParams >= totalParams;
    final fillColor = allFilled ? AppColors.success : AppColors.warning;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDark : AppColors.glassLight,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.glassBorderDark
                    : AppColors.glassBorderLight,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _ProgressChip(
                        icon: Icons.check_circle_outline_rounded,
                        label: '$filledParams/$totalParams parameter terisi',
                        color: fillColor,
                      ),
                      if (warningCount > 0) ...[
                        const SizedBox(width: 8),
                        _ProgressChip(
                          icon: Icons.warning_amber_rounded,
                          label: '$warningCount warning',
                          color: AppColors.danger,
                        ),
                      ],
                    ],
                  ),
                  if (secondaryStatus != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        secondaryStatus!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSoft,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  OverflowBar(
                    spacing: 12,
                    overflowSpacing: 12,
                    alignment: MainAxisAlignment.center,
                    overflowAlignment: OverflowBarAlignment.center,
                    children: [
                      SizedBox(
                        width: narrow
                            ? double.infinity
                            : (MediaQuery.of(context).size.width - 44) / 2,
                        child: AppButton(
                          label: 'Simpan Draft',
                          onPressed: onSaveDraft,
                          type: AppButtonType.outlined,
                          isLoading: isSaving,
                        ),
                      ),
                      if (submitVisible)
                        SizedBox(
                          width: narrow
                              ? double.infinity
                              : (MediaQuery.of(context).size.width - 44) / 2,
                          child: AppButton(
                            label: submitLabel,
                            onPressed: onSubmit,
                            isLoading: isSubmitting,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
