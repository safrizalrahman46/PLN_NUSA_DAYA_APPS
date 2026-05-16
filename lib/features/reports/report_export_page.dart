import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';

class ReportExportPage extends StatelessWidget {
  const ReportExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Laporan')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).padding.bottom + 108),
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
                            'Pilih format export',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Dummy action untuk tahap awal integrasi.',
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
                  label: 'Export PDF',
                  subtitle: 'Format PDF siap cetak',
                  onTap: () => _showInfo(context, 'Export PDF dummy dijalankan.'),
                ),
                const SizedBox(height: 10),
                _ExportOption(
                  icon: Icons.table_chart_rounded,
                  color: AppColors.success,
                  label: 'Export Excel',
                  subtitle: 'Format spreadsheet (.xlsx)',
                  onTap: () =>
                      _showInfo(context, 'Export Excel dummy dijalankan.'),
                ),
                const SizedBox(height: 10),
                _ExportOption(
                  icon: Icons.print_rounded,
                  color: AppColors.accent,
                  label: 'Print Langsung',
                  subtitle: 'Cetak via printer terhubung',
                  onTap: () => _showInfo(context, 'Print dummy dijalankan.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
  final VoidCallback onTap;

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
            color: AppColors.textSoft,
            size: 20,
          ),
        ],
      ),
    );
  }
}
