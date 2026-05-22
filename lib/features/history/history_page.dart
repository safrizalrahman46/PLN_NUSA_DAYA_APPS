import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../auth/auth_controller.dart';
import '../logsheet/input_logsheet_page.dart';
import 'logsheet_detail_page.dart';
import 'widgets/history_filter_bar.dart';
import 'widgets/logsheet_history_card.dart';

final historyProvider = FutureProvider<List<LogsheetModel>>((ref) {
  final user = ref.watch(authControllerProvider).user;
  return ref.read(logsheetRepositoryProvider).getHistory(
        operatorId: user?.isOperator == true ? user?.id : null,
      );
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
    final user = ref.watch(authControllerProvider).user;

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
                  item.machineDisplayName.toLowerCase().contains(query) ||
                  item.machineIdentity.toLowerCase().contains(query) ||
                  item.machineCapacityInfo.toLowerCase().contains(query) ||
                  item.machineMasterInfo.toLowerCase().contains(query) ||
                  item.serialNumber.toLowerCase().contains(query);
              final matchSync = switch (_syncFilter) {
                'Tersinkron' => item.syncStatus == SyncStatus.synced,
                'Pending' =>
                  item.syncStatus == SyncStatus.pendingSync ||
                  item.syncStatus == SyncStatus.pendingEdit,
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
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 108,
              ),
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
                const SizedBox(height: 12),
                if (_syncFilter != 'Semua' ||
                    _locationFilter != 'Semua' ||
                    _unitFilter != 'Semua Unit' ||
                    _selectedDate != null)
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_alt_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Menampilkan ${filtered.length} hasil',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _syncFilter = 'Semua';
                            _locationFilter = 'Semua';
                            _unitFilter = 'Semua Unit';
                            _selectedDate = null;
                          }),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.textSoft,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reset semua',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSoft,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
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
                         onEdit: item.canEdit && user?.id == item.operatorId
                             ? () {
                                 Navigator.push(
                                   context,
                                   MaterialPageRoute<void>(
                                     builder: (_) => InputLogsheetPage(
                                       initialLogsheet: item,
                                     ),
                                   ),
                                 ).then((_) => _refresh());
                               }
                             : null,
                       ),
                     ),
                   ),
              ],
            );
          },
          loading: () => const AppLoading(),
          error: (error, _) => AppErrorState(
              message: ApiException.fromObject(error).message,
              onRetry: _refresh,
            ),
        ),
      ),
    );
  }
}
