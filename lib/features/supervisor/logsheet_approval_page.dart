import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/local/local_logsheet_datasource.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/models/user_model.dart';
import '../auth/auth_controller.dart';

final approvalLogsheetListProvider =
    FutureProvider<List<LogsheetModel>>((ref) async {
  // Try remote first
  try {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/logsheets/history',
      queryParameters: {'limit': '100'},
    );
    final data = response.data['data'] as List<dynamic>?;
    if (data != null) {
      return data
          .map(
            (item) =>
                LogsheetModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
  } catch (_) {}

  // Fallback to local
  return ref.read(localLogsheetDatasourceProvider).fetchAll();
});

class LogsheetApprovalPage extends ConsumerWidget {
  const LogsheetApprovalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsheetsAsync = ref.watch(approvalLogsheetListProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Logsheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(approvalLogsheetListProvider),
          ),
        ],
      ),
      body: logsheetsAsync.when(
        data: (logsheets) {
          final pending = logsheets
              .where(
                (l) =>
                    l.syncStatus == SyncStatus.synced &&
                    l.approvalStatus == ApprovalStatus.pendingReview,
              )
              .toList();
          final approved = logsheets
              .where((l) => l.approvalStatus == ApprovalStatus.approved)
              .toList();
          final rejected = logsheets
              .where((l) => l.approvalStatus == ApprovalStatus.rejected)
              .toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 100,
            ),
            children: [
              // Summary banner
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Antrian Approval Logsheet',
                      subtitle:
                          'Tinjau dan setujui atau tolak setiap laporan yang masuk dari operator.',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _SummaryPill(
                          label: 'Menunggu',
                          count: pending.length,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        _SummaryPill(
                          label: 'Disetujui',
                          count: approved.length,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        _SummaryPill(
                          label: 'Ditolak',
                          count: rejected.length,
                          color: AppColors.danger,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pending review section
              if (pending.isEmpty)
                const _EmptyApprovalBanner()
              else ...[
                const _SectionLabel(
                  label: 'Menunggu Review',
                  color: AppColors.warning,
                ),
                const SizedBox(height: 10),
                ...pending.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LogsheetApprovalCard(
                      logsheet: l,
                      canApprove: true,
                      currentUser: user,
                      onApprove: () => _doApprove(context, ref, l),
                      onReject: () => _doReject(context, ref, l),
                    ),
                  ),
                ),
              ],

              // Approved section
              if (approved.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionLabel(
                  label: 'Disetujui',
                  color: AppColors.success,
                ),
                const SizedBox(height: 10),
                ...approved.take(10).map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LogsheetApprovalCard(
                      logsheet: l,
                      canApprove: false,
                      currentUser: user,
                    ),
                  ),
                ),
              ],

              // Rejected section
              if (rejected.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionLabel(
                  label: 'Ditolak',
                  color: AppColors.danger,
                ),
                const SizedBox(height: 10),
                ...rejected.take(10).map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LogsheetApprovalCard(
                      logsheet: l,
                      canApprove: false,
                      currentUser: user,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorState(
          message: ApiException.fromObject(e).message,
          onRetry: () => ref.invalidate(approvalLogsheetListProvider),
        ),
      ),
    );
  }

  Future<void> _doApprove(
    BuildContext context,
    WidgetRef ref,
    LogsheetModel logsheet,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Logsheet'),
        content: Text(
          'Anda akan menyetujui laporan logsheet dari operator '
          '"${logsheet.operatorName}" – mesin "${logsheet.machineName}".\n\n'
          'Tindakan ini akan dicatat dalam audit trail.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.put(
        '/logsheets/${logsheet.id}/approve',
        data: {'approval_status': 'approved'},
      );
      ref.invalidate(approvalLogsheetListProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logsheet berhasil disetujui.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiException.fromObject(e).message),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _doReject(
    BuildContext context,
    WidgetRef ref,
    LogsheetModel logsheet,
  ) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Logsheet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operator: ${logsheet.operatorName}\n'
              'Mesin: ${logsheet.machineName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: reasonController,
              label: 'Alasan Penolakan *',
              hint: 'Tuliskan alasan penolakan dengan jelas…',
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: AppColors.danger,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Operator akan menerima notifikasi penolakan beserta alasannya.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan wajib diisi.'),
                  ),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();

    if (confirmed != true || !context.mounted) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.put(
        '/logsheets/${logsheet.id}/approve',
        data: {
          'approval_status': 'rejected',
          'rejection_reason': reason,
        },
      );
      ref.invalidate(approvalLogsheetListProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logsheet ditolak dan operator diberi notifikasi.'),
          backgroundColor: AppColors.danger.withValues(alpha: 0.85),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiException.fromObject(e).message),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

// ─────────────────── Widgets ───────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyApprovalBanner extends StatelessWidget {
  const _EmptyApprovalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Semua Logsheet Sudah Ditinjau',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada logsheet yang menunggu review saat ini.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogsheetApprovalCard extends StatelessWidget {
  const _LogsheetApprovalCard({
    required this.logsheet,
    required this.canApprove,
    required this.currentUser,
    this.onApprove,
    this.onReject,
  });

  final LogsheetModel logsheet;
  final bool canApprove;
  final UserModel? currentUser;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final approval = logsheet.approvalStatus;
    final approvalColor = switch (approval) {
      ApprovalStatus.pendingReview => AppColors.warning,
      ApprovalStatus.approved => AppColors.success,
      ApprovalStatus.rejected => AppColors.danger,
    };

    final syncColor = logsheet.syncStatus == SyncStatus.synced
        ? AppColors.success
        : AppColors.warning;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: approvalColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  approval == ApprovalStatus.approved
                      ? Icons.check_circle_rounded
                      : approval == ApprovalStatus.rejected
                      ? Icons.cancel_rounded
                      : Icons.pending_actions_rounded,
                  color: approvalColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      logsheet.machineName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${logsheet.operatorName} • ${logsheet.unitName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label: approval.label,
                    color: approvalColor,
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(
                    label: logsheet.syncStatus.name,
                    color: syncColor,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Detail grid
          _DetailGrid(logsheet: logsheet),

          // Rejection reason if rejected
          if (logsheet.approvalStatus == ApprovalStatus.rejected &&
              logsheet.rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alasan Penolakan:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    logsheet.rejectionReason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons for pending review
          if (canApprove && approval == ApprovalStatus.pendingReview) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.45),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.logsheet});

  final LogsheetModel logsheet;

  @override
  Widget build(BuildContext context) {
    final items = <String, String>{
      'Mesin': logsheet.machineName,
      'Beban': '${logsheet.bebanMesin} kW',
      'Stand KWH': '${logsheet.standKwh}',
      'Stand BBM': '${logsheet.standBbm}',
      'Tek. Oli': '${logsheet.tekananOli} bar',
      'Temp. Air': '${logsheet.temperaturAir} °C',
      'Phasa R': '${logsheet.phasaR} A',
      'Phasa S': '${logsheet.phasaS} A',
      'Phasa T': '${logsheet.phasaT} A',
      'Tegangan': '${logsheet.tegangan} V',
      'Cos Phi': '${logsheet.cosPhi}',
      'Frekuensi': '${logsheet.frequency} Hz',
    };

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: items.entries
          .map(
            (e) => SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSoft,
                    ),
                  ),
                  Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
