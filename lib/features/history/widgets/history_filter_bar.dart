import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';

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

  bool get _hasDateFilter => selectedDateLabel != 'Semua tanggal';
  bool get _hasSyncFilter => selectedSync != 'Semua';
  bool get _hasOtherFilter =>
      selectedLocation != 'Semua' || selectedUnit != 'Semua Unit';
  int get _otherFilterCount =>
      (selectedLocation != 'Semua' ? 1 : 0) +
      (selectedUnit != 'Semua Unit' ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Cari proof ID / unit / serial number',
            onChanged: onSearchChanged,
            suffixIcon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _FilterPill(
                label: _hasDateFilter ? selectedDateLabel : 'Semua tanggal',
                icon: Icons.calendar_month_rounded,
                active: _hasDateFilter,
                onTap: onPickDate,
              ),
              const SizedBox(width: 8),
              _FilterPill(
                label: _hasSyncFilter ? selectedSync : 'Semua status',
                icon: Icons.sync_rounded,
                active: _hasSyncFilter,
                onTap: () => _showSyncSheet(context),
              ),
              const SizedBox(width: 8),
              _FilterPill(
                label: _hasOtherFilter
                    ? '$_otherFilterCount filter aktif'
                    : 'Filter lain',
                icon: Icons.tune_rounded,
                active: _hasOtherFilter,
                onTap: () => _showOtherSheet(context),
                trailingArrow: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSyncSheet(BuildContext context) {
    const options = ['Semua', 'Tersinkron', 'Pending', 'Gagal', 'Draft'];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        title: 'Status Sinkronisasi',
        sections: [
          _FilterSection(
            title: 'Status Sinkronisasi',
            options: options,
            selected: selectedSync,
            onChanged: (v) {
              onSyncChanged(v);
              Navigator.pop(context);
            },
          ),
        ],
        onReset: () {
          onSyncChanged('Semua');
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOtherSheet(BuildContext context) {
    const locationOptions = [
      'Semua',
      'Valid',
      'Di luar area',
      'GPS mati',
      'Izin ditolak',
    ];
    final unitOptions = ['Semua Unit', ...units];

    String tempLocation = selectedLocation;
    String tempUnit = selectedUnit;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (_, setSheetState) => _FilterSheet(
          title: 'Filter Lainnya',
          sections: [
            _FilterSection(
              title: 'Status Lokasi',
              options: locationOptions,
              selected: tempLocation,
              onChanged: (v) => setSheetState(() => tempLocation = v),
            ),
            _FilterSection(
              title: 'Pilih Unit',
              options: unitOptions,
              selected: tempUnit,
              onChanged: (v) => setSheetState(() => tempUnit = v),
            ),
          ],
          onApply: () {
            onLocationChanged(tempLocation);
            onUnitChanged(tempUnit);
            Navigator.pop(sheetContext);
          },
          onReset: () {
            onLocationChanged('Semua');
            onUnitChanged('Semua Unit');
            Navigator.pop(sheetContext);
          },
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.trailingArrow = false,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = active ? AppColors.primary : AppColors.textSoft;

    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
              ),
              if (trailingArrow) ...[
                const SizedBox(width: 3),
                Icon(Icons.expand_more_rounded, size: 14, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.title,
    required this.sections,
    required this.onReset,
    this.onApply,
  });

  final String title;
  final List<_FilterSection> sections;
  final VoidCallback onReset;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2332) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                children: [
                  for (final section in sections) ...[
                    SectionTitle(title: section.title),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: section.options.map((option) {
                        final selected = option == section.selected;
                        return ChoiceChip(
                          label: Text(option),
                          selected: selected,
                          backgroundColor: Colors.transparent,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.14),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.50)
                                : AppColors.border,
                          ),
                          onSelected: (_) => section.onChanged(option),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
              child: OverflowBar(
                spacing: 12,
                children: [
                  TextButton(
                    onPressed: onReset,
                    child: const Text('Reset Filter'),
                  ),
                  if (onApply != null)
                    FilledButton(
                      onPressed: onApply,
                      child: const Text('Terapkan'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
