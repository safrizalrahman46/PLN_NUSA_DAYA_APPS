import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/dashboard_summary_model.dart';
import '../../../data/models/app_enums.dart';

class TodayReportStatus extends StatelessWidget {
  const TodayReportStatus({super.key, required this.summary});

  final DashboardSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.pendingSync > 0
        ? ReportStatus.late
        : summary.todayReports > 0
        ? ReportStatus.onTime
        : ReportStatus.missing;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Status Operasional Hari Ini',
            subtitle:
                'Pantau progres laporan, pending sync, dan abnormal terbaru',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusBadge.report(status),
              const Spacer(),
              Text(
                '${summary.todayReports} laporan',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
            label: 'Tersinkron hari ini',
            value: summary.successReports.toString(),
            valueColor: AppColors.success,
          ),
          _InfoTile(
            icon: Icons.sync_rounded,
            iconColor: AppColors.warning,
            label: 'Pending sync',
            value: summary.pendingSync.toString(),
            valueColor: AppColors.warning,
          ),
          _InfoTile(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.highlight,
            label: 'Laporan terlambat',
            value: summary.lateOperators.toString(),
            valueColor: AppColors.highlight,
          ),
          _InfoTile(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.danger,
            label: 'Abnormal hari ini',
            value: summary.abnormalReports.toString(),
            valueColor: AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}
