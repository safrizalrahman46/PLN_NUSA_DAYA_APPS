import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/app_card.dart';
import '../auth/auth_controller.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppCard(
            gradient: AppColors.softSurfaceGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferensi Aplikasi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Atur pengalaman aplikasi untuk kebutuhan operasional harian.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (value) =>
                      ref.read(appSettingsProvider.notifier).toggleTheme(value),
                  title: const Text('Mode gelap'),
                ),
                SwitchListTile(
                  value: settings.autoSync,
                  onChanged: (value) => ref
                      .read(appSettingsProvider.notifier)
                      .toggleAutoSync(value),
                  title: const Text('Sinkron otomatis'),
                ),
                SwitchListTile(
                  value: settings.gpsHighAccuracy,
                  onChanged: (value) => ref
                      .read(appSettingsProvider.notifier)
                      .toggleGpsHighAccuracy(value),
                  title: const Text('GPS akurasi tinggi'),
                ),
                SwitchListTile(
                  value: settings.notificationsEnabled,
                  onChanged: (value) => ref
                      .read(appSettingsProvider.notifier)
                      .toggleNotifications(value),
                  title: const Text('Notifikasi'),
                ),
                const Divider(height: 20),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: const Text('Bahasa'),
                  subtitle: Text(settings.language),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_rounded),
                  title: const Text('Clear cache'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await ref.read(appSettingsProvider.notifier).clearCache();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache berhasil dibersihkan'),
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
}
