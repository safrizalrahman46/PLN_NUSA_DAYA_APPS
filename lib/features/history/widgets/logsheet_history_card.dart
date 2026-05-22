import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/logsheet_model.dart';
import '../../../data/models/app_enums.dart';

class LogsheetHistoryCard extends StatelessWidget {
  const LogsheetHistoryCard({
    super.key,
    required this.logsheet,
    required this.onTap,
    this.onEdit,
  });

  final LogsheetModel logsheet;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  Color _iconColor() {
    return switch (logsheet.reportStatus) {
      ReportStatus.onTime => AppColors.success,
      ReportStatus.late => AppColors.warning,
      ReportStatus.missing => AppColors.danger,
      ReportStatus.abnormal => AppColors.danger,
    };
  }

  IconData _iconData() {
    return switch (logsheet.reportStatus) {
      ReportStatus.onTime => Icons.check_circle_rounded,
      ReportStatus.late => Icons.schedule_rounded,
      ReportStatus.missing => Icons.error_outline_rounded,
      ReportStatus.abnormal => Icons.warning_amber_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _iconColor();
    final icon = _iconData();

    return GlassCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        logsheet.proofId,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primary.withValues(alpha: 0.10),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateHelper.formatDateTime(logsheet.submittedAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
                ),
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  borderRadius: 12,
                  sigmaX: 6,
                  sigmaY: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${logsheet.unitName} • ${logsheet.machineDisplayName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        logsheet.machineIdentity.isEmpty
                            ? 'Status mesin: ${logsheet.machineStatus.label}'
                            : '${logsheet.machineIdentity} • ${logsheet.machineStatus.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (logsheet.machineCapacityInfo.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          logsheet.machineCapacityInfo,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSoft),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    StatusBadge.machine(logsheet.machineStatus),
                    StatusBadge.sync(logsheet.syncStatus),
                    StatusBadge.approval(logsheet.approvalStatus),
                    StatusBadge.location(logsheet.locationStatus),
                    StatusBadge.report(logsheet.reportStatus),
                  ],
                ),
                if (logsheet.rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Alasan penolakan: ${logsheet.rejectionReason}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
                if (onEdit != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit inputan'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
