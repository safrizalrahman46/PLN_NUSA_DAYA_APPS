import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_info.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_shimmer.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../auth/auth_controller.dart';
import '../history/history_page.dart';
import '../logsheet/input_logsheet_page.dart';
import '../profile/profile_page.dart';
import '../sync/pending_upload_page.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/next_report_card.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/summary_card.dart';
import 'widgets/today_report_status.dart';
import 'widgets/unit_quick_access_card.dart';

final operatorSummaryProvider = FutureProvider<DashboardSummaryModel>((ref) {
  return ref.read(logsheetRepositoryProvider).getOperatorSummary();
});

class OperatorDashboardPage extends ConsumerStatefulWidget {
  const OperatorDashboardPage({super.key});

  @override
  ConsumerState<OperatorDashboardPage> createState() =>
      _OperatorDashboardPageState();
}

class _OperatorDashboardPageState extends ConsumerState<OperatorDashboardPage> {
  Timer? _timer;
  var _animateIn = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _animateIn = true);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(operatorSummaryProvider);
    await ref.read(operatorSummaryProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final summary = ref.watch(operatorSummaryProvider);
    final online = ref.watch(networkStatusProvider).valueOrNull ?? true;
    final hive = ref.read(hiveServiceProvider);
    final lastSelectedUnitId = hive.settingsBox
        .get('last_selected_unit_id')
        ?.toString();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              20, 18, 20, MediaQuery.of(context).padding.bottom + 108),
          children: [
            DashboardHeader(user: user, online: online),
            const SizedBox(height: 18),
            if (!online)
              GlassCard(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: AppColors.warning.withValues(alpha: 0.35),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: AppColors.warning),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Perangkat sedang offline. Data baru akan disimpan lokal terlebih dahulu.',
                      ),
                    ),
                  ],
                ),
              ),
            if (!online) const SizedBox(height: 18),
            summary.when(
              data: (data) => Column(
                children: [
                  _AnimatedSection(
                    index: 0,
                    animateIn: _animateIn,
                    child: NextReportCard(
                      nextReportAt: data.nextReportAt,
                      countdownText: DateHelper.countdownText(data.nextReportAt),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedSection(
                    index: 1,
                    animateIn: _animateIn,
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: MediaQuery.of(context).size.width >= 700
                          ? 4
                          : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.15,
                      children: [
                        SummaryCard(
                          title: 'Laporan Hari Ini',
                          value: data.todayReports.toString(),
                          icon: Icons.receipt_long_rounded,
                        ),
                        SummaryCard(
                          title: 'Pending Sync',
                          value: data.pendingSync.toString(),
                          icon: Icons.cloud_upload_rounded,
                          tone: SummaryTone.warning,
                        ),
                        SummaryCard(
                          title: 'Laporan Sukses',
                          value: data.successReports.toString(),
                          icon: Icons.check_circle_rounded,
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
                  _AnimatedSection(
                    index: 2,
                    animateIn: _animateIn,
                    child: QuickActionGrid(
                      onInput: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const InputLogsheetPage(),
                        ),
                      ),
                      onHistory: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const HistoryPage(),
                        ),
                      ),
                      onPending: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PendingUploadPage(),
                        ),
                      ),
                      onProfile: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfilePage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AnimatedSection(
                    index: 3,
                    animateIn: _animateIn,
                    child: UnitQuickAccessCard(
                      units: DummyData.units,
                      lastSelectedUnitId: lastSelectedUnitId,
                      onPickUnit: (unit) {
                        hive.settingsBox.put('last_selected_unit_id', unit.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                InputLogsheetPage(initialUnitId: unit.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AnimatedSection(
                    index: 4,
                    animateIn: _animateIn,
                    child: GlassCard(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tileWidth = constraints.maxWidth < 420
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 12) / 2;

                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: tileWidth,
                                child: _ScopeInfo(
                                  label: 'Cakupan Lokasi',
                                  value: '${DummyData.units.length} unit',
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: _ScopeInfo(
                                  label: 'Total Mesin',
                                  value: '${DummyData.machines.length} mesin',
                                ),
                              ),
                              SizedBox(
                                width: tileWidth,
                                child: const _ScopeInfo(
                                  label: 'Mode Input',
                                  value: '1 mesin / 1 jam',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AnimatedSection(
                    index: 5,
                    animateIn: _animateIn,
                    child: TodayReportStatus(summary: data),
                  ),
                ],
              ),
              loading: () => Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppShimmer(
                      child: Container(
                        height: index == 0 ? 130 : 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              error: (error, _) =>
                  AppErrorState(message: error.toString(), onRetry: _refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
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
      duration: Duration(milliseconds: 320 + (index * 80)),
      curve: Curves.easeOutCubic,
      offset: animateIn ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 280 + (index * 80)),
        opacity: animateIn ? 1 : 0,
        child: child,
      ),
    );
  }
}

class _ScopeInfo extends StatelessWidget {
  const _ScopeInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      sigmaX: 8,
      sigmaY: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
