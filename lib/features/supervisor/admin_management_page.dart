import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/machine_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/repositories/machine_repository.dart';
import '../../data/repositories/unit_repository.dart';

final managementUnitsProvider = FutureProvider<List<UnitModel>>((ref) {
  return ref.read(unitRepositoryProvider).getUnits();
});

final managementMachinesProvider = FutureProvider<List<MachineModel>>((ref) {
  return ref.read(machineRepositoryProvider).getAllMachines();
});

class AdminManagementPage extends ConsumerStatefulWidget {
  const AdminManagementPage({super.key});

  @override
  ConsumerState<AdminManagementPage> createState() =>
      _AdminManagementPageState();
}

class _AdminManagementPageState extends ConsumerState<AdminManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSoft,
          tabs: const [
            Tab(text: 'Operator'),
            Tab(text: 'Unit'),
            Tab(text: 'Mesin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UsersTab(),
          _UnitsTab(),
          _MachinesTab(),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final grouped = {
      for (final role in UserRole.values)
        role: DummyData.users.where((item) => item.role == role).toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Manajemen User',
                subtitle:
                    'Pantau akun operator, supervisor, admin, dan superadmin yang aktif.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: UserRole.values
                    .map(
                      (role) => _CountPill(
                        label: role.label,
                        value: grouped[role]!.length.toString(),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...DummyData.users.map(
          (user) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  foregroundColor: AppColors.primary,
                  child: const Icon(Icons.person_rounded),
                ),
                title: Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text('${user.role.label} • ${user.unitName}'),
                trailing: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  borderRadius: 999,
                  sigmaX: 6,
                  sigmaY: 6,
                  child: Text(
                    user.username,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitsTab extends ConsumerWidget {
  const _UnitsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(managementUnitsProvider);

    return units.when(
      data: (items) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Master Unit PLTD',
                  subtitle:
                      'Daftar unit aktif yang menjadi tujuan input operator dan relasi mesin.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _CountPill(label: 'Total Unit', value: items.length.toString()),
                    _CountPill(
                      label: 'Status Aktif',
                      value: items.where((item) => item.status == 'active').length.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (unit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
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
                      Icons.electrical_services_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    unit.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${unit.locationName} • Radius ${unit.radiusMeter.toStringAsFixed(0)} m',
                  ),
                  trailing: StatusBadge(
                    label: unit.status,
                    color: unit.status == 'active'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const AppLoading(),
      error: (error, _) => AppErrorState(
        message: ApiException.fromObject(error).message,
      ),
    );
  }
}

class _MachinesTab extends ConsumerStatefulWidget {
  const _MachinesTab();

  @override
  ConsumerState<_MachinesTab> createState() => _MachinesTabState();
}

class _MachinesTabState extends ConsumerState<_MachinesTab> {
  late final TextEditingController _searchController;
  String _query = '';
  String _selectedUnitId = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(managementUnitsProvider);
    final machinesAsync = ref.watch(managementMachinesProvider);

    if (unitsAsync.isLoading || machinesAsync.isLoading) {
      return const AppLoading();
    }
    if (unitsAsync.hasError) {
      return AppErrorState(
        message: ApiException.fromObject(unitsAsync.error!).message,
      );
    }
    if (machinesAsync.hasError) {
      return AppErrorState(
        message: ApiException.fromObject(machinesAsync.error!).message,
      );
    }

    final units = unitsAsync.value ?? const <UnitModel>[];
    final machines = machinesAsync.value ?? const <MachineModel>[];
    final unitNameById = {for (final unit in units) unit.id: unit.name};
    final filtered = machines.where((machine) {
      final unitName = unitNameById[machine.unitId] ?? machine.unitId;
      final searchText = [
        machine.displayLabel,
        machine.displaySubtitle,
        machine.masterInfoLine,
        unitName,
      ].join(' ').toLowerCase();
      final matchQuery = _query.trim().isEmpty ||
          searchText.contains(_query.trim().toLowerCase());
      final matchUnit =
          _selectedUnitId == 'all' || machine.unitId == _selectedUnitId;
      return matchQuery && matchUnit;
    }).toList();

    final unitOptions = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(value: 'all', child: Text('Semua Unit')),
      ...units.map(
        (unit) => DropdownMenuItem<String>(
          value: unit.id,
          child: Text(unit.name),
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Master Mesin PLTD',
                subtitle:
                    'Superadmin dapat tambah, edit, hapus, dan memindahkan mesin antar unit langsung dari panel ini.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _CountPill(label: 'Total Mesin', value: machines.length.toString()),
                  _CountPill(
                    label: 'Unit Terpakai',
                    value: machines.map((item) => item.unitId).toSet().length.toString(),
                  ),
                  _CountPill(
                    label: 'Gangguan/Rusak',
                    value: machines
                        .where(
                          (item) => parseMachineStatus(
                                item.conditionLabel.isEmpty
                                    ? item.status
                                    : item.conditionLabel,
                              ) ==
                              MachineStatus.gangguanRusak,
                        )
                        .length
                        .toString(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _searchController,
                      label: 'Cari mesin, serial, UP3, atau unit',
                      onChanged: (value) => setState(() => _query = value),
                      suffixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_selectedUnitId),
                      initialValue: _selectedUnitId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Filter Unit'),
                      items: unitOptions,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUnitId = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(
                    label: 'Tambah Mesin',
                    onPressed: units.isEmpty ? null : () => _addMachine(units),
                    fullWidth: false,
                  ),
                  AppButton(
                    label: 'Reset Filter',
                    onPressed: () {
                      setState(() {
                        _query = '';
                        _selectedUnitId = 'all';
                      });
                      _searchController.clear();
                    },
                    type: AppButtonType.outlined,
                    fullWidth: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const AppErrorState(
            title: 'Mesin tidak ditemukan',
            message: 'Tidak ada mesin yang cocok dengan filter saat ini.',
          )
        else
          ...filtered.map(
            (machine) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MachineCard(
                machine: machine,
                unitName: unitNameById[machine.unitId] ?? machine.unitId,
                onEdit: () => _editMachine(units, machine),
                onMove: () => _moveMachine(units, machine),
                onDelete: () => _deleteMachine(machine),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addMachine(List<UnitModel> units) async {
    final created = await _showMachineDialog(units: units);
    if (!mounted || created == null) return;
    await ref.read(machineRepositoryProvider).createMachine(created);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Mesin baru berhasil ditambahkan.');
  }

  Future<void> _editMachine(List<UnitModel> units, MachineModel machine) async {
    final updated = await _showMachineDialog(units: units, machine: machine);
    if (!mounted || updated == null) return;
    await ref.read(machineRepositoryProvider).updateMachine(updated);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Master mesin berhasil diperbarui.');
  }

  Future<void> _moveMachine(List<UnitModel> units, MachineModel machine) async {
    final targetUnitId = await _showMoveDialog(units: units, machine: machine);
    if (!mounted || targetUnitId == null || targetUnitId == machine.unitId) {
      return;
    }
    await ref.read(machineRepositoryProvider).moveMachine(machine.id, targetUnitId);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Mesin berhasil dipindahkan ke unit baru.');
  }

  Future<void> _deleteMachine(MachineModel machine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Mesin'),
        content: Text(
          'Hapus ${machine.displayLabel}? Mesin ini tidak akan muncul lagi pada form input operator, tetapi riwayat logsheet lama tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await ref.read(machineRepositoryProvider).deleteMachine(machine.id);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Mesin berhasil dihapus dari master data.');
  }

  Future<MachineModel?> _showMachineDialog({
    required List<UnitModel> units,
    MachineModel? machine,
  }) async {
    final nameController = TextEditingController(text: machine?.machineName ?? '');
    final brandController = TextEditingController(text: machine?.brand ?? '');
    final typeController = TextEditingController(text: machine?.machineType ?? '');
    final serialController = TextEditingController(text: machine?.serialNumber ?? '');
    final generatorController = TextEditingController(
      text: machine?.generatorCode ?? '',
    );
    final ownershipController = TextEditingController(
      text: machine?.ownershipStatus ?? '',
    );
    final performanceController = TextEditingController(
      text: machine?.performanceLabel ?? '',
    );
    final capacityController = TextEditingController(text: machine?.capacity ?? '');
    final availableController = TextEditingController(
      text: machine?.availableCapacity ?? '',
    );
    final dispatchController = TextEditingController(
      text: machine?.dispatchCapacity ?? '',
    );
    final up3Controller = TextEditingController(text: machine?.up3 ?? '');
    final conditionController = TextEditingController(
      text: machine?.conditionLabel ?? '',
    );
    var selectedUnitId = machine?.unitId ?? (units.isNotEmpty ? units.first.id : '');
    var selectedStatus = parseMachineStatus(
      machine == null
          ? MachineStatus.operasi.apiValue
          : machine.conditionLabel.isEmpty
          ? machine.status
          : machine.conditionLabel,
    );

    final result = await showDialog<MachineModel>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(machine == null ? 'Tambah Mesin PLTD' : 'Edit Mesin PLTD'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                      key: ValueKey('unit-$selectedUnitId'),
                      initialValue: selectedUnitId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unit PLTD *'),
                      items: units
                          .map(
                            (unit) => DropdownMenuItem<String>(
                              value: unit.id,
                              child: Text(unit.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedUnitId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MachineStatus>(
                      key: ValueKey('status-${selectedStatus.name}'),
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status Mesin *'),
                      items: MachineStatus.values
                          .map(
                            (status) => DropdownMenuItem<MachineStatus>(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedStatus = value;
                          if (conditionController.text.trim().isEmpty ||
                              MachineStatus.values.any(
                                (item) => item.label == conditionController.text.trim(),
                              )) {
                            conditionController.text = value.label;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: nameController,
                      label: 'Nama Mesin *',
                      hint: 'Contoh: Cummins #3',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: serialController,
                      label: 'Serial Number',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(controller: brandController, label: 'Merk'),
                    const SizedBox(height: 12),
                    AppTextField(controller: typeController, label: 'Tipe Mesin'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: capacityController,
                      label: 'Kapasitas Terpasang',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: availableController,
                      label: 'Kapasitas DMN',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: dispatchController,
                      label: 'Kapasitas Pasok',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(controller: up3Controller, label: 'UP3'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: generatorController,
                      label: 'Kode Generator',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: ownershipController,
                      label: 'Status Kepemilikan',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: performanceController,
                      label: 'Label Kinerja',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: conditionController,
                      label: 'Label Kondisi',
                      hint: 'Default mengikuti status mesin',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Anda bisa memindahkan mesin ke unit lain kapan saja dengan mengganti pilihan Unit PLTD saat edit.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  if (selectedUnitId.isEmpty ||
                      (nameController.text.trim().isEmpty &&
                          serialController.text.trim().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unit dan identitas mesin wajib diisi.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    MachineModel(
                      id: machine?.id ?? '',
                      unitId: selectedUnitId,
                      up3: up3Controller.text.trim(),
                      machineName: nameController.text.trim(),
                      brand: brandController.text.trim(),
                      machineType: typeController.text.trim(),
                      serialNumber: serialController.text.trim(),
                      generatorCode: generatorController.text.trim(),
                      ownershipStatus: ownershipController.text.trim(),
                      performanceLabel: performanceController.text.trim(),
                      capacity: capacityController.text.trim(),
                      availableCapacity: availableController.text.trim(),
                      dispatchCapacity: dispatchController.text.trim(),
                      status: selectedStatus.apiValue,
                      conditionLabel: conditionController.text.trim().isEmpty
                          ? selectedStatus.label
                          : conditionController.text.trim(),
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
    brandController.dispose();
    typeController.dispose();
    serialController.dispose();
    generatorController.dispose();
    ownershipController.dispose();
    performanceController.dispose();
    capacityController.dispose();
    availableController.dispose();
    dispatchController.dispose();
    up3Controller.dispose();
    conditionController.dispose();
    return result;
  }

  Future<String?> _showMoveDialog({
    required List<UnitModel> units,
    required MachineModel machine,
  }) async {
    var selectedUnitId = machine.unitId;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pindah Mesin ke Unit Lain'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.displayLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih unit tujuan baru untuk memperbarui relasi mesin ini.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('move-$selectedUnitId'),
                  initialValue: selectedUnitId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Unit Tujuan'),
                  items: units
                      .map(
                        (unit) => DropdownMenuItem<String>(
                          value: unit.id,
                          child: Text(unit.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedUnitId = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selectedUnitId),
              child: const Text('Pindahkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({
    required this.machine,
    required this.unitName,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
  });

  final MachineModel machine;
  final String unitName;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final machineStatus = parseMachineStatus(
      machine.conditionLabel.isEmpty ? machine.status : machine.conditionLabel,
    );

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.memory_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.displayLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      unitName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.machine(machineStatus),
            ],
          ),
          const SizedBox(height: 12),
          if (machine.displaySubtitle.isNotEmpty)
            Text(machine.displaySubtitle),
          if (machine.masterInfoLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              machine.masterInfoLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoft,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: 'Edit',
                onPressed: onEdit,
                fullWidth: false,
              ),
              AppButton(
                label: 'Pindah Unit',
                onPressed: onMove,
                type: AppButtonType.tonal,
                fullWidth: false,
              ),
              AppButton(
                label: 'Hapus',
                onPressed: onDelete,
                type: AppButtonType.outlined,
                fullWidth: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 999,
      sigmaX: 6,
      sigmaY: 6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoft,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
