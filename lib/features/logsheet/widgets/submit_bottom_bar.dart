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
  });

  final bool isSaving;
  final bool isSubmitting;
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 380;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.glassDark
                : AppColors.glassLight,
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: OverflowBar(
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
                  SizedBox(
                    width: narrow
                        ? double.infinity
                        : (MediaQuery.of(context).size.width - 44) / 2,
                    child: AppButton(
                      label: 'Submit Logsheet',
                      onPressed: onSubmit,
                      isLoading: isSubmitting,
                    ),
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
