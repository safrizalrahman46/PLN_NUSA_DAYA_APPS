import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/logsheet_model.dart';
import '../../data/repositories/error_log_repository.dart';
import '../auth/auth_controller.dart';
import '../profile/settings_controller.dart';
import 'report_export_service.dart';

class ReportExportPage extends ConsumerWidget {
  const ReportExportPage({
    super.key,
    this.records = const <LogsheetModel>[],
    this.periodLabel = 'Harian',
    this.dateRangeLabel = '-',
    this.exportedBy = 'Supervisor',
    this.operatorFieldLabel = '',
  });

  final List<LogsheetModel> records;
  final String periodLabel;
  final String dateRangeLabel;
  final String exportedBy;
  final String operatorFieldLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final appSettings = ref.watch(appSettingsProvider);
    final service = ReportExportService();
    final payload = ReportExportPayload(
      records: records,
      periodLabel: periodLabel,
      exportedBy: user?.name ?? exportedBy,
      dateRangeLabel: dateRangeLabel,
      fileNameBase: _fileNameBase(periodLabel),
      operatorFieldLabel: operatorFieldLabel.isEmpty
          ? appSettings.operatorFieldLabel
          : operatorFieldLabel,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Download Laporan')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 108,
        ),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.file_download_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Download laporan $periodLabel',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${records.length} data • $dateRangeLabel',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ExportOption(
                  icon: Icons.picture_as_pdf_rounded,
                  color: AppColors.danger,
                  label: 'Download PDF',
                  subtitle: 'Format PDF siap cetak dengan logo PLN Nusa Daya',
                  onTap: records.isEmpty
                      ? null
                      : () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Menyiapkan file PDF...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          try {
                            await service.sharePdf(payload);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('File PDF berhasil dibuat!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (error, stackTrace) {
                            await ref.read(errorLogRepositoryProvider).logException(
                                  error: error,
                                  stackTrace: stackTrace,
                                  page: 'ReportExportPage.sharePdf',
                                  user: user,
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal export PDF: $error')),
                            );
                          }
                        },
                ),
                const SizedBox(height: 10),
                _ExportOption(
                  icon: Icons.table_chart_rounded,
                  color: AppColors.success,
                  label: 'Download Excel',
                  subtitle: 'Format spreadsheet (.xlsx) untuk analisis',
                  onTap: records.isEmpty
                      ? null
                      : () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Menyiapkan file Excel...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          try {
                            await service.shareExcel(payload);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('File Excel berhasil dibuat!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (error, stackTrace) {
                            await ref.read(errorLogRepositoryProvider).logException(
                                  error: error,
                                  stackTrace: stackTrace,
                                  page: 'ReportExportPage.shareExcel',
                                  user: user,
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal export Excel: $error')),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fileNameBase(String period) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    return 'Laporan_Logsheet_PLTD_$dateStr';
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 18,
      sigmaX: 6,
      sigmaY: 6,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: onTap == null ? AppColors.border : AppColors.textSoft,
            size: 20,
          ),
        ],
      ),
    );
  }
}
