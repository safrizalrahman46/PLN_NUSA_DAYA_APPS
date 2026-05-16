import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/dummy/dummy_data.dart';

class HeatmapStatusTable extends StatelessWidget {
  const HeatmapStatusTable({
    super.key,
    required this.heatmap,
    required this.dateLabel,
    required this.lastUpdatedLabel,
  });

  final Map<String, Map<String, String>> heatmap;
  final String dateLabel;
  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final slots = DateHelper.reportSlots();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Heatmap Status Laporan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tanggal: $dateLabel',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Auto refresh: $lastUpdatedLabel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.grid_view_rounded),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _LegendChip(label: 'Sudah submit', color: Colors.green),
              _LegendChip(label: 'Belum submit', color: Colors.red),
              _LegendChip(label: 'Warning / telat', color: Colors.orange),
              _LegendChip(label: 'Inactive', color: Colors.grey),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                AppColors.primary.withValues(alpha: 0.08),
              ),
              columns: [
                const DataColumn(label: Text('Unit')),
                ...slots.map((slot) => DataColumn(label: Text(slot))),
              ],
              rows: DummyData.units.map((unit) {
                return DataRow(
                  cells: [
                    DataCell(Text(unit.name)),
                    ...slots.map((slot) {
                      final value = heatmap[unit.id]?[slot] ?? 'inactive';
                      return DataCell(
                        GestureDetector(
                          onTap: () =>
                              _showCell(context, unit.name, slot, value),
                          child: Tooltip(
                            message: '${unit.name} • $slot • $value',
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _colorOf(value),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorOf(String value) {
    switch (value) {
      case 'submitted':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'missing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCell(BuildContext context, String unit, String slot, String value) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$unit • $slot'),
        content: Text('Status sel: $value'),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
