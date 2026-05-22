import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/supervisor_repository.dart';
import '../auth/auth_controller.dart';
import '../dashboard/widgets/report_donut_chart.dart';
import '../dashboard/widgets/summary_card.dart';
import 'widgets/heatmap_status_table.dart';
import 'widgets/yamazumi_chart.dart';

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

final reportRowsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(supervisorRepositoryProvider).getReportRows();
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
  var _animateIn = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _animateIn = true);
    });
    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) return;
      setState(() => _lastUpdated = DateTime.now());
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
    ref.invalidate(reportRowsProvider);
    setState(() => _lastUpdated = DateTime.now());
    await ref.read(supervisorDashboardProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(supervisorDashboardProvider);
    final heatmap = ref.watch(heatmapProvider(_selectedDate));
    final reportRows = ref.watch(reportRowsProvider);
    final user = ref.watch(authControllerProvider).user;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Supervisor')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).padding.bottom + 108),
          children: [
            // ── Hero card ────────────────────────────────────────────────
            _DashSection(
              index: 0,
              animateIn: _animateIn,
              child: _SupervisorHeroCard(
                user: user,
                online: online,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 18),

            // ── Summary cards ─────────────────────────────────────────────
            summary.when(
              data: (data) => Column(
                children: [
                  _DashSection(
                    index: 1,
                    animateIn: _animateIn,
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount:
                          MediaQuery.of(context).size.width >= 700 ? 4 : 2,
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
                  ),
                  const SizedBox(height: 18),

                  // ── Status monitoring ──────────────────────────────────
                  _DashSection(
                    index: 2,
                    animateIn: _animateIn,
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(
                            title: 'Status Monitoring',
                            subtitle:
                                'Unit submit, laporan pending, dan operator terlambat',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _StatusTile(
                                  label: 'Unit Submit',
                                  value: data.successReports.toString(),
                                  color: AppColors.success,
                                  icon: Icons.check_circle_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatusTile(
                                  label: 'Laporan Pending',
                                  value: data.pendingSync.toString(),
                                  color: AppColors.warning,
                                  icon: Icons.sync_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatusTile(
                                  label: 'Operator Terlambat',
                                  value: data.lateOperators.toString(),
                                  color: AppColors.danger,
                                  icon: Icons.access_time_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Donut chart ────────────────────────────────────────
                  _DashSection(
                    index: 3,
                    animateIn: _animateIn,
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(
                            title: 'Distribusi Status Laporan',
                            subtitle:
                                'Proporsi laporan sukses, pending, terlambat, dan abnormal hari ini',
                          ),
                          const SizedBox(height: 16),
                          ReportDonutChart(
                            success: data.successReports,
                            pending: data.pendingSync,
                            late: data.lateOperators,
                            abnormal: data.abnormalReports,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const AppLoading(),
              error: (error, _) =>
                  AppErrorState(message: ApiException.fromObject(error).message),
            ),
            const SizedBox(height: 18),

            // ── Yamazumi chart ─────────────────────────────────────────────
            _DashSection(
              index: 4,
              animateIn: _animateIn,
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Beban Laporan per Unit',
                      subtitle:
                          'Distribusi tepat waktu, terlambat, dan abnormal — Yamazumi Chart',
                    ),
                    const SizedBox(height: 16),
                    reportRows.when(
                      data: (rows) => YamazumiChart(rows: rows),
                      loading: () =>
                          const SizedBox(height: 120, child: AppLoading()),
                      error: (e, _) => AppErrorState(message: e.toString()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Date picker for heatmap ────────────────────────────────────
            GlassCard(
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Hari ini'),
                    selected: _isSameDate(_selectedDate, DateTime.now()),
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.primary.withValues(alpha: 0.14),
                    side: BorderSide(
                      color: _isSameDate(_selectedDate, DateTime.now())
                          ? AppColors.primary.withValues(alpha: 0.42)
                          : AppColors.border,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedDate = DateTime.now()),
                  ),
                  ChoiceChip(
                    label: const Text('Kemarin'),
                    selected: _isSameDate(
                      _selectedDate,
                      DateTime.now().subtract(const Duration(days: 1)),
                    ),
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.primary.withValues(alpha: 0.14),
                    side: BorderSide(
                      color: _isSameDate(
                        _selectedDate,
                        DateTime.now().subtract(const Duration(days: 1)),
                      )
                          ? AppColors.primary.withValues(alpha: 0.42)
                          : AppColors.border,
                    ),
                    onSelected: (_) => setState(
                      () => _selectedDate =
                          DateTime.now().subtract(const Duration(days: 1)),
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Pilih tanggal'),
                    selected: !_isSameDate(_selectedDate, DateTime.now()) &&
                        !_isSameDate(
                          _selectedDate,
                          DateTime.now().subtract(const Duration(days: 1)),
                        ),
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.primary.withValues(alpha: 0.14),
                    side: BorderSide(
                      color: (!_isSameDate(_selectedDate, DateTime.now()) &&
                              !_isSameDate(
                                _selectedDate,
                                DateTime.now()
                                    .subtract(const Duration(days: 1)),
                              ))
                          ? AppColors.primary.withValues(alpha: 0.42)
                          : AppColors.border,
                    ),
                    onSelected: (_) async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Heatmap ────────────────────────────────────────────────────
            heatmap.when(
              data: (data) => HeatmapStatusTable(
                heatmap: data,
                dateLabel: DateHelper.formatDate(_selectedDate),
                lastUpdatedLabel: DateHelper.formatHour(_lastUpdated),
              ),
              loading: () => const AppLoading(label: 'Memuat heatmap...'),
              error: (error, _) =>
                  AppErrorState(message: ApiException.fromObject(error).message),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Hero card ────────────────────────────────────────────────────────────────

class _SupervisorHeroCard extends StatelessWidget {
  const _SupervisorHeroCard({
    required this.user,
    required this.online,
    required this.isDark,
  });

  final UserModel? user;
  final bool online;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkGradient : AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Aurora orb — top right
          Positioned(
            right: -50,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraCyan.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Aurora orb — bottom left
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraViolet.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Aurora orb — center right
          Positioned(
            right: 60,
            bottom: 10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraBlue.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppBrandLogo.full(width: 108, withContainer: true),
                    const Spacer(),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      borderRadius: 999,
                      sigmaX: 8,
                      sigmaY: 8,
                      borderColor: Colors.white.withValues(alpha: 0.30),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateHelper.formatHour(DateTime.now()),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  DateHelper.greeting(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Supervisor PLTD',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supervisor Control Center',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    StatusBadge(
                      label: online ? 'Online' : 'Offline',
                      color: online ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      borderRadius: 999,
                      sigmaX: 6,
                      sigmaY: 6,
                      borderColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        'Supervisor',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      borderRadius: 999,
                      sigmaX: 6,
                      sigmaY: 6,
                      borderColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        DateHelper.formatDate(DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status tile ──────────────────────────────────────────────────────────────

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.22 : 0.10),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.28 : 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textSoft,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Animated section ─────────────────────────────────────────────────────────

class _DashSection extends StatelessWidget {
  const _DashSection({
    required this.index,
    required this.animateIn,
    required this.child,
  });

  final int index;
  final bool animateIn;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Duration(milliseconds: 300 + (index * 90)),
      curve: Curves.easeOutCubic,
      offset: animateIn ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 260 + (index * 90)),
        opacity: animateIn ? 1 : 0,
        child: child,
      ),
    );
  }
}
