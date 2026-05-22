import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../errors/error_log_page.dart';
import '../profile/settings_controller.dart';
import 'admin_management_page.dart';

class SystemControlPage extends ConsumerWidget {
  const SystemControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kontrol Sistem')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
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
                        'Atur konfigurasi global yang memengaruhi form operator, sinkronisasi, dan master data pembangkit.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
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
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Konfigurasi Global',
                  subtitle:
                      'Khusus superadmin untuk kontrol sistem dan penyesuaian kebutuhan lapangan.',
                ),
                const SizedBox(height: 16),
                _SettingRow(
                  label: 'Base URL API',
                  value: AppConfig.baseUrl,
                  icon: Icons.link_rounded,
                ),
                _SettingRow(
                  label: 'Sinkronisasi otomatis',
                  value: settings.autoSync ? 'Aktif' : 'Nonaktif',
                  icon: Icons.sync_rounded,
                ),
                _SettingRow(
                  label: 'Akurasi GPS tinggi',
                  value: settings.gpsHighAccuracy ? 'Aktif' : 'Nonaktif',
                  icon: Icons.gps_fixed_rounded,
                ),
                _SettingRow(
                  label: 'Label field operator',
                  value: settings.operatorFieldLabel,
                  icon: Icons.badge_rounded,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: 'Ubah Label Form',
                      onPressed: () => _showOperatorFieldDialog(context, ref),
                      fullWidth: false,
                    ),
                    AppButton(
                      label: 'Kelola Mesin',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminManagementPage(),
                          ),
                        );
                      },
                      type: AppButtonType.outlined,
                      fullWidth: false,
                    ),
                    AppButton(
                      label: 'Audit Log',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const ErrorLogPage(),
                          ),
                        );
                      },
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
                          'Perubahan label form dan master mesin langsung berlaku untuk sesi berikutnya dan tetap tersimpan di perangkat.',
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

  Future<void> _showOperatorFieldDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final settings = ref.read(appSettingsProvider);
    final controller = TextEditingController(text: settings.operatorFieldLabel);

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Label Field Operator'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Label ini dipakai pada form input, detail laporan, dan file export PDF/Excel.',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller,
                label: 'Label baru',
                hint: 'Contoh: Nama Petugas Operator',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (value == null) return;
    await ref.read(appSettingsProvider.notifier).setOperatorFieldLabel(value);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Label field operator berhasil diperbarui.'),
      ),
    );
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 12,
        sigmaX: 6,
        sigmaY: 6,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 140, child: Text(label)),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
