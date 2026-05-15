import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/repositories/supervisor_repository.dart';
import 'report_detail_supervisor_page.dart';
import 'widgets/monitoring_filter_bar.dart';
import 'widgets/operator_status_card.dart';

final monitoringProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(supervisorRepositoryProvider).getMonitoringItems();
});

class OperatorMonitoringPage extends ConsumerStatefulWidget {
  const OperatorMonitoringPage({super.key});

  @override
  ConsumerState<OperatorMonitoringPage> createState() =>
      _OperatorMonitoringPageState();
}

class _OperatorMonitoringPageState
    extends ConsumerState<OperatorMonitoringPage> {
  String _query = '';
  String _status = 'Semua';
  String _unit = 'Semua Unit';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final monitoring = ref.watch(monitoringProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Operator')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monitoringProvider);
          await ref.read(monitoringProvider.future);
        },
        child: monitoring.when(
          data: (items) {
            final availableUnits =
                items.map((item) => item['unit'].toString()).toSet().toList()
                  ..sort();
            final filtered = items.where((item) {
              final unit = item['unit'].toString();
              final operator = item['operator'].toString();
              final reportStatus = item['reportStatus'].toString();
              final rawSubmit = item['lastSubmit'];
              final lastSubmit = rawSubmit is DateTime
                  ? rawSubmit
                  : DateTime.tryParse(rawSubmit?.toString() ?? '');
              final matchQuery =
                  _query.isEmpty ||
                  unit.toLowerCase().contains(_query.toLowerCase()) ||
                  operator.toLowerCase().contains(_query.toLowerCase());
              final matchStatus =
                  _status == 'Semua' ||
                  reportStatus.toLowerCase() == _status.toLowerCase();
              final matchUnit = _unit == 'Semua Unit' || unit == _unit;
              final matchDate =
                  _selectedDate == null ||
                  (lastSubmit != null &&
                      lastSubmit.year == _selectedDate!.year &&
                      lastSubmit.month == _selectedDate!.month &&
                      lastSubmit.day == _selectedDate!.day);
              return matchQuery && matchStatus && matchUnit && matchDate;
            }).toList();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                MonitoringFilterBar(
                  onSearch: (value) => setState(() => _query = value),
                  selectedDateLabel: _selectedDate == null
                      ? 'Semua tanggal'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}',
                  selectedStatus: _status,
                  selectedUnit: _unit,
                  availableUnits: availableUnits,
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
                  onStatusChanged: (value) => setState(() => _status = value),
                  onUnitChanged: (value) => setState(() => _unit = value),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const AppEmptyState(
                    title: 'Monitoring kosong',
                    message:
                        'Belum ada data yang sesuai dengan filter monitoring.',
                    icon: Icons.monitor_heart_outlined,
                  )
                else
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OperatorStatusCard(
                        item: item,
                        onDetail: item['logsheet'] == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => ReportDetailSupervisorPage(
                                      logsheet: item['logsheet'],
                                    ),
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
          error: (error, _) => AppErrorState(message: error.toString()),
        ),
      ),
    );
  }
}
