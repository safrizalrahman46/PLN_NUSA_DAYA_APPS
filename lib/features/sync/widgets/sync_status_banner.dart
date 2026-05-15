import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../sync_service.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key, required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(state.isSyncing ? Icons.sync_rounded : Icons.cloud_done_rounded),
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
