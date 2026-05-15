import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_title.dart';

class SystemControlPage extends StatelessWidget {
  const SystemControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontrol Sistem')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkGradient
                : AppColors.heroGradient,
            borderColor: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Governance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kontrol konfigurasi global, hak akses, dan integrasi pusat.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.settings_suggest_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            gradient: AppColors.softSurfaceGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Konfigurasi Global',
                  subtitle:
                      'Khusus superadmin untuk kontrol sistem dan integrasi pusat.',
                ),
                const SizedBox(height: 16),
                const _SettingRow(
                  label: 'Mode sistem',
                  value: 'Produksi (dummy)',
                  icon: Icons.radio_button_checked_rounded,
                ),
                const _SettingRow(
                  label: 'Base URL API',
                  value: 'http://10.0.2.2:8000/api',
                  icon: Icons.link_rounded,
                ),
                const _SettingRow(
                  label: 'Sinkronisasi otomatis',
                  value: 'Aktif',
                  icon: Icons.sync_rounded,
                ),
                const _SettingRow(
                  label: 'Monitoring region',
                  value: 'Kalimantan Timur',
                  icon: Icons.public_rounded,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: 'Kelola Role',
                      onPressed: () =>
                          _snack(context, 'Kelola role dummy dijalankan.'),
                      fullWidth: false,
                    ),
                    AppButton(
                      label: 'Konfigurasi API',
                      onPressed: () =>
                          _snack(context, 'Konfigurasi API dummy dijalankan.'),
                      type: AppButtonType.outlined,
                      fullWidth: false,
                    ),
                    AppButton(
                      label: 'Audit Log',
                      onPressed: () =>
                          _snack(context, 'Audit log dummy dijalankan.'),
                      type: AppButtonType.tonal,
                      fullWidth: false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.highlight.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.highlight.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.policy_rounded,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Perubahan konfigurasi bersifat audit-tracked dan membutuhkan validasi berlapis.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 380;

    if (narrow) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
