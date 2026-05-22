import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/retention_repository.dart';
import '../auth/auth_controller.dart';
import '../profile/settings_controller.dart';

final retentionCandidatesProvider = FutureProvider<List<LogsheetModel>>((ref) {
  return ref.read(retentionRepositoryProvider).getArchiveCandidates();
});

final retentionArchiveProvider = FutureProvider<List<LogsheetModel>>((ref) {
  return ref.read(retentionRepositoryProvider).getArchivedItems();
});

final retentionLogsProvider = FutureProvider((ref) {
  return ref.read(retentionRepositoryProvider).getRetentionLogs();
});

class RetentionSettingsPage extends ConsumerStatefulWidget {
  const RetentionSettingsPage({super.key});

  @override
  ConsumerState<RetentionSettingsPage> createState() => _RetentionSettingsPageState();
}

class _RetentionSettingsPageState extends ConsumerState<RetentionSettingsPage> {
  Future<void> _refresh() async {
    ref.invalidate(retentionCandidatesProvider);
    ref.invalidate(retentionArchiveProvider);
    ref.invalidate(retentionLogsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final settings = ref.watch(appSettingsProvider);
    final retention = ref.watch(retentionCandidatesProvider);
    final archived = ref.watch(retentionArchiveProvider);
    final logs = ref.watch(retentionLogsProvider);
    final canConfigure = user?.isAdmin == true || user?.isSuperadmin == true;
    final canView = canConfigure || user?.isSupervisor == true;

    if (!canView) {
      return const Scaffold(body: Center(child: Text('Akses retensi dibatasi untuk supervisor/admin.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Setting Retensi Data')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Retensi Default', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Data lebih lama dari ${settings.retentionYears} tahun akan masuk daftar arsip dan dapat diexport sebelum dihapus.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: settings.retentionYears,
                          decoration: const InputDecoration(labelText: 'Masa retensi (tahun)'),
                          items: [3, 5, 7, 10]
                              .map((item) => DropdownMenuItem(value: item, child: Text('$item tahun')))
                              .toList(),
                          onChanged: canConfigure
                              ? (value) {
                                  if (value != null) {
                                    ref.read(appSettingsProvider.notifier).setRetentionYears(value);
                                    ref.read(retentionRepositoryProvider).setRetentionYears(value);
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            retention.when(
              data: (items) => GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Kandidat Arsip', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('${items.length} data lebih lama dari ${settings.retentionYears} tahun.'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: items.isEmpty
                              ? null
                              : () async {
                                  final bytes = utf8.encode(
                                    const JsonEncoder.withIndent('  ').convert(
                                      items.map((item) => item.toJson()).toList(),
                                    ),
                                  );
                                  final fileName = 'Arsip_Logsheet_${DateTime.now().toIso8601String().substring(0, 10)}.json';
                                  await Share.shareXFiles(
                                    [
                                      XFile.fromData(
                                        bytes,
                                        mimeType: 'application/json',
                                        name: fileName,
                                      ),
                                    ],
                                    text: 'Export arsip data retensi PLN Nusa Daya',
                                  );
                                  await ref.read(retentionRepositoryProvider).saveExportLog(fileName, items.length);
                                  await _refresh();
                                },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Export Arsip'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: !canConfigure || items.isEmpty
                              ? null
                              : () async {
                                  await ref.read(retentionRepositoryProvider).archiveExpired();
                                  await _refresh();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Data lama berhasil dipindahkan ke arsip lokal.')),
                                  );
                                },
                          icon: const Icon(Icons.archive_rounded),
                          label: const Text('Arsipkan Sekarang'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (items.isEmpty)
                      const Text('Belum ada data yang memenuhi batas retensi.')
                    else
                      ...items.take(8).map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${item.unitName} • ${item.machineShortLabel}'),
                          subtitle: Text('${item.operatorName} • ${item.submittedAt}'),
                          trailing: StatusBadge.sync(item.syncStatus),
                        ),
                      ),
                  ],
                ),
              ),
              loading: () => const AppLoading(),
              error: (error, _) => Text(error.toString()),
            ),
            const SizedBox(height: 16),
            archived.when(
              data: (items) => GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Riwayat Arsip', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('${items.length} data telah dipindahkan ke arsip lokal.'),
                  ],
                ),
              ),
              loading: () => const AppLoading(),
              error: (error, _) => Text(error.toString()),
            ),
            const SizedBox(height: 16),
            logs.when(
              data: (items) => GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Log Retensi', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    if (items.isEmpty)
                      const Text('Belum ada aktivitas retensi.')
                    else
                      ...items.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.action),
                          subtitle: Text('${item.affectedCount} data • ${item.createdAt}'),
                        ),
                      ),
                  ],
                ),
              ),
              loading: () => const AppLoading(),
              error: (error, _) => Text(error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
