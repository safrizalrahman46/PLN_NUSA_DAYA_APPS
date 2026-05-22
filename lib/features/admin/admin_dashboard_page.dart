import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/error_log_repository.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../../data/repositories/machine_repository.dart';
import '../../data/repositories/retention_repository.dart';
import '../../data/repositories/unit_repository.dart';
import '../../data/dummy/dummy_data.dart';
import '../errors/error_log_page.dart';
import '../notifications/notification_page.dart';
import '../reports/report_page.dart';
import '../supervisor/admin_management_page.dart';
import 'retention_settings_page.dart';

final adminDashboardCountsProvider = FutureProvider((ref) async {
  final history = await ref.read(logsheetRepositoryProvider).getHistory();
  final errors = await ref.read(errorLogRepositoryProvider).getAll();
  final retention = await ref.read(retentionRepositoryProvider).getArchiveCandidates();
  final units = await ref.read(unitRepositoryProvider).getUnits();
  final machines = await ref.read(machineRepositoryProvider).getAllMachines();
  return {
    'users': DummyData.users.length,
    'units': units.length,
    'machines': machines.length,
    'reports': history.length,
    'pending': history.where((item) => item.syncStatus != SyncStatus.synced).length,
    'errors': errors.length,
    'retention': retention.length,
  };
});

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key, required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(adminDashboardCountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: counts.when(
        data: (data) => ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).padding.bottom + 108,
          ),
          children: [
            GlassCard(
              gradient: AppColors.heroGradient,
              borderColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${user?.name ?? 'Admin'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola master data, laporan, retensi, dan log error PLN Nusa Daya dari satu panel.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(label: 'User', value: '${data['users']}'),
                _MetricTile(label: 'Unit', value: '${data['units']}', color: AppColors.success),
                _MetricTile(label: 'Mesin', value: '${data['machines']}', color: AppColors.accent),
                _MetricTile(label: 'Laporan', value: '${data['reports']}', color: AppColors.highlight),
                _MetricTile(label: 'Pending', value: '${data['pending']}', color: AppColors.warning),
                _MetricTile(label: 'Error', value: '${data['errors']}', color: AppColors.danger),
                _MetricTile(label: 'Retensi', value: '${data['retention']}', color: AppColors.textSoft),
              ],
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aksi Admin',
                    style: Theme.of(context).textTheme.titleLarge,
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
                              builder: (_) => const AdminManagementPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.dataset_rounded),
                        label: const Text('Master Data'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const ReportPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bar_chart_rounded),
                        label: const Text('Laporan'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const ErrorLogPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bug_report_rounded),
                        label: const Text('Log Error'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const RetentionSettingsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.archive_rounded),
                        label: const Text('Retensi Data'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const NotificationPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_active_rounded),
                        label: const Text('Notifikasi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(message: ApiException.fromObject(error).message),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width < 700 ? (MediaQuery.of(context).size.width - 52) / 2 : 170,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSoft)),
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
      ),
    );
  }
}
