import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';

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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Cari unit / operator',
            onChanged: onSearch,
            suffixIcon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_rounded),
            title: Text('Tanggal monitoring: $selectedDateLabel'),
            trailing: TextButton(
              onPressed: onPickDate,
              child: const Text('Ubah'),
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
      onSelected: (_) {
        onTap();
      },
    );
  }
}
