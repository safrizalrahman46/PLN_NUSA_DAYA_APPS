import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_helper.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/section_title.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../data/repositories/supervisor_repository.dart';
import '../dashboard/widgets/summary_card.dart';
import 'widgets/heatmap_status_table.dart';

final supervisorDashboardProvider = FutureProvider<DashboardSummaryModel>((
  ref,
) {
  return ref.read(supervisorRepositoryProvider).getDashboardSummary();
});

final heatmapProvider =
    FutureProvider.family<Map<String, Map<String, String>>, DateTime>((
      ref,
      date,
    ) {
      return ref.read(supervisorRepositoryProvider).getHeatmap(date);
    });

class SupervisorDashboardPage extends ConsumerStatefulWidget {
  const SupervisorDashboardPage({super.key});

  @override
  ConsumerState<SupervisorDashboardPage> createState() =>
      _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState
    extends ConsumerState<SupervisorDashboardPage> {
  Timer? _timer;
  DateTime _selectedDate = DateTime.now();
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lastUpdated = DateTime.now();
      });
      ref.invalidate(heatmapProvider(_selectedDate));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(supervisorDashboardProvider);
    ref.invalidate(heatmapProvider(_selectedDate));
    setState(() {
      _lastUpdated = DateTime.now();
    });
    await ref.read(supervisorDashboardProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(supervisorDashboardProvider);
    final heatmap = ref.watch(heatmapProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Supervisor')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            summary.when(
              data: (data) => Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: MediaQuery.of(context).size.width >= 700
                        ? 4
                        : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    children: [
                      SummaryCard(
                        title: 'Total Unit',
                        value: data.totalUnits.toString(),
                        icon: Icons.apartment_rounded,
                      ),
                      SummaryCard(
                        title: 'Total Operator',
                        value: data.totalOperators.toString(),
                        icon: Icons.groups_rounded,
                      ),
                      SummaryCard(
                        title: 'Laporan Hari Ini',
                        value: data.todayReports.toString(),
                        icon: Icons.receipt_long_rounded,
                        tone: SummaryTone.success,
                      ),
                      SummaryCard(
                        title: 'Laporan Abnormal',
                        value: data.abnormalReports.toString(),
                        icon: Icons.warning_amber_rounded,
                        tone: SummaryTone.danger,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Status Monitoring',
                          subtitle:
                              'Ringkasan unit sudah submit, unit pending, dan operator terlambat',
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatusInfo(
                              label: 'Unit sudah submit',
                              value: data.successReports.toString(),
                              color: Colors.green,
                            ),
                            _StatusInfo(
                              label: 'Laporan pending',
                              value: data.pendingSync.toString(),
                              color: Colors.orange,
                            ),
                            _StatusInfo(
                              label: 'Operator terlambat',
                              value: data.lateOperators.toString(),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Analitik Operasional',
                          subtitle:
                              'Ringkasan beban, laporan per unit, dan status laporan',
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: true),
                              titlesData: const FlTitlesData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  color: Colors.cyan,
                                  barWidth: 3,
                                  spots: const [
                                    FlSpot(0, 2.5),
                                    FlSpot(1, 3.2),
                                    FlSpot(2, 2.8),
                                    FlSpot(3, 3.8),
                                    FlSpot(4, 3.4),
                                    FlSpot(5, 4.2),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(
                                6,
                                (index) => BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (index + 2) * 2.0,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 42,
                              sections: [
                                PieChartSectionData(
                                  value: data.successReports.toDouble(),
                                  color: Colors.green,
                                  title: 'Sukses',
                                ),
                                PieChartSectionData(
                                  value: data.pendingSync.toDouble(),
                                  color: Colors.orange,
                                  title: 'Pending',
                                ),
                                PieChartSectionData(
                                  value: data.abnormalReports.toDouble(),
                                  color: Colors.red,
                                  title: 'Abnormal',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const AppLoading(),
              error: (error, _) => AppErrorState(message: error.toString()),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Hari ini'),
                    selected: _isSameDate(_selectedDate, DateTime.now()),
                    onSelected: (_) {
                      setState(() {
                        _selectedDate = DateTime.now();
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Kemarin'),
                    selected: _isSameDate(
                      _selectedDate,
                      DateTime.now().subtract(const Duration(days: 1)),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedDate = DateTime.now().subtract(
                          const Duration(days: 1),
                        );
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Pilih tanggal'),
                    selected:
                        !_isSameDate(_selectedDate, DateTime.now()) &&
                        !_isSameDate(
                          _selectedDate,
                          DateTime.now().subtract(const Duration(days: 1)),
                        ),
                    onSelected: (_) async {
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            heatmap.when(
              data: (data) => HeatmapStatusTable(
                heatmap: data,
                dateLabel: DateHelper.formatDate(_selectedDate),
                lastUpdatedLabel: DateHelper.formatHour(_lastUpdated),
              ),
              loading: () => const AppLoading(label: 'Memuat heatmap...'),
              error: (error, _) => AppErrorState(message: error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _StatusInfo extends StatelessWidget {
  const _StatusInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
