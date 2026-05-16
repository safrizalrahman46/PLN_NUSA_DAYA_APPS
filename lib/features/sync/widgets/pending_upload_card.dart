import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
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
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  logsheet.proofId,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                borderRadius: 999,
                sigmaX: 6,
                sigmaY: 6,
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
            GlassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: 12,
              sigmaX: 6,
              sigmaY: 6,
              gradient: LinearGradient(
                colors: [
                  AppColors.danger.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: AppColors.danger.withValues(alpha: 0.25),
              child: Text(
                logsheet.syncErrorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
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
