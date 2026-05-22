import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/auth_controller.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.darkGradient
                      : AppColors.heroGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.auroraViolet.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Pengaturan',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 108),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Preferensi section
                _SectionLabel(label: 'Preferensi Aplikasi'),
                const SizedBox(height: 10),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: AppColors.auroraViolet,
                        title: 'Mode Gelap',
                        subtitle: 'Ubah tema tampilan aplikasi',
                        trailing: Switch(
                          value: settings.themeMode == ThemeMode.dark,
                          onChanged: (value) => ref
                              .read(appSettingsProvider.notifier)
                              .toggleTheme(value),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      const _Divider(),
                      _SettingsTile(
                        icon: Icons.sync_rounded,
                        iconColor: AppColors.success,
                        title: 'Sinkron Otomatis',
                        subtitle: 'Kirim data saat terhubung internet',
                        trailing: Switch(
                          value: settings.autoSync,
                          onChanged: (value) => ref
                              .read(appSettingsProvider.notifier)
                              .toggleAutoSync(value),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      const _Divider(),
                      _SettingsTile(
                        icon: Icons.gps_fixed_rounded,
                        iconColor: AppColors.accent,
                        title: 'GPS Akurasi Tinggi',
                        subtitle: 'Gunakan lebih banyak daya baterai',
                        trailing: Switch(
                          value: settings.gpsHighAccuracy,
                          onChanged: (value) => ref
                              .read(appSettingsProvider.notifier)
                              .toggleGpsHighAccuracy(value),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      const _Divider(),
                      _SettingsTile(
                        icon: Icons.notifications_rounded,
                        iconColor: AppColors.warning,
                        title: 'Notifikasi',
                        subtitle: 'Peringatan dan pengingat laporan',
                        trailing: Switch(
                          value: settings.notificationsEnabled,
                          onChanged: (value) => ref
                              .read(appSettingsProvider.notifier)
                              .toggleNotifications(value),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Umum section
                _SectionLabel(label: 'Umum'),
                const SizedBox(height: 10),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        iconColor: AppColors.highlight,
                        title: 'Bahasa',
                        subtitle: settings.language,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSoft,
                        ),
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            showDragHandle: true,
                            builder: (sheetContext) => SafeArea(
                              child: ListView(
                                shrinkWrap: true,
                                children: ['Indonesia', 'English']
                                    .map(
                                      (item) => ListTile(
                                        title: Text(item),
                                        trailing: settings.language == item
                                            ? const Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.success,
                                              )
                                            : null,
                                        onTap: () => Navigator.pop(sheetContext, item),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                          if (selected != null) {
                            await ref
                                .read(appSettingsProvider.notifier)
                                .setLanguage(selected);
                          }
                        },
                      ),
                      const _Divider(),
                      _SettingsTile(
                        icon: Icons.cleaning_services_rounded,
                        iconColor: AppColors.accent,
                        title: 'Clear Cache',
                        subtitle: 'Hapus data cache lokal',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSoft,
                        ),
                        onTap: () async {
                          await ref
                              .read(appSettingsProvider.notifier)
                              .clearCache();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cache berhasil dibersihkan'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Akun section
                _SectionLabel(label: 'Akun'),
                const SizedBox(height: 10),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: _SettingsTile(
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.danger,
                    title: 'Logout',
                    subtitle: 'Keluar dari akun ini',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSoft,
                    ),
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
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: Theme.of(context).dividerColor,
    );
  }
}
