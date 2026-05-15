import 'package:flutter/material.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';

class ReportExportPage extends StatelessWidget {
  const ReportExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Laporan')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih format export',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fitur export masih berupa dummy action untuk tahap awal integrasi.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: 'Export PDF',
                  onPressed: () =>
                      _showInfo(context, 'Export PDF dummy dijalankan.'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Export Excel',
                  onPressed: () =>
                      _showInfo(context, 'Export Excel dummy dijalankan.'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Print',
                  onPressed: () =>
                      _showInfo(context, 'Print dummy dijalankan.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
