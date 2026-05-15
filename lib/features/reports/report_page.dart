import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/section_title.dart';
import '../../data/repositories/supervisor_repository.dart';

final reportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(supervisorRepositoryProvider).getReportRows();
});

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  String _period = 'Harian';
  String _unit = 'Semua Unit';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.reportExport),
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: reports.when(
        data: (items) {
          final uniqueUnits =
              items.map((row) => row['unit'].toString()).toSet().toList()
                ..sort();
          final unitOptions = ['Semua Unit', ...uniqueUnits];
          final filtered = items.where((row) {
            return _unit == 'Semua Unit' || row['unit'].toString() == _unit;
          }).toList();

          final totalRows = filtered.length;
          final totalReports = filtered.fold<int>(
            0,
            (sum, row) => sum + ((row['jumlah'] as num?)?.toInt() ?? 0),
          );
          final totalAbnormal = filtered.fold<int>(
            0,
            (sum, row) => sum + ((row['abnormal'] as num?)?.toInt() ?? 0),
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                gradient: AppColors.softSurfaceGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Filter Laporan',
                      subtitle: 'Atur periode, unit, dan tanggal rekap laporan',
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: ['Harian', 'Mingguan', 'Bulanan']
                          .map(
                            (item) => ChoiceChip(
                              label: Text(item),
                              selected: _period == item,
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.primary.withValues(
                                alpha: 0.14,
                              ),
                              side: BorderSide(
                                color: _period == item
                                    ? AppColors.primary.withValues(alpha: 0.42)
                                    : AppColors.border,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _period = item;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Filter unit PLTD',
                      ),
                      items: unitOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _unit = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tanggal rekap: ${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            child: const Text('Ubah'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: 'Rekap $_period',
                      subtitle:
                          'Data dummy siap diganti dengan data backend saat integrasi aktif',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MiniInfo(
                          label: 'Baris Rekap',
                          value: totalRows.toString(),
                        ),
                        _MiniInfo(
                          label: 'Total Laporan',
                          value: totalReports.toString(),
                        ),
                        _MiniInfo(
                          label: 'Total Abnormal',
                          value: totalAbnormal.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      const AppEmptyState(
                        title: 'Rekap kosong',
                        message:
                            'Belum ada data yang sesuai dengan filter laporan saat ini.',
                        icon: Icons.table_chart_outlined,
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Unit')),
                            DataColumn(label: Text('Operator')),
                            DataColumn(label: Text('Jumlah')),
                            DataColumn(label: Text('Tepat Waktu')),
                            DataColumn(label: Text('Terlambat')),
                            DataColumn(label: Text('Abnormal')),
                            DataColumn(label: Text('Pending')),
                          ],
                          rows: filtered
                              .map(
                                (row) => DataRow(
                                  cells: [
                                    DataCell(Text(row['tanggal'].toString())),
                                    DataCell(Text(row['unit'].toString())),
                                    DataCell(Text(row['operator'].toString())),
                                    DataCell(Text(row['jumlah'].toString())),
                                    DataCell(
                                      Text(row['tepatWaktu'].toString()),
                                    ),
                                    DataCell(Text(row['terlambat'].toString())),
                                    DataCell(Text(row['abnormal'].toString())),
                                    DataCell(Text(row['pending'].toString())),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(message: error.toString()),
      ),
    );
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
