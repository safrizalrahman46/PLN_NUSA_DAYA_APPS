import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/network/network_info.dart';
import '../../core/widgets/glass_card.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.primaryDark,
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
                    // Aurora orb — top right
                    Positioned(
                      right: -60,
                      top: -40,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.auroraCyan.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Aurora orb — bottom left
                    Positioned(
                      left: -40,
                      bottom: -20,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.auroraViolet.withValues(alpha: 0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Profile content
                    Positioned.fill(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 82,
                                    height: 82,
                                    decoration: BoxDecoration(
                                      gradient: isDark
                                          ? AppColors.darkGradient
                                          : AppColors.heroGradient,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.40),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: GlassCard(
                                        padding: const EdgeInsets.all(10),
                                        borderRadius: 999,
                                        sigmaX: 12,
                                        sigmaY: 12,
                                        shadow: false,
                                        borderColor: Colors.white
                                            .withValues(alpha: 0.35),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.name ?? '-',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${user?.username ?? '-'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white
                                                    .withValues(alpha: 0.80),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Stats chips row
                              Row(
                                children: [
                                  _ProfileStatChip(
                                    label: 'Status',
                                    value: online ? 'Online' : 'Offline',
                                    valueColor: online
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: 10),
                                  _ProfileStatChip(
                                    label: 'Role',
                                    value: user?.role.label ?? '-',
                                  ),
                                  const SizedBox(width: 10),
                                  _ProfileStatChip(
                                    label: 'Unit',
                                    value: user?.isOperator == true
                                        ? 'Semua'
                                        : 'Terikat',
                                  ),
                                ],
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
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, bottomInset + 108),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info section
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Akun',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoItem(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: AppStrings.dummyEmail),
                          const _InfoItem(
                              icon: Icons.phone_outlined,
                              label: 'Telepon',
                              value: '0812-0000-1234'),
                          _InfoItem(
                              icon: Icons.tag_outlined,
                              label: 'Versi Aplikasi',
                              value: AppStrings.appVersion),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Menu section
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.edit_rounded,
                        iconColor: AppColors.primary,
                        title: 'Edit Profil',
                        subtitle: 'Perubahan profil (dummy)',
                        onTap: () =>
                            _snack(context, 'Edit profile dummy.'),
                      ),
                      _MenuDivider(),
                      _MenuItem(
                        icon: Icons.lock_reset_rounded,
                        iconColor: AppColors.accent,
                        title: 'Ubah Password',
                        subtitle:
                            'Ubah melalui admin/supervisor',
                        onTap: () =>
                            _snack(context, 'Change password dummy.'),
                      ),
                      _MenuDivider(),
                      _MenuItem(
                        icon: Icons.tune_rounded,
                        iconColor: AppColors.highlight,
                        title: 'Pengaturan',
                        subtitle: 'Tema, sinkronisasi, GPS, notifikasi',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.settings),
                      ),
                      if (canManageMaster) ...[
                        _MenuDivider(),
                        _MenuItem(
                          icon: Icons.dataset_rounded,
                          iconColor: AppColors.success,
                          title: 'Master Data',
                          subtitle:
                              'Kelola user, unit, mesin',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const AdminManagementPage(),
                              ),
                            );
                          },
                        ),
                      ],
                      if (canManageSystem) ...[
                        _MenuDivider(),
                        _MenuItem(
                          icon: Icons.admin_panel_settings_rounded,
                          iconColor: AppColors.warning,
                          title: 'Kontrol Sistem',
                          subtitle: 'Konfigurasi superadmin',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const SystemControlPage(),
                              ),
                            );
                          },
                        ),
                      ],
                      _MenuDivider(),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.danger,
                        title: 'Logout',
                        onTap: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }
}

class _ProfileStatChip extends StatelessWidget {
  const _ProfileStatChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 14,
      sigmaX: 8,
      sigmaY: 8,
      borderColor: Colors.white.withValues(alpha: 0.28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 16,
            color: isDark ? AppColors.accent : AppColors.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoft,
                    fontSize: 11,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(
                    alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSoft,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 20,
      color: Theme.of(context).dividerColor,
    );
  }
}
