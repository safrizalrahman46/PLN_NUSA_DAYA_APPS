import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
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

    return AppCard(
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
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoTile(
            label: 'Tersinkron hari ini',
            value: summary.successReports.toString(),
          ),
          _InfoTile(
            label: 'Pending sync',
            value: summary.pendingSync.toString(),
          ),
          _InfoTile(
            label: 'Laporan terlambat',
            value: summary.lateOperators.toString(),
          ),
          _InfoTile(
            label: 'Abnormal hari ini',
            value: summary.abnormalReports.toString(),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
