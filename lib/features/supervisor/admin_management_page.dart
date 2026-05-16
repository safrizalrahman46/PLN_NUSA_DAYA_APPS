import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
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
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSoft,
            tabs: [
              const Tab(text: 'Operator'),
              const Tab(text: 'Unit'),
              const Tab(text: 'Mesin'),
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
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: title, subtitle: subtitle),
              const SizedBox(height: 16),
              Row(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    borderRadius: 999,
                    sigmaX: 6,
                    sigmaY: 6,
                    child: Text(
                      'Total ${items.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: buttonLabel,
                    onPressed: () =>
                        _snack(context, '$buttonLabel dummy dijalankan.'),
                    fullWidth: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (entry.key + 1).toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Edit / nonaktifkan / sinkronkan',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSoft,
                              ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _snack(context, 'Fitur edit master data dummy.'),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
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
