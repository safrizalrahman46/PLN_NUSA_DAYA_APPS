import 'package:flutter/material.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Simpan Draft',
                onPressed: onSaveDraft,
                type: AppButtonType.outlined,
                isLoading: isSaving,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Submit Logsheet',
                onPressed: onSubmit,
                isLoading: isSubmitting,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
