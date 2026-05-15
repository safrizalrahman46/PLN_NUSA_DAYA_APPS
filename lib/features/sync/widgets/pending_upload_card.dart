import 'package:flutter/material.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(logsheet.proofId, style: Theme.of(context).textTheme.titleLarge),
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
            Text(
              logsheet.syncErrorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
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
