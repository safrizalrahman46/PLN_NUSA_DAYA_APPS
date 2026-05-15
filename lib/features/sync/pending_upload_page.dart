import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import 'sync_service.dart';
import 'widgets/pending_upload_card.dart';
import 'widgets/sync_status_banner.dart';

final pendingProvider = FutureProvider<List<LogsheetModel>>((ref) {
  return ref.read(logsheetRepositoryProvider).getPendingUploads();
});

class PendingUploadPage extends ConsumerWidget {
  const PendingUploadPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(pendingProvider);
    await ref.read(pendingProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingProvider);
    final syncState = ref.watch(syncServiceProvider);

    ref.listen(syncServiceProvider, (previous, next) {
      if (next.lastMessage != null &&
          next.lastMessage != previous?.lastMessage &&
          context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.lastMessage!)));
        ref.invalidate(pendingProvider);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Upload')),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SyncStatusBanner(state: syncState),
            const SizedBox(height: 16),
            pending.when(
              data: (items) => Column(
                children: [
                  AppCard(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        Colors.white,
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Antrian Upload',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${items.length} laporan menunggu sinkronisasi.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: syncState.isSyncing
                              ? null
                              : () => ref
                                    .read(syncServiceProvider.notifier)
                                    .syncPending(),
                          icon: const Icon(Icons.sync_rounded),
                          label: Text('Sync (${items.length})'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    const AppEmptyState(
                      title: 'Tidak ada antrian',
                      message:
                          'Semua laporan sudah tersinkron. Input laporan baru untuk mengisi antrian.',
                      icon: Icons.cloud_done_rounded,
                    )
                  else
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PendingUploadCard(
                          logsheet: item,
                          onSync: () => ref
                              .read(syncServiceProvider.notifier)
                              .syncPending(),
                        ),
                      ),
                    ),
                ],
              ),
              loading: () => const AppLoading(),
              error: (error, _) => AppErrorState(
                message: error.toString(),
                onRetry: () => _refresh(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
