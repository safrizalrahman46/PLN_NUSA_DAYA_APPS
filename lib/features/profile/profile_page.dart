import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/network/network_info.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/user_model.dart';
import '../auth/auth_controller.dart';
import '../admin/retention_settings_page.dart';
import '../errors/error_log_page.dart';
import '../notifications/notification_page.dart';
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
            expandedHeight: 340,
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
                    // Aurora orb — top right
                    Positioned(
                      right: -60,
                      top: -40,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.auroraCyan.withValues(alpha: 0.28),
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
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.auroraViolet.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Aurora orb — center
                    Positioned(
                      right: 80,
                      bottom: 60,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.auroraBlue.withValues(alpha: 0.16),
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
                              // Avatar + name row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _AvatarWidget(isDark: isDark),
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
                                          '@${user?.username ?? '-'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.75,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _ProfileChip(
                                              label: online
                                                  ? 'Online'
                                                  : 'Offline',
                                              color: online
                                                  ? AppColors.success
                                                  : AppColors.warning,
                                              icon: online
                                                  ? Icons.wifi_rounded
                                                  : Icons.wifi_off_rounded,
                                            ),
                                            const SizedBox(width: 8),
                                            _ProfileChip(
                                              label: user?.role.label ?? 'User',
                                              color: AppColors.accent,
                                              icon: Icons.badge_rounded,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Stats row
                              GlassCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                borderRadius: 20,
                                sigmaX: 10,
                                sigmaY: 10,
                                borderColor: Colors.white.withValues(
                                  alpha: 0.22,
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      _StatItem(
                                        value: '128',
                                        label: 'Laporan',
                                        color: AppColors.accent,
                                      ),
                                      _StatDivider(),
                                      _StatItem(
                                        value: '24',
                                        label: 'Hari Aktif',
                                        color: AppColors.success,
                                      ),
                                      _StatDivider(),
                                      _StatItem(
                                        value: '96%',
                                        label: 'Sinkronisasi',
                                        color: AppColors.highlight,
                                      ),
                                    ],
                                  ),
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
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 108),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info section
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: isDark ? 0.22 : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.accent
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Informasi Akun',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: AppStrings.dummyEmail,
                        color: AppColors.primary,
                      ),
                      _InfoRowDivider(),
                      const _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Telepon',
                        value: '0812-0000-1234',
                        color: AppColors.success,
                      ),
                      _InfoRowDivider(),
                      _InfoRow(
                        icon: Icons.tag_outlined,
                        label: 'Versi Aplikasi',
                        value: AppStrings.appVersion,
                        color: AppColors.highlight,
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
                        subtitle: 'Ubah nama tampilan dan unit default',
                        onTap: () => _showEditProfileDialog(context, ref, user),
                      ),
                      _MenuDivider(),
                      _MenuItem(
                        icon: Icons.lock_reset_rounded,
                        iconColor: AppColors.accent,
                        title: 'Ubah Password',
                        subtitle: 'Catat permintaan perubahan password',
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      _MenuDivider(),
                      _MenuItem(
                        icon: Icons.notifications_active_rounded,
                        iconColor: AppColors.warning,
                        title: 'Notifikasi',
                        subtitle: 'Buka pusat notifikasi dan tindak lanjut',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const NotificationPage(),
                            ),
                          );
                        },
                      ),
                      _MenuDivider(),
                      _MenuItem(
                        icon: Icons.tune_rounded,
                        iconColor: AppColors.highlight,
                        title: 'Pengaturan',
                        subtitle: 'Tema, sinkronisasi, GPS, notifikasi',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                      if (user?.isSupervisor == true ||
                          user?.isAdmin == true ||
                          user?.isSuperadmin == true) ...[
                        _MenuDivider(),
                        _MenuItem(
                          icon: Icons.bug_report_rounded,
                          iconColor: AppColors.danger,
                          title: 'Log Error',
                          subtitle: 'Lihat error lengkap dan detail stack trace',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ErrorLogPage(),
                              ),
                            );
                          },
                        ),
                      ],
                      if (user?.isSupervisor == true ||
                          user?.isAdmin == true ||
                          user?.isSuperadmin == true) ...[
                        _MenuDivider(),
                        _MenuItem(
                          icon: Icons.archive_rounded,
                          iconColor: AppColors.success,
                          title: 'Retensi Data',
                          subtitle: 'Arsip data 5 tahun dan histori pembersihan',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const RetentionSettingsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                      if (canManageMaster) ...[
                        _MenuDivider(),
                        _MenuItem(
                          icon: Icons.dataset_rounded,
                          iconColor: AppColors.success,
                          title: 'Master Data',
                          subtitle: 'Kelola user, unit, mesin',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const AdminManagementPage(),
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
                                builder: (_) => const SystemControlPage(),
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
                        subtitle: 'Keluar dari sesi saat ini',
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Konfirmasi Logout'),
                              content: const Text(
                                'Apakah Anda yakin ingin keluar? Data offline yang belum tersinkronisasi akan tetap tersimpan di perangkat.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
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

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
  ) async {
    if (user == null) return;
    final nameController = TextEditingController(text: user.name);
    final unitController = TextEditingController(text: user.unitName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama tampil'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Unit default'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    await ref.read(authControllerProvider.notifier).updateUser(
          user.copyWith(
            name: nameController.text.trim().isEmpty
                ? user.name
                : nameController.text.trim(),
            unitName: unitController.text.trim().isEmpty
                ? user.unitName
                : unitController.text.trim(),
          ),
        );
    if (!context.mounted) return;
    _snack(context, 'Profil berhasil diperbarui secara lokal.');
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password lama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password baru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    _snack(
      context,
      'Permintaan perubahan password dicatat. Demi keamanan, perubahan final tetap diverifikasi oleh sistem.',
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

// ── Avatar ──────────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isDark ? AppColors.darkGradient : AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDark ? AppColors.darkGradient : AppColors.heroGradient,
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 38,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Profile chip ─────────────────────────────────────────────────────────────

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      borderRadius: 999,
      sigmaX: 8,
      sigmaY: 8,
      borderColor: color.withValues(alpha: 0.35),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.20),
    );
  }
}

// ── Info rows ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.22 : 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoft,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52,
      endIndent: 0,
      color: Theme.of(context).dividerColor,
    );
  }
}

// ── Menu items ────────────────────────────────────────────────────────────────

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 21),
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
      indent: 76,
      endIndent: 20,
      color: Theme.of(context).dividerColor,
    );
  }
}
