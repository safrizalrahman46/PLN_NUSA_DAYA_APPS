import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/floating_pill_nav.dart';
import '../../data/models/app_enums.dart';
import '../auth/auth_controller.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/report_page.dart';
import 'operator_monitoring_page.dart';
import 'supervisor_dashboard_page.dart';

class SupervisorShellPage extends ConsumerStatefulWidget {
  const SupervisorShellPage({super.key});

  @override
  ConsumerState<SupervisorShellPage> createState() =>
      _SupervisorShellPageState();
}

class _SupervisorShellPageState extends ConsumerState<SupervisorShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;
    final user = ref.watch(authControllerProvider).user;

    final items = <_ShellItem>[
      const _ShellItem(
        label: 'Dashboard',
        icon: Icons.dashboard_rounded,
        page: SupervisorDashboardPage(),
      ),
      const _ShellItem(
        label: 'Monitoring',
        icon: Icons.monitor_heart_rounded,
        page: OperatorMonitoringPage(),
      ),
      const _ShellItem(
        label: 'Laporan',
        icon: Icons.bar_chart_rounded,
        page: ReportPage(),
      ),
      const _ShellItem(
        label: 'Notifikasi',
        icon: Icons.notifications_rounded,
        page: NotificationPage(),
      ),
      const _ShellItem(
        label: 'Profil',
        icon: Icons.person_rounded,
        page: ProfilePage(),
      ),
    ];

    final safeIndex = _index >= items.length ? items.length - 1 : _index;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: safeIndex,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).colorScheme.surface,
              indicatorColor: AppColors.primary.withValues(alpha: 0.16),
              leading: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  user?.role.label ?? 'Monitoring',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              destinations: items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(safeIndex),
                  child: items[safeIndex].page,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Main animated page content
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(safeIndex),
                child: items[safeIndex].page,
              ),
            ),
          ),
          // Floating pill navigation
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomInset + 16,
            child: FloatingPillNav(
              currentIndex: safeIndex,
              onTap: (value) => setState(() => _index = value),
              items: items
                  .map((item) => FloatingPillNavItem(
                        icon: item.icon,
                        label: item.label,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellItem {
  const _ShellItem({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Widget page;
}
