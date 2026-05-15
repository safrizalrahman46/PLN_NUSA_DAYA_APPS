import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_info.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_picker_field.dart';
import '../../../core/widgets/section_title.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/models/unit_model.dart';

class MachineSelectorCard extends ConsumerWidget {
  const MachineSelectorCard({
    super.key,
    required this.operatorName,
    required this.selectedUnit,
    required this.selectedMachine,
    required this.units,
    required this.machines,
    required this.onUnitChanged,
    required this.onMachineChanged,
  });

  final String operatorName;
  final UnitModel? selectedUnit;
  final MachineModel? selectedMachine;
  final List<UnitModel> units;
  final AsyncValue<List<MachineModel>> machines;
  final ValueChanged<UnitModel?> onUnitChanged;
  final ValueChanged<MachineModel?> onMachineChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(networkStatusProvider).valueOrNull ?? true;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Informasi Unit',
            subtitle:
                'Pilih unit secara manual lalu pilih serial number mesin yang akan diinput',
          ),
          const SizedBox(height: 16),
          AppPickerField<UnitModel>(
            value: selectedUnit,
            label: 'Unit PLTD',
            hint: 'Pilih unit PLTD',
            options: units
                .map(
                  (item) => PickerOption<UnitModel>(
                    value: item,
                    label: item.name,
                    subtitle: item.locationName,
                  ),
                )
                .toList(),
            onSelected: (value) => onUnitChanged(value),
            searchHint: 'Cari unit atau lokasi',
          ),
          const SizedBox(height: 12),
          machines.when(
            data: (items) => AppPickerField<MachineModel>(
              value: selectedMachine,
              label: 'Serial Number Mesin',
              hint: items.isEmpty
                  ? 'Belum ada mesin untuk unit ini'
                  : 'Pilih serial number mesin',
              options: items
                  .map(
                    (item) => PickerOption<MachineModel>(
                      value: item,
                      label: item.serialNumber,
                      subtitle: '${item.capacity} • ${item.status}',
                    ),
                  )
                  .toList(),
              onSelected: (value) => onMachineChanged(value),
              searchHint: 'Cari serial number mesin',
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Gagal memuat mesin'),
          ),
          machines.when(
            data: (items) {
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akses cepat mesin pada unit ini',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items
                          .map(
                            (item) => ChoiceChip(
                              label: Text(item.serialNumber.split('-').last),
                              selected: selectedMachine?.id == item.id,
                              onSelected: (_) {
                                onMachineChanged(item);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text('Total unit: ${units.length} lokasi'),
              Text(
                'Mesin unit ini: ${machines.valueOrNull?.length ?? 0} mesin',
              ),
              Text('Jam laporan: ${DateHelper.formatDateTime(DateTime.now())}'),
              Text('Operator: $operatorName'),
              Text('Koneksi: ${online ? 'Online' : 'Offline'}'),
            ],
          ),
        ],
      ),
    );
  }
}
