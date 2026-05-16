import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/floating_pill_nav.dart';

import '../history/history_page.dart';
import '../logsheet/input_logsheet_page.dart';
import '../profile/profile_page.dart';
import '../sync/pending_upload_page.dart';
import 'operator_dashboard_page.dart';

class OperatorShellPage extends StatefulWidget {
  const OperatorShellPage({super.key});

  @override
  State<OperatorShellPage> createState() => _OperatorShellPageState();
}

class _OperatorShellPageState extends State<OperatorShellPage> {
  int _index = 0;

  final _pages = const [
    OperatorDashboardPage(),
    HistoryPage(),
    PendingUploadPage(),
    ProfilePage(),
  ];

  static const _navItems = [
    FloatingPillNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Dashboard',
    ),
    FloatingPillNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'Riwayat',
    ),
    FloatingPillNavItem(
      icon: Icons.cloud_upload_outlined,
      activeIcon: Icons.cloud_upload_rounded,
      label: 'Pending',
    ),
    FloatingPillNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FloatingActionButton.extended(
                  onPressed: _openInput,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Input'),
                  backgroundColor: AppColors.highlight,
                  foregroundColor: AppColors.primaryDark,
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_rounded),
                  label: Text('Riwayat'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.cloud_upload_rounded),
                  label: Text('Pending'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_rounded),
                  label: Text('Profil'),
                ),
              ],
            ),
            Expanded(child: _pages[_index]),
          ],
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Main page content
          Positioned.fill(
            child: _pages[_index],
          ),
          // Floating pill navigation
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomInset + 16,
            child: FloatingPillNav(
              currentIndex: _index,
              onTap: (value) => setState(() => _index = value),
              items: _navItems,
            ),
          ),
          // Input Logsheet FAB
          Positioned(
            bottom: bottomInset + 16 + 68 + 10,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _openInput,
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text(
                'Input',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              backgroundColor: AppColors.highlight,
              foregroundColor: AppColors.primaryDark,
              elevation: 4,
              extendedPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
          ),
        ],
      ),
    );
  }

  void _openInput() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const InputLogsheetPage()),
    );
  }
}
