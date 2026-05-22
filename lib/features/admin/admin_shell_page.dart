import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/floating_pill_nav.dart';
import '../auth/auth_controller.dart';
import '../errors/error_log_page.dart';
import '../profile/profile_page.dart';
import '../reports/report_page.dart';
import '../supervisor/admin_management_page.dart';
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
    final pages = [
      AdminDashboardPage(user: user),
      const AdminManagementPage(),
      const ReportPage(),
      const ErrorLogPage(),
      const ProfilePage(),
    ];

    final items = const [
      FloatingPillNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      FloatingPillNavItem(icon: Icons.dataset_rounded, label: 'Master'),
      FloatingPillNavItem(icon: Icons.bar_chart_rounded, label: 'Laporan'),
      FloatingPillNavItem(icon: Icons.bug_report_rounded, label: 'Error'),
      FloatingPillNavItem(icon: Icons.person_rounded, label: 'Profil'),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: pages[_index]),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomInset + 16,
            child: FloatingPillNav(
              currentIndex: _index,
              onTap: (value) => setState(() => _index = value),
              items: items,
            ),
          ),
          if (user?.isSuperadmin == true)
            Positioned(
              right: 20,
              bottom: bottomInset + 16 + 72 + 10,
              child: FloatingActionButton.extended(
                onPressed: () => setState(() => _index = 1),
                backgroundColor: AppColors.highlight,
                foregroundColor: AppColors.primaryDark,
                icon: const Icon(Icons.admin_panel_settings_rounded),
                label: const Text('Kelola Sistem'),
              ),
            ),
        ],
      ),
    );
  }
}
