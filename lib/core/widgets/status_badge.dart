import 'package:flutter/material.dart';

import '../../data/models/app_enums.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  factory StatusBadge.sync(SyncStatus status) {
    final map = <SyncStatus, (String, Color)>{
      SyncStatus.draft: ('Draft', AppColors.textSoft),
      SyncStatus.pendingSync: ('Pending', AppColors.warning),
      SyncStatus.synced: ('Tersinkron', AppColors.success),
      SyncStatus.failed: ('Gagal', AppColors.danger),
    };
    final item = map[status]!;
    return StatusBadge(label: item.$1, color: item.$2);
  }

  factory StatusBadge.location(LocationStatus status) {
    final map = <LocationStatus, (String, Color)>{
      LocationStatus.valid: ('Valid', AppColors.success),
      LocationStatus.outsideArea: ('Di luar area', AppColors.warning),
      LocationStatus.permissionDenied: ('Izin ditolak', AppColors.danger),
      LocationStatus.gpsOff: ('GPS mati', AppColors.danger),
      LocationStatus.unknown: ('Belum dicek', AppColors.textSoft),
    };
    final item = map[status]!;
    return StatusBadge(label: item.$1, color: item.$2);
  }

  factory StatusBadge.report(ReportStatus status) {
    final map = <ReportStatus, (String, Color)>{
      ReportStatus.onTime: ('Tepat waktu', AppColors.success),
      ReportStatus.late: ('Terlambat', AppColors.warning),
      ReportStatus.missing: ('Belum masuk', AppColors.danger),
      ReportStatus.abnormal: ('Abnormal', AppColors.danger),
    };
    final item = map[status]!;
    return StatusBadge(label: item.$1, color: item.$2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
