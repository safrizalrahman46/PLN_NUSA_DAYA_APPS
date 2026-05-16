import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';

class MonitoringFilterBar extends StatelessWidget {
  const MonitoringFilterBar({
    super.key,
    required this.onSearch,
    required this.selectedDateLabel,
    required this.selectedStatus,
    required this.selectedUnit,
    required this.availableUnits,
    required this.onPickDate,
    required this.onStatusChanged,
    required this.onUnitChanged,
  });

  final ValueChanged<String> onSearch;
  final String selectedDateLabel;
  final String selectedStatus;
  final String selectedUnit;
  final List<String> availableUnits;
  final VoidCallback onPickDate;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Monitoring', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Pantau operator berdasarkan unit, tanggal, dan status laporan.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Cari unit / operator',
            onChanged: onSearch,
            suffixIcon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            borderRadius: 16,
            sigmaX: 6,
            sigmaY: 6,
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tanggal monitoring: $selectedDateLabel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(onPressed: onPickDate, child: const Text('Ubah')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                        'Semua',
                        'submitted',
                        'pending',
                        'late',
                        'missing',
                        'abnormal',
                      ]
                      .map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _ChipFilter(
                            label: status,
                            selected: selectedStatus == status,
                            onTap: () {
                              onStatusChanged(status);
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: selectedUnit,
            decoration: const InputDecoration(labelText: 'Filter unit'),
            items: ['Semua Unit', ...availableUnits]
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onUnitChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ChipFilter extends StatelessWidget {
  const _ChipFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.14),
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.42)
            : AppColors.border,
      ),
      onSelected: (_) {
        onTap();
      },
    );
  }
}
