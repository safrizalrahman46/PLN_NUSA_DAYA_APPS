import 'package:flutter/material.dart';

import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/logsheet_model.dart';

class LogsheetHistoryCard extends StatelessWidget {
  const LogsheetHistoryCard({
    super.key,
    required this.logsheet,
    required this.onTap,
  });

  final LogsheetModel logsheet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              logsheet.proofId,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
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
                StatusBadge.report(logsheet.reportStatus),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${logsheet.unitName} • ${logsheet.serialNumber}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
