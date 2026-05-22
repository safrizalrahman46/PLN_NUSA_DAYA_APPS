import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../auth/auth_controller.dart';
import '../logsheet/input_logsheet_page.dart';
import 'sync_service.dart';
import 'widgets/pending_upload_card.dart';
import 'widgets/sync_status_banner.dart';

final pendingProvider = FutureProvider<List<LogsheetModel>>((ref) {
  final user = ref.watch(authControllerProvider).user;
  return ref.read(logsheetRepositoryProvider).getPendingUploads(
        operatorId: user?.isOperator == true ? user?.id : null,
      );
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
    final user = ref.watch(authControllerProvider).user;

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
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).padding.bottom + 108),
          children: [
            SyncStatusBanner(state: syncState),
            const SizedBox(height: 16),
            pending.when(
              data: (items) => Column(
                children: [
                  GlassCard(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                              .syncPending(localId: item.localId),
                          onEdit: item.canEdit && user?.id == item.operatorId
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => InputLogsheetPage(
                                        initialLogsheet: item,
                                      ),
                                    ),
                                  ).then((_) => _refresh(ref));
                                }
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              loading: () => const AppLoading(),
              error: (error, _) => AppErrorState(
                message: ApiException.fromObject(error).message,
                onRetry: () => _refresh(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
