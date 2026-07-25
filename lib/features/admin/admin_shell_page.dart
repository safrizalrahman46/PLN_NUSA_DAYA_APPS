import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/floating_pill_nav.dart';
import '../auth/auth_controller.dart';
import '../errors/error_log_page.dart';
import '../history/history_page.dart';
import '../logsheet/input_logsheet_page.dart';
import '../profile/profile_page.dart';
import '../reports/report_page.dart';
import '../supervisor/admin_management_page.dart';
import '../supervisor/logsheet_approval_page.dart';
import '../sync/pending_upload_page.dart';
import 'admin_dashboard_page.dart';

class AdminShellPage extends ConsumerStatefulWidget {
  const AdminShellPage({super.key});

  @override
  ConsumerState<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends ConsumerState<AdminShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final isSuperadmin = user?.isSuperadmin == true;

    // Superadmin mendapat semua tab termasuk logsheet
    final pages = isSuperadmin
        ? [
            AdminDashboardPage(user: user),
            const AdminManagementPage(),
            const HistoryPage(),
            const PendingUploadPage(),
            const ReportPage(),
            const ErrorLogPage(),
            const ProfilePage(),
          ]
        : [
            AdminDashboardPage(user: user),
            const AdminManagementPage(),
            const ReportPage(),
            const ErrorLogPage(),
            const ProfilePage(),
          ];

    final items = isSuperadmin
        ? const [
            FloatingPillNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
            FloatingPillNavItem(icon: Icons.dataset_rounded, label: 'Master'),
            FloatingPillNavItem(icon: Icons.history_rounded, label: 'Riwayat'),
            FloatingPillNavItem(icon: Icons.cloud_upload_rounded, label: 'Pending'),
            FloatingPillNavItem(icon: Icons.bar_chart_rounded, label: 'Laporan'),
            FloatingPillNavItem(icon: Icons.bug_report_rounded, label: 'Error'),
            FloatingPillNavItem(icon: Icons.person_rounded, label: 'Profil'),
          ]
        : const [
            FloatingPillNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
            FloatingPillNavItem(icon: Icons.dataset_rounded, label: 'Master'),
            FloatingPillNavItem(icon: Icons.bar_chart_rounded, label: 'Laporan'),
            FloatingPillNavItem(icon: Icons.bug_report_rounded, label: 'Error'),
            FloatingPillNavItem(icon: Icons.person_rounded, label: 'Profil'),
          ];

    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Ensure index is within range to prevent crashes during user/role changes
    final activeIndex = _index >= pages.length ? 0 : _index;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: pages[activeIndex]),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomInset + 16,
            child: FloatingPillNav(
              currentIndex: activeIndex,
              onTap: (value) => setState(() => _index = value),
              items: items,
            ),
          ),
          // Superadmin: tombol Input Logsheet
          if (isSuperadmin)
            Positioned(
              right: 20,
              bottom: bottomInset + 16 + 72 + 10,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const InputLogsheetPage(),
                  ),
                ),
                backgroundColor: AppColors.highlight,
                foregroundColor: AppColors.primaryDark,
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Input Logsheet'),
                heroTag: 'superadmin_input_logsheet',
              ),
            ),
          // Superadmin: tombol Approval shortcut
          if (isSuperadmin)
            Positioned(
              right: 20,
              bottom: bottomInset + 16 + 72 + 10 + 60,
              child: FloatingActionButton.small(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const LogsheetApprovalPage(),
                  ),
                ),
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                tooltip: 'Approval Logsheet',
                heroTag: 'superadmin_approval',
                child: const Icon(Icons.rate_review_rounded, size: 20),
              ),
            ),
          // Non-superadmin admin: Kelola Sistem shortcut
          if (!isSuperadmin)
            Positioned(
              right: 20,
              bottom: bottomInset + 16 + 72 + 10,
              child: FloatingActionButton.extended(
                onPressed: () => setState(() => _index = 1),
                backgroundColor: AppColors.highlight,
                foregroundColor: AppColors.primaryDark,
                icon: const Icon(Icons.admin_panel_settings_rounded),
                label: const Text('Kelola Sistem'),
                heroTag: 'admin_kelola_sistem',
              ),
            ),
        ],
      ),
    );
  }
}
