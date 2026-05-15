import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: syncState.isSyncing
                          ? null
                          : () => ref
                                .read(syncServiceProvider.notifier)
                                .syncPending(),
                      icon: const Icon(Icons.sync_rounded),
                      label: Text('Sync Semua (${items.length})'),
                    ),
                  ),
                  const SizedBox(height: 16),
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
