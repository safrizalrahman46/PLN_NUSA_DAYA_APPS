import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/logsheet_model.dart';

class PendingUploadCard extends StatelessWidget {
  const PendingUploadCard({
    super.key,
    required this.logsheet,
    required this.onSync,
  });

  final LogsheetModel logsheet;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.softSurfaceGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  logsheet.proofId,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.warning.withValues(alpha: 0.14),
                ),
                child: Text(
                  'Pending',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateHelper.formatDateTime(logsheet.submittedAt),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge.sync(logsheet.syncStatus),
              StatusBadge.location(logsheet.locationStatus),
            ],
          ),
          if (logsheet.syncErrorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                logsheet.syncErrorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
              ),
            ),
          ],
          const SizedBox(height: 14),
          AppButton(
            label: 'Sync Item Ini',
            onPressed: onSync,
            fullWidth: false,
          ),
        ],
      ),
    );
  }
}
