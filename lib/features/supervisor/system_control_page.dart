import 'package:flutter/material.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_title.dart';

class SystemControlPage extends StatelessWidget {
  const SystemControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontrol Sistem')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Konfigurasi Global',
                  subtitle:
                      'Khusus superadmin untuk kontrol sistem dan integrasi pusat.',
                ),
                const SizedBox(height: 16),
                const _SettingRow(
                  label: 'Mode sistem',
                  value: 'Produksi (dummy)',
                ),
                const _SettingRow(
                  label: 'Base URL API',
                  value: 'http://10.0.2.2:8000/api',
                ),
                const _SettingRow(
                  label: 'Sinkronisasi otomatis',
                  value: 'Aktif',
                ),
                const _SettingRow(
                  label: 'Monitoring region',
                  value: 'Kalimantan Timur',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: 'Kelola Role',
                      onPressed: () =>
                          _snack(context, 'Kelola role dummy dijalankan.'),
                      fullWidth: false,
                    ),
                    AppButton(
                      label: 'Konfigurasi API',
                      onPressed: () =>
                          _snack(context, 'Konfigurasi API dummy dijalankan.'),
                      type: AppButtonType.outlined,
                      fullWidth: false,
                    ),
                    AppButton(
                      label: 'Audit Log',
                      onPressed: () =>
                          _snack(context, 'Audit log dummy dijalankan.'),
                      type: AppButtonType.tonal,
                      fullWidth: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label)),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
