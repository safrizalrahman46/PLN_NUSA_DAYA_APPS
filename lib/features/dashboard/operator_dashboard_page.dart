import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_info.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error_state.dart';
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

  @override
  void initState() {
    super.initState();
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          children: [
            DashboardHeader(user: user, online: online),
            const SizedBox(height: 18),
            if (!online)
              const AppCard(
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
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
                  NextReportCard(
                    nextReportAt: data.nextReportAt,
                    countdownText: DateHelper.countdownText(data.nextReportAt),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
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
                  const SizedBox(height: 18),
                  QuickActionGrid(
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
                  const SizedBox(height: 18),
                  UnitQuickAccessCard(
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
                  const SizedBox(height: 18),
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _ScopeInfo(
                            label: 'Cakupan Lokasi',
                            value: '${DummyData.units.length} unit',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ScopeInfo(
                            label: 'Total Mesin',
                            value: '${DummyData.machines.length} mesin',
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: _ScopeInfo(
                            label: 'Mode Input',
                            value: '1 mesin / 1 jam',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TodayReportStatus(summary: data),
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

class _ScopeInfo extends StatelessWidget {
  const _ScopeInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
