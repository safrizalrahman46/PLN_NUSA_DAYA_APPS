import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../data/models/unit_model.dart';

class UnitQuickAccessCard extends StatelessWidget {
  const UnitQuickAccessCard({
    super.key,
    required this.units,
    required this.lastSelectedUnitId,
    required this.onPickUnit,
  });

  final List<UnitModel> units;
  final String? lastSelectedUnitId;
  final ValueChanged<UnitModel> onPickUnit;

  @override
  Widget build(BuildContext context) {
    final quickUnits = units.take(6).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Akses Cepat Unit',
            subtitle: 'Ketuk kartu unit untuk melihat detail atau mulai input laporan',
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width >= 500 ? 3 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemCount: quickUnits.length,
            itemBuilder: (context, index) {
              final unit = quickUnits[index];
              final isSelected = unit.id == lastSelectedUnitId;
              return _UnitMiniCard(
                unit: unit,
                isSelected: isSelected,
                onTap: () => onPickUnit(unit),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showAllUnits(context),
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            label: Text('Lihat semua ${units.length} unit'),
          ),
        ],
      ),
    );
  }

  void _showAllUnits(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AllUnitsSheet(
        units: units,
        lastSelectedUnitId: lastSelectedUnitId,
        onPickUnit: onPickUnit,
      ),
    );
  }
}

class _UnitMiniCard extends StatelessWidget {
  const _UnitMiniCard({
    required this.unit,
    required this.isSelected,
    required this.onTap,
  });

  final UnitModel unit;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.06),
                      AppColors.accent.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.0)
                  : AppColors.border,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.20)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.electrical_services_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Aktif',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                unit.name.replaceFirst('PLTD ', ''),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.text,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                unit.locationName.isEmpty ? 'PLTD' : unit.locationName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.80)
                      : AppColors.textSoft,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllUnitsSheet extends StatefulWidget {
  const _AllUnitsSheet({
    required this.units,
    required this.lastSelectedUnitId,
    required this.onPickUnit,
  });

  final List<UnitModel> units;
  final String? lastSelectedUnitId;
  final ValueChanged<UnitModel> onPickUnit;

  @override
  State<_AllUnitsSheet> createState() => _AllUnitsSheetState();
}

class _AllUnitsSheetState extends State<_AllUnitsSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.units.where((unit) {
      final query = _query.toLowerCase();
      return query.isEmpty ||
          unit.name.toLowerCase().contains(query) ||
          unit.locationName.toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 4,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Semua Unit PLTD',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${widget.units.length} unit',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Cari unit atau lokasi',
                onChanged: (value) => setState(() => _query = value),
                suffixIcon: const Icon(Icons.search_rounded),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final unit = filtered[index];
                    final isSelected = unit.id == widget.lastSelectedUnitId;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        widget.onPickUnit(unit);
                        Navigator.pop(context);
                      },
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                )
                              : LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.10),
                                    AppColors.accent.withValues(alpha: 0.06),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.electrical_services_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        unit.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      subtitle: unit.locationName.isNotEmpty
                          ? Text(unit.locationName)
                          : null,
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSoft,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
