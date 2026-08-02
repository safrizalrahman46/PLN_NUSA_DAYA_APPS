import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_info.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_picker_field.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/models/unit_model.dart';

class MachineSelectorCard extends ConsumerWidget {
  const MachineSelectorCard({
    super.key,
    required this.operatorName,
    required this.selectedUnit,
    required this.selectedMachine,
    required this.selectedTimeSlot,
    required this.units,
    required this.machines,
    required this.onUnitChanged,
    required this.onMachineChanged,
    required this.onMachineStatusChanged,
    required this.onTimeSlotChanged,
  });

  final String operatorName;
  final UnitModel? selectedUnit;
  final MachineModel? selectedMachine;
  final MachineStatus? machineStatus;
  final String selectedTimeSlot;
  final List<UnitModel> units;
  final AsyncValue<List<MachineModel>> machines;
  final ValueChanged<UnitModel?> onUnitChanged;
  final ValueChanged<MachineModel?> onMachineChanged;
  final ValueChanged<MachineStatus> onMachineStatusChanged;
  final ValueChanged<String> onTimeSlotChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(networkStatusProvider).valueOrNull ?? true;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.electric_bolt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: SectionTitle(
                  title: 'Informasi Unit',
                  subtitle: 'Pilih unit, mesin, dan status operasi',
                ),
              ),
            ],
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
              label: 'Mesin PLTD',
              hint: items.isEmpty
                  ? 'Belum ada mesin untuk unit ini'
                  : 'Pilih nama mesin dari master PLTD',
              options: items
                  .map(
                    (item) => PickerOption<MachineModel>(
                      value: item,
                      label: item.displayLabel,
                      subtitle: item.masterInfoLine.isEmpty
                          ? item.displaySubtitle
                          : '${item.displaySubtitle} • ${item.masterInfoLine}',
                    ),
                  )
                  .toList(),
              onSelected: (value) => onMachineChanged(value),
              searchHint: 'Cari nama mesin, merk, tipe, atau no seri',
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Gagal memuat mesin'),
          ),
          const SizedBox(height: 12),
          AppPickerField<MachineStatus>(
            value: machineStatus,
            label: 'Status Mesin',
            hint: 'Status awal mengikuti master, tetap bisa diubah',
            options: MachineStatus.values
                .map(
                  (status) => PickerOption<MachineStatus>(
                    value: status,
                    label: status.label,
                    subtitle: switch (status) {
                      MachineStatus.operasi =>
                        'Mesin beroperasi normal saat pelaporan',
                      MachineStatus.standby =>
                        'Mesin siaga dan tidak sedang dibebani',
                      MachineStatus.gangguanRusak =>
                        'Mesin gangguan/rusak, parameter numerik otomatis 0',
                    },
                  ),
                )
                .toList(),
            onSelected: onMachineStatusChanged,
            searchHint: 'Cari status mesin',
          ),
          const SizedBox(height: 12),
          AppPickerField<String>(
            value: selectedTimeSlot.isEmpty
                ? '${DateTime.now().hour.toString().padLeft(2, '0')}:00'
                : selectedTimeSlot,
            label: 'Jam Laporan (Slot Jam)',
            hint: 'Pilih jam laporan (00:00 - 23:30)',
            options: [
              for (int h = 0; h < 24; h++) ...[
                '${h.toString().padLeft(2, '0')}:00',
                '${h.toString().padLeft(2, '0')}:30',
              ]
            ]
                .map(
                  (time) => PickerOption<String>(
                    value: time,
                    label: 'Jam $time WITA',
                    subtitle: 'Slot jam operasional $time',
                  ),
                )
                .toList(),
            onSelected: onTimeSlotChanged,
            searchHint: 'Cari jam (contoh: 01:00, 07:00, 14:30)',
          ),
          if (selectedMachine != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedMachine!.displayLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (selectedMachine!.displaySubtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      selectedMachine!.displaySubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (selectedMachine!.masterInfoLine.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      selectedMachine!.masterInfoLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
                              label: Text(item.shortLabel),
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
              Text('Jam laporan: ${selectedTimeSlot.isEmpty ? DateHelper.formatDateTime(DateTime.now()) : "Jam $selectedTimeSlot WITA"}'),
              Text('Operator: $operatorName'),
              Text('Koneksi: ${online ? 'Online' : 'Offline'}'),
            ],
          ),
        ],
      ),
    );
  }
}
