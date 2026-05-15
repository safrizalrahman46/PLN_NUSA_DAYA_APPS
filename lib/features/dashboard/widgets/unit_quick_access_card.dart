import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
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
    final quickUnits = units.take(8).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akses Cepat Unit',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih unit yang akan diinput. Operator bisa melihat semua unit PLTD.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickUnits
                .map(
                  (unit) => ChoiceChip(
                    label: Text(unit.name.replaceFirst('PLTD ', '')),
                    selected: lastSelectedUnitId == unit.id,
                    onSelected: (_) {
                      onPickUnit(unit);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showAllUnits(context),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Lihat semua unit'),
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
              Text(
                'Semua Unit PLTD',
                style: Theme.of(context).textTheme.titleLarge,
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
                      title: Text(unit.name),
                      subtitle: Text(unit.locationName),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            )
                          : null,
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
