import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/error_log_model.dart';
import '../../data/repositories/error_log_repository.dart';

final errorLogDetailProvider = FutureProvider.family<ErrorLogModel?, String>((
  ref,
  id,
) {
  return ref.read(errorLogRepositoryProvider).getById(id);
});

class ErrorLogDetailPage extends ConsumerWidget {
  const ErrorLogDetailPage({super.key, required this.errorLogId});

  final String errorLogId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(errorLogDetailProvider(errorLogId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Error')),
      body: detail.when(
        data: (item) {
          if (item == null) {
            return const AppEmptyState(
              title: 'Error tidak ditemukan',
              message: 'Item log error mungkin sudah dibersihkan dari penyimpanan lokal.',
              icon: Icons.error_outline_rounded,
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.errorType,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Waktu', value: item.createdAt.toString()),
                    _DetailRow(label: 'User', value: item.userName.isEmpty ? '-' : item.userName),
                    _DetailRow(label: 'Role', value: item.role.label),
                    _DetailRow(label: 'Halaman/Menu', value: item.page),
                    _DetailRow(label: 'Pesan', value: item.message),
                    _DetailRow(label: 'Detail', value: item.detail),
                    _DetailRow(label: 'Source', value: item.source),
                    if (item.stackTrace.isNotEmpty)
                      _DetailBlock(label: 'Stack Trace', value: item.stackTrace),
                    if (item.metadata.isNotEmpty)
                      _DetailBlock(label: 'Metadata', value: item.metadata.toString()),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await ref.read(errorLogRepositoryProvider).updateStatus(
                                  item.id,
                                  ErrorLogStatus.diproses,
                                );
                            ref.invalidate(errorLogDetailProvider(errorLogId));
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Tandai Diproses'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await ref.read(errorLogRepositoryProvider).updateStatus(
                                  item.id,
                                  ErrorLogStatus.selesai,
                                );
                            ref.invalidate(errorLogDetailProvider(errorLogId));
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Tandai Selesai'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: '${item.errorType}\n${item.message}\n${item.detail}\n${item.stackTrace}',
                              ),
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
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (error, _) => AppEmptyState(
          title: 'Gagal memuat detail error',
          message: error.toString(),
          icon: Icons.error_outline_rounded,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoft,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }
}
