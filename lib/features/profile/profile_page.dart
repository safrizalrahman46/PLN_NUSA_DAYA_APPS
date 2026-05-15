import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/network/network_info.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/app_enums.dart';
import '../auth/auth_controller.dart';
import '../supervisor/admin_management_page.dart';
import '../supervisor/system_control_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? true;
    final canManageMaster = user?.canManageMasterData == true;
    final canManageSystem = user?.canManageSystem == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkGradient
                : AppColors.heroGradient,
            borderColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white.withValues(alpha: 0.24),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '-',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user?.username ?? '-'} • ${user?.role.label ?? '-'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  user?.role.label ?? '-',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.isOperator == true
                      ? 'Dapat memilih semua unit PLTD'
                      : (user?.unitName ?? '-'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _InfoChip(label: 'Email', value: AppStrings.dummyEmail),
                    const _InfoChip(label: 'Telepon', value: '0812-0000-1234'),
                    _InfoChip(
                      label: 'Status Login',
                      value: online ? 'Aktif' : 'Offline',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.appVersion,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Edit profile'),
                  subtitle: const Text(
                    'Perubahan profil untuk tahap awal masih dummy',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _snack(context, 'Edit profile dummy.'),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset_rounded),
                  title: const Text('Change password'),
                  subtitle: const Text(
                    'Ubah password operator melalui admin/supervisor',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _snack(context, 'Change password dummy.'),
                ),
                ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: const Text('Settings'),
                  subtitle: const Text(
                    'Tema, sinkronisasi, GPS, dan notifikasi',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                ),
                if (canManageMaster)
                  ListTile(
                    leading: const Icon(Icons.dataset_rounded),
                    title: const Text('Master Data'),
                    subtitle: const Text(
                      'Kelola user, unit, dan serial number mesin',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AdminManagementPage(),
                        ),
                      );
                    },
                  ),
                if (canManageSystem)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_rounded),
                    title: const Text('Kontrol Sistem'),
                    subtitle: const Text(
                      'Konfigurasi global dan kontrol khusus superadmin',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SystemControlPage(),
                        ),
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                  ),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final onHero = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onHero
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: onHero
              ? Colors.white.withValues(alpha: 0.28)
              : Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: onHero ? Colors.white70 : AppColors.textSoft,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: onHero ? Colors.white : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
