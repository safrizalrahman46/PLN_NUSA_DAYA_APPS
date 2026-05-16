import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../sync_service.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key, required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final syncing = state.isSyncing;

    return GlassCard(
      gradient: LinearGradient(
        colors: [
          (syncing ? AppColors.primary : AppColors.success).withValues(
            alpha: 0.16,
          ),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: syncing
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.success.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: syncing
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.success.withValues(alpha: 0.14),
            ),
            child: Icon(
              syncing ? Icons.sync_rounded : Icons.cloud_done_rounded,
              color: syncing ? AppColors.primary : AppColors.success,
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
