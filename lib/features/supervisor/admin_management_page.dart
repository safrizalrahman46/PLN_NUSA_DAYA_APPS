import 'package:flutter/material.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_title.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_enums.dart';

class AdminManagementPage extends StatelessWidget {
  const AdminManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Master Data'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Operator'),
              Tab(text: 'Unit'),
              Tab(text: 'Mesin'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SectionList(
              title: 'Manajemen Operator',
              subtitle:
                  'Kelola akun operator, supervisor, admin, dan superadmin.',
              buttonLabel: 'Tambah User',
              items: DummyData.users
                  .map((item) => '${item.name} • ${item.role.label}')
                  .toList(),
            ),
            _SectionList(
              title: 'Master Unit PLTD',
              subtitle:
                  'Daftar unit aktif yang digunakan dalam pelaporan lapangan.',
              buttonLabel: 'Tambah Unit',
              items: DummyData.units
                  .map((item) => '${item.name} • ${item.locationName}')
                  .toList(),
            ),
            _SectionList(
              title: 'Master Serial Number Mesin',
              subtitle:
                  'Kelola mesin per unit sesuai serial number aktif di lokasi.',
              buttonLabel: 'Tambah Mesin',
              items: DummyData.machines
                  .map((item) => '${item.serialNumber} • ${item.capacity}')
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.items,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: title, subtitle: subtitle),
              const SizedBox(height: 16),
              AppButton(
                label: buttonLabel,
                onPressed: () =>
                    _snack(context, '$buttonLabel dummy dijalankan.'),
                fullWidth: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item),
                subtitle: const Text(
                  'Edit / nonaktifkan / sinkronkan master data',
                ),
                trailing: IconButton(
                  onPressed: () =>
                      _snack(context, 'Fitur edit master data dummy.'),
                  icon: const Icon(Icons.edit_rounded),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
