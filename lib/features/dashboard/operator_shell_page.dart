import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

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

    return Scaffold(
      body: _pages[_index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openInput,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Input Logsheet'),
        backgroundColor: AppColors.highlight,
        foregroundColor: AppColors.primaryDark,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_upload_rounded),
            label: 'Pending',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
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
