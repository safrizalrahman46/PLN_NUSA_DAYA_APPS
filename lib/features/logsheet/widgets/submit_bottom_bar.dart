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
    final narrow = MediaQuery.of(context).size.width < 380;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
    );
  }
}
