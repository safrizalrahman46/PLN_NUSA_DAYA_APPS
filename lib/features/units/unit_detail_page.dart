import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/models/machine_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/repositories/error_log_repository.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../../data/repositories/machine_repository.dart';
import '../history/logsheet_detail_page.dart';
import '../logsheet/input_logsheet_page.dart';

final unitMachinesProvider = FutureProvider.family<List<MachineModel>, String>((
  ref,
  unitId,
) {
  return ref.read(machineRepositoryProvider).getMachines(unitId);
});

final unitLogsProvider = FutureProvider.family<List<LogsheetModel>, String>((
  ref,
  unitId,
) async {
  final all = await ref.read(logsheetRepositoryProvider).getHistory();
  return all.where((item) => item.unitId == unitId).toList();
});

final unitErrorCountProvider = FutureProvider.family<int, String>((ref, unitId) async {
  final errors = await ref.read(errorLogRepositoryProvider).getAll();
  return errors.where((item) => item.metadata['unitId']?.toString() == unitId).length;
});

class UnitDetailPage extends ConsumerWidget {
  const UnitDetailPage({super.key, required this.unit});

  final UnitModel unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machines = ref.watch(unitMachinesProvider(unit.id));
    final logs = ref.watch(unitLogsProvider(unit.id));
    final errorCount = ref.watch(unitErrorCountProvider(unit.id));

    return Scaffold(
      appBar: AppBar(title: Text(unit.name)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          GlassCard(
            gradient: AppColors.heroGradient,
            borderColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  unit.locationName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(label: 'Radius ${unit.radiusMeter.toStringAsFixed(0)} m', color: AppColors.highlight),
                    StatusBadge(label: unit.status, color: AppColors.success),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          logs.when(
            data: (items) {
              final pendingCount = items.where((item) => item.syncStatus != SyncStatus.synced).length;
              final operatorNames = items.map((item) => item.operatorName).toSet().toList()..sort();
              final latest = items.take(5).toList();
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _MetricCard(label: 'Total Laporan', value: '${items.length}')),
                      const SizedBox(width: 12),
                      Expanded(child: _MetricCard(label: 'Pending', value: '$pendingCount', color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: errorCount.when(
                          data: (count) => _MetricCard(
                            label: 'Error Terkait',
                            value: '$count',
                            color: AppColors.danger,
                          ),
                          loading: () => const _MetricCard(label: 'Error Terkait', value: '...'),
                          error: (_, __) => const _MetricCard(label: 'Error Terkait', value: '-'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'Operator Terkait',
                          value: '${operatorNames.length}',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Aksi Unit',
                          subtitle: 'Buka input operator atau lihat riwayat terbaru unit ini',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => InputLogsheetPage(initialUnitId: unit.id),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Input Unit Ini'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: latest.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (_) => LogsheetDetailPage(logsheet: latest.first),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.receipt_long_rounded),
                              label: const Text('Lihat Detail Terbaru'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Riwayat Input Terbaru',
                          subtitle: 'Lima laporan paling baru dari unit ini',
                        ),
                        const SizedBox(height: 12),
                        if (latest.isEmpty)
                          const Text('Belum ada riwayat untuk unit ini.')
                        else
                          ...latest.map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${item.operatorName} • ${item.machineShortLabel}'),
                              subtitle: Text(item.lifecycleStatusLabel),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => LogsheetDetailPage(logsheet: item),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  machines.when(
                    data: (machineItems) => GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(
                            title: 'Mesin Terdaftar (${machineItems.length})',
                            subtitle: 'Master mesin yang aktif pada ${unit.name}',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: machineItems
                                .map(
                                  (item) => StatusBadge(
                                    label: item.shortLabel,
                                    color: AppColors.primary,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const AppLoading(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              );
            },
            loading: () => const AppLoading(),
            error: (error, _) => Text(error.toString()),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoft,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
