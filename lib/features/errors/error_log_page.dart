import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/error_log_model.dart';
import '../../data/repositories/error_log_repository.dart';
import '../auth/auth_controller.dart';
import 'error_log_detail_page.dart';

final errorLogsProvider = FutureProvider<List<ErrorLogModel>>((ref) {
  return ref.read(errorLogRepositoryProvider).getAll();
});

class ErrorLogPage extends ConsumerStatefulWidget {
  const ErrorLogPage({super.key});

  @override
  ConsumerState<ErrorLogPage> createState() => _ErrorLogPageState();
}

class _ErrorLogPageState extends ConsumerState<ErrorLogPage> {
  String _status = 'Semua';
  String _query = '';

  Future<void> _refresh() async {
    ref.invalidate(errorLogsProvider);
    await ref.read(errorLogsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final logs = ref.watch(errorLogsProvider);
    final canView = user?.isSupervisor == true || user?.isAdmin == true || user?.isSuperadmin == true;

    if (!canView) {
      return const Scaffold(
        body: Center(
          child: AppEmptyState(
            title: 'Akses dibatasi',
            message: 'Log error hanya bisa dibuka oleh supervisor atau admin.',
            icon: Icons.admin_panel_settings_rounded,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Log Error')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: logs.when(
          data: (items) {
            final filtered = items.where((item) {
              final matchStatus = _status == 'Semua' || item.status.label == _status;
              final q = _query.toLowerCase();
              final matchQuery = q.isEmpty ||
                  item.message.toLowerCase().contains(q) ||
                  item.page.toLowerCase().contains(q) ||
                  item.userName.toLowerCase().contains(q) ||
                  item.errorType.toLowerCase().contains(q);
              return matchStatus && matchQuery;
            }).toList();

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
                      Text(
                        'Filter Error',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          labelText: 'Cari user, halaman, atau pesan error',
                          suffixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: ['Semua', 'Baru', 'Diproses', 'Selesai']
                            .map(
                              (item) => ChoiceChip(
                                label: Text(item),
                                selected: _status == item,
                                backgroundColor: Colors.white,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.14),
                                onSelected: (_) => setState(() => _status = item),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const AppEmptyState(
                    title: 'Belum ada error',
                    message: 'Semua error penting akan tercatat di halaman ini.',
                    icon: Icons.bug_report_outlined,
                  )
                else
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => ErrorLogDetailPage(errorLogId: item.id),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.errorType,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                StatusBadge(
                                  label: item.status.label,
                                  color: item.status == ErrorLogStatus.selesai
                                      ? AppColors.success
                                      : item.status == ErrorLogStatus.diproses
                                      ? AppColors.warning
                                      : AppColors.danger,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item.message),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                StatusBadge(
                                  label: item.role.label,
                                  color: AppColors.primary,
                                ),
                                StatusBadge(
                                  label: item.page,
                                  color: AppColors.textSoft,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.userName.isEmpty ? 'User tidak diketahui' : item.userName,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSoft,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: '${item.message}\n${item.detail}\n${item.stackTrace}'),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Detail error berhasil disalin.')),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded),
                                  label: const Text('Copy Error'),
                                ),
                              ],
                            ),
                          ],
                        ),
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
