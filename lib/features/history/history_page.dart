import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import 'logsheet_detail_page.dart';
import 'widgets/history_filter_bar.dart';
import 'widgets/logsheet_history_card.dart';

final historyProvider = FutureProvider<List<LogsheetModel>>((ref) {
  return ref.read(logsheetRepositoryProvider).getHistory();
});

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _query = '';
  String _syncFilter = 'Semua';
  String _locationFilter = 'Semua';
  String _unitFilter = 'Semua Unit';
  DateTime? _selectedDate;

  Future<void> _refresh() async {
    ref.invalidate(historyProvider);
    await ref.read(historyProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Logsheet')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: history.when(
          data: (items) {
            final units = items.map((item) => item.unitName).toSet().toList()
              ..sort();
            final filtered = items.where((item) {
              final query = _query.toLowerCase();
              final matchQuery =
                  query.isEmpty ||
                  item.proofId.toLowerCase().contains(query) ||
                  item.unitName.toLowerCase().contains(query) ||
                  item.serialNumber.toLowerCase().contains(query);
              final matchSync = switch (_syncFilter) {
                'Tersinkron' => item.syncStatus == SyncStatus.synced,
                'Pending' => item.syncStatus == SyncStatus.pendingSync,
                'Gagal' => item.syncStatus == SyncStatus.failed,
                'Draft' => item.syncStatus == SyncStatus.draft,
                _ => true,
              };
              final matchLocation = switch (_locationFilter) {
                'Valid' => item.locationStatus == LocationStatus.valid,
                'Di luar area' =>
                  item.locationStatus == LocationStatus.outsideArea,
                'GPS mati' => item.locationStatus == LocationStatus.gpsOff,
                'Izin ditolak' =>
                  item.locationStatus == LocationStatus.permissionDenied,
                _ => true,
              };
              final matchUnit =
                  _unitFilter == 'Semua Unit' || item.unitName == _unitFilter;
              final matchDate =
                  _selectedDate == null ||
                  (item.submittedAt.year == _selectedDate!.year &&
                      item.submittedAt.month == _selectedDate!.month &&
                      item.submittedAt.day == _selectedDate!.day);
              return matchQuery &&
                  matchSync &&
                  matchLocation &&
                  matchUnit &&
                  matchDate;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                HistoryFilterBar(
                  onSearchChanged: (value) => setState(() => _query = value),
                  selectedDateLabel: _selectedDate == null
                      ? 'Semua tanggal'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}',
                  selectedSync: _syncFilter,
                  selectedLocation: _locationFilter,
                  selectedUnit: _unitFilter,
                  units: units,
                  onPickDate: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  onSyncChanged: (value) => setState(() => _syncFilter = value),
                  onLocationChanged: (value) =>
                      setState(() => _locationFilter = value),
                  onUnitChanged: (value) => setState(() => _unitFilter = value),
                ),
                const SizedBox(height: 16),
                AppCard(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniInfoChip(
                        icon: Icons.filter_alt_rounded,
                        label: 'Hasil ${filtered.length}',
                      ),
                      _MiniInfoChip(
                        icon: Icons.sync_rounded,
                        label: _syncFilter,
                      ),
                      _MiniInfoChip(
                        icon: Icons.location_on_rounded,
                        label: _locationFilter,
                      ),
                      _MiniInfoChip(
                        icon: Icons.calendar_month_rounded,
                        label: _selectedDate == null ? 'Semua tanggal' : '1 hari',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  const AppEmptyState(
                    title: 'Data tidak ditemukan',
                    message:
                        'Coba ubah kata kunci pencarian atau filter riwayat.',
                    icon: Icons.history_toggle_off_rounded,
                  )
                else
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LogsheetHistoryCard(
                        logsheet: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  LogsheetDetailPage(logsheet: item),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const AppLoading(),
          error: (error, _) =>
              AppErrorState(message: error.toString(), onRetry: _refresh),
        ),
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
