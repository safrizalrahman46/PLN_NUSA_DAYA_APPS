import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.selectedDateLabel,
    required this.selectedSync,
    required this.selectedLocation,
    required this.selectedUnit,
    required this.units,
    required this.onPickDate,
    required this.onSyncChanged,
    required this.onLocationChanged,
    required this.onUnitChanged,
  });

  final ValueChanged<String> onSearchChanged;
  final String selectedDateLabel;
  final String selectedSync;
  final String selectedLocation;
  final String selectedUnit;
  final List<String> units;
  final VoidCallback onPickDate;
  final ValueChanged<String> onSyncChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.softSurfaceGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Riwayat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Cari data logsheet berdasarkan waktu, unit, dan status.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Cari proof ID / unit / serial number',
            onChanged: onSearchChanged,
            suffixIcon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Filter tanggal: $selectedDateLabel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: onPickDate,
                  child: const Text('Ubah'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FilterWrap(
            title: 'Status sync',
            options: const ['Semua', 'Tersinkron', 'Pending', 'Gagal', 'Draft'],
            selected: selectedSync,
            onSelected: onSyncChanged,
          ),
          const SizedBox(height: 10),
          _FilterWrap(
            title: 'Status lokasi',
            options: const [
              'Semua',
              'Valid',
              'Di luar area',
              'GPS mati',
              'Izin ditolak',
            ],
            selected: selectedLocation,
            onSelected: onLocationChanged,
          ),
          const SizedBox(height: 10),
          _FilterWrap(
            title: 'Unit',
            options: ['Semua Unit', ...units],
            selected: selectedUnit,
            onSelected: onUnitChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterWrap extends StatelessWidget {
  const _FilterWrap({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(option),
                      selected: option == selected,
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary.withValues(alpha: 0.14),
                      side: BorderSide(
                        color: option == selected
                            ? AppColors.primary.withValues(alpha: 0.42)
                            : AppColors.border,
                      ),
                      onSelected: (_) {
                        onSelected(option);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
