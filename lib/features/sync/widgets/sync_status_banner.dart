import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/sync_feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../sync_service.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key, required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final syncing = state.isSyncing;
    final bannerTone = syncing ? SyncMessageTone.neutral : state.tone;
    final color = switch (bannerTone) {
      SyncMessageTone.success => AppColors.success,
      SyncMessageTone.warning => AppColors.warning,
      SyncMessageTone.error => AppColors.danger,
      SyncMessageTone.neutral => AppColors.primary,
    };
    final icon = syncing
        ? Icons.sync_rounded
        : switch (bannerTone) {
            SyncMessageTone.success => Icons.cloud_done_rounded,
            SyncMessageTone.warning => Icons.wifi_off_rounded,
            SyncMessageTone.error => Icons.cloud_off_rounded,
            SyncMessageTone.neutral => Icons.cloud_sync_rounded,
          };

    return GlassCard(
      gradient: LinearGradient(
        colors: [
          color.withValues(
            alpha: 0.16,
          ),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: color.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.lastMessage ??
                  'Sistem siap melakukan sinkronisasi otomatis.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
