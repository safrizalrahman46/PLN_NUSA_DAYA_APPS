import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../auth/auth_controller.dart';
import '../history/logsheet_detail_page.dart';
import '../profile/settings_controller.dart';
import 'report_export_page.dart';

final reportLogsProvider = FutureProvider<List<LogsheetModel>>((ref) {
  final user = ref.watch(authControllerProvider).user;
  return ref.read(logsheetRepositoryProvider).getHistory(
        operatorId: user?.isOperator == true ? user?.id : null,
      );
});

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  String _period = 'Semua Periode';
  String _unit = 'Semua Unit';
  String _operator = 'Semua Operator';
  String _status = 'Semua Status';
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(reportLogsProvider);
    final user = ref.watch(authControllerProvider).user;
    final operatorFieldLabel = ref.watch(appSettingsProvider).operatorFieldLabel;
    final isCompact = MediaQuery.sizeOf(context).width < 420;

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: logs.when(
        data: (items) {
          final units = items.map((item) => item.unitName).toSet().toList()..sort();
          final operators = items.map((item) => item.operatorName).toSet().toList()..sort();
          final filtered = items.where(_matchesFilters).toList();

          final unitField = DropdownButtonFormField<String>(
            initialValue: _unit,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: ['Semua Unit', ...units].map(_dropdownItem).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _unit = value);
            },
          );

          final operatorField = DropdownButtonFormField<String>(
            initialValue: _operator,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Operator'),
            items: ['Semua Operator', ...operators].map(_dropdownItem).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _operator = value);
            },
          );

          final statusField = DropdownButtonFormField<String>(
            initialValue: _status,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Status Data'),
            items: const [
              'Semua Status',
              'Draft',
              'Pending Sync',
              'Pending Edit',
              'Terkirim',
              'Sync Gagal',
              'Disetujui',
              'Ditolak',
            ].map(_dropdownItem).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _status = value);
            },
          );

          final startDateField = _DateFilterTile(
            label: 'Tanggal mulai',
            value: _startDate,
            onPick: () => _pickDate(true),
          );

          final endDateField = _DateFilterTile(
            label: 'Tanggal akhir',
            value: _endDate,
            onPick: () => _pickDate(false),
          );

          final referenceDateField = _DateFilterTile(
            label: 'Tanggal acuan $_period',
            value: _selectedDate,
            onPick: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          );

          final resetButton = FilledButton.tonalIcon(
            onPressed: () {
              setState(() {
                _period = 'Semua Periode';
                _unit = 'Semua Unit';
                _operator = 'Semua Operator';
                _status = 'Semua Status';
                _startDate = null;
                _endDate = null;
                _selectedDate = DateTime.now();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset Filter'),
          );

          return ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 108,
            ),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Filter Laporan',
                      subtitle: 'Filter harian, mingguan, bulanan, tahunan, unit, operator, dan status data',
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: ['Semua Periode', 'Harian', 'Mingguan', 'Bulanan', 'Tahunan']
                          .map(
                            (item) => ChoiceChip(
                              label: Text(item),
                              selected: _period == item,
                              backgroundColor: Colors.white,
                              selectedColor:
                                  AppColors.primary.withValues(alpha: 0.14),
                              side: BorderSide(
                                color: _period == item
                                    ? AppColors.primary.withValues(alpha: 0.42)
                                    : AppColors.border,
                              ),
                              onSelected: (_) => setState(() => _period = item),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    if (isCompact) ...[
                      unitField,
                      const SizedBox(height: 12),
                      operatorField,
                    ] else
                      Row(
                        children: [
                          Expanded(child: unitField),
                          const SizedBox(width: 12),
                          Expanded(child: operatorField),
                        ],
                      ),
                    const SizedBox(height: 12),
                    statusField,
                    const SizedBox(height: 12),
                    if (isCompact) ...[
                      startDateField,
                      const SizedBox(height: 12),
                      endDateField,
                    ] else
                      Row(
                        children: [
                          Expanded(child: startDateField),
                          const SizedBox(width: 12),
                          Expanded(child: endDateField),
                        ],
                      ),
                    const SizedBox(height: 12),
                    if (isCompact) ...[
                      if (_period != 'Semua Periode') ...[
                        referenceDateField,
                        const SizedBox(height: 12),
                      ],
                      SizedBox(width: double.infinity, child: resetButton),
                    ] else
                      Row(
                        children: [
                          if (_period != 'Semua Periode') ...[
                            Expanded(child: referenceDateField),
                            const SizedBox(width: 12),
                          ],
                          Expanded(child: resetButton),
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
                    SectionTitle(
                      title: 'Rekap $_period',
                      subtitle: _dateRangeLabel(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MiniInfo(label: 'Total Data', value: filtered.length.toString()),
                        _MiniInfo(
                          label: 'Pending',
                          value: filtered.where((item) => item.syncStatus != SyncStatus.synced).length.toString(),
                        ),
                        _MiniInfo(
                          label: 'Abnormal',
                          value: filtered.where((item) => item.reportStatus == ReportStatus.abnormal).length.toString(),
                        ),
                        _MiniInfo(
                          label: 'Disetujui',
                          value: filtered.where((item) => item.approvalStatus == ApprovalStatus.approved).length.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: filtered.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => ReportExportPage(
                                        records: filtered,
                                        periodLabel: _period,
                                        dateRangeLabel: _dateRangeLabel(),
                                        exportedBy: user?.name ?? 'Supervisor',
                                        operatorFieldLabel: operatorFieldLabel,
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download Laporan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      const AppEmptyState(
                        title: 'Rekap kosong',
                        message: 'Belum ada data yang sesuai dengan filter laporan saat ini.',
                        icon: Icons.table_chart_outlined,
                      )
                    else ...[
                      Text(
                        'Ketuk salah satu baris untuk melihat parameter lengkap hasil input operator.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSoft,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Unit')),
                            DataColumn(label: Text('Operator')),
                            DataColumn(label: Text('Mesin')),
                            DataColumn(label: Text('Status Data')),
                            DataColumn(label: Text('Laporan')),
                            DataColumn(label: Text('Parameter Utama')),
                            DataColumn(label: Text('Catatan')),
                          ],
                          rows: filtered
                              .map(
                                (row) => DataRow(
                                  onSelectChanged: (_) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => LogsheetDetailPage(
                                          logsheet: row,
                                          title: 'Detail Laporan',
                                        ),
                                      ),
                                    );
                                  },
                                  cells: [
                                    DataCell(Text(DateFormat('dd-MM-yyyy HH:mm').format(row.submittedAt))),
                                    DataCell(Text(row.unitName)),
                                    DataCell(Text(row.operatorName)),
                                    DataCell(Text(row.machineShortLabel)),
                                    DataCell(Text(row.lifecycleStatusLabel)),
                                    DataCell(Text(row.reportStatus.name)),
                                    DataCell(
                                      SizedBox(
                                        width: 240,
                                        child: Text(
                                          _parameterPreview(
                                            row,
                                            operatorFieldLabel,
                                          ),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 220,
                                        child: Text(row.notes),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(
          message: ApiException.fromObject(error).message,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _dropdownItem(String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _parameterPreview(
    LogsheetModel item,
    String operatorFieldLabel,
  ) {
    final buf = StringBuffer()
      ..write('Beban ${item.bebanMesin.toStringAsFixed(1)} kW\n')
      ..write('KWH ${item.standKwh.toStringAsFixed(1)} • BBM ${item.standBbm.toStringAsFixed(1)} L\n')
      ..write('Oli ${item.tekananOli.toStringAsFixed(1)} bar • Air ${item.temperaturAir.toStringAsFixed(1)} C\n')
      ..write('Phasa ${item.phasaR.toStringAsFixed(0)}/${item.phasaS.toStringAsFixed(0)}/${item.phasaT.toStringAsFixed(0)} • ')
      ..write('Teg ${item.tegangan.toStringAsFixed(0)} V • Hz ${item.frequency.toStringAsFixed(1)} • ')
      ..write('CosPhi ${item.cosPhi.toStringAsFixed(2)}');
    if (item.fieldCondition.isNotEmpty) {
      buf.write('\n$operatorFieldLabel: ${item.fieldCondition}');
    }
    return buf.toString();
  }

  bool _matchesFilters(LogsheetModel item) {
    final matchUnit = _unit == 'Semua Unit' || item.unitName == _unit;
    final matchOperator =
        _operator == 'Semua Operator' || item.operatorName == _operator;
    final matchStatus = switch (_status) {
      'Draft' => item.lifecycleStatusLabel == 'Draft',
      'Pending Sync' => item.lifecycleStatusLabel == 'Pending Sync',
      'Pending Edit' => item.lifecycleStatusLabel == 'Pending Edit',
      'Terkirim' => item.lifecycleStatusLabel == 'Terkirim',
      'Sync Gagal' => item.lifecycleStatusLabel == 'Sync Gagal',
      'Disetujui' => item.lifecycleStatusLabel == 'Disetujui',
      'Ditolak' => item.lifecycleStatusLabel == 'Ditolak',
      _ => true,
    };
    final hasDateRange = _startDate != null || _endDate != null;
    final matchRange = (!hasDateRange) ||
        ((_startDate == null || !item.submittedAt.isBefore(_startDate!)) &&
            (_endDate == null || !item.submittedAt.isAfter(_endDate!.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)))));
    // If a date range is explicitly set, the period chip is ignored to avoid confusion
    final matchPeriod = hasDateRange || switch (_period) {
      'Harian' => _isSameDay(item.submittedAt, _selectedDate),
      'Mingguan' => _isInSameWeek(item.submittedAt, _selectedDate),
      'Bulanan' => item.submittedAt.year == _selectedDate.year && item.submittedAt.month == _selectedDate.month,
      'Tahunan' => item.submittedAt.year == _selectedDate.year,
      _ => true,
    };
    return matchUnit && matchOperator && matchStatus && matchRange && matchPeriod;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInSameWeek(DateTime value, DateTime anchor) {
    final start = anchor.subtract(Duration(days: anchor.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return !value.isBefore(DateTime(start.year, start.month, start.day)) &&
        value.isBefore(DateTime(end.year, end.month, end.day));
  }

  String _dateRangeLabel() {
    if (_startDate != null || _endDate != null) {
      final start = _startDate == null ? '-' : DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!);
      final end = _endDate == null ? '-' : DateFormat('dd MMM yyyy', 'id_ID').format(_endDate!);
      return '$start s/d $end';
    }

    switch (_period) {
      case 'Semua Periode':
        return 'Semua data tersedia';
      case 'Harian':
        return DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
      case 'Mingguan':
        final start = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('dd MMM', 'id_ID').format(start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(end)}';
      case 'Bulanan':
        return DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);
      case 'Tahunan':
        return DateFormat('yyyy', 'id_ID').format(_selectedDate);
      default:
        return '-';
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? _selectedDate) : (_endDate ?? _selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.softSurfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _DateFilterTile extends StatelessWidget {
  const _DateFilterTile({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
        ),
        child: Text(
          value == null ? '-' : DateFormat('dd MMM yyyy', 'id_ID').format(value!),
        ),
      ),
    );
  }
}
