import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/dio_client.dart';
import '../dummy/dummy_data.dart';
import '../local/master_data_datasource.dart';
import '../models/machine_model.dart';
import '../models/unit_model.dart';
import '../remote/machine_api.dart';

final machineRepositoryProvider = Provider<MachineRepository>((ref) {
  return MachineRepository(
    MachineApi(ref.read(dioProvider)),
    ref.read(masterDataDatasourceProvider),
  );
});

class MachineRepository {
  MachineRepository(this._api, this._datasource);

  final MachineApi _api;
  final MasterDataDatasource _datasource;
  final _uuid = const Uuid();

  /// Fetch machines for a specific unit using the DIGIKIT format-logsheet API.
  /// This is the preferred method for the InputLogsheetPage.
  Future<List<MachineModel>> getMachinesForUnit(UnitModel unit) async {
    // kdArea is required for the format-logsheet endpoint.
    // If kdArea is missing (e.g. legacy dummy unit), fall back to local cache.
    if (unit.kdArea.isEmpty) {
      final all = await getAllMachines();
      final filtered = all.where((m) => m.unitId == unit.id).toList();
      if (filtered.isNotEmpty) return filtered;
      return DummyData.machinesByUnit(unit.id);
    }

    return _api.getMachinesByUnit(
      kdUnit: unit.id,
      kdArea: unit.kdArea,
      namaUnit: unit.name,
    );
  }

  Future<List<MachineModel>> getAllMachines() async {
    final cached = await _datasource.fetchMachines();
    if (cached != null) {
      return _sortMachines(cached);
    }

    final seeded = await _bootstrapMachines();
    return _sortMachines(seeded);
  }

  Future<List<MachineModel>> getMachines(String unitId) async {
    final all = await getAllMachines();
    return all.where((item) => item.unitId == unitId).toList();
  }

  Future<MachineModel> createMachine(MachineModel machine) async {
    final all = await getAllMachines();
    final next = machine.copyWith(
      id: machine.id.trim().isEmpty ? _nextMachineId(all) : machine.id.trim(),
    );
    await _datasource.saveMachines([...all, next]);
    return next;
  }

  Future<MachineModel> updateMachine(MachineModel machine) async {
    final all = await getAllMachines();
    final index = all.indexWhere((item) => item.id == machine.id);
    if (index < 0) {
      throw StateError('Mesin dengan id ${machine.id} tidak ditemukan.');
    }
    final updated = List<MachineModel>.from(all)..[index] = machine;
    await _datasource.saveMachines(updated);
    return machine;
  }

  Future<MachineModel> moveMachine(String machineId, String unitId) async {
    final all = await getAllMachines();
    final index = all.indexWhere((item) => item.id == machineId);
    if (index < 0) {
      throw StateError('Mesin dengan id $machineId tidak ditemukan.');
    }
    final moved = all[index].copyWith(unitId: unitId);
    final updated = List<MachineModel>.from(all)..[index] = moved;
    await _datasource.saveMachines(updated);
    return moved;
  }

  Future<void> deleteMachine(String machineId) async {
    final all = await getAllMachines();
    final updated = all.where((item) => item.id != machineId).toList();
    await _datasource.saveMachines(updated);
  }

  Future<List<MachineModel>> _bootstrapMachines() async {
    final remoteItems = await _api.getAllMachines();
    final base = remoteItems.isEmpty ? DummyData.machines : remoteItems;
    await _datasource.saveMachines(base);
    return base;
  }

  List<MachineModel> _sortMachines(List<MachineModel> items) {
    final sorted = List<MachineModel>.from(items);
    sorted.sort((a, b) {
      final unitCompare = a.unitId.compareTo(b.unitId);
      if (unitCompare != 0) {
        return unitCompare;
      }
      final nameCompare = a.displayLabel.toLowerCase().compareTo(
        b.displayLabel.toLowerCase(),
      );
      if (nameCompare != 0) {
        return nameCompare;
      }
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  String _nextMachineId(List<MachineModel> items) {
    final nextNumber = items
            .map(
              (item) => int.tryParse(
                item.id.replaceFirst(RegExp(r'^[A-Za-z]+'), ''),
              ),
            )
            .whereType<int>()
            .fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue) +
        1;
    return 'M${nextNumber.toString().padLeft(3, '0')}-${_uuid.v4().substring(0, 4)}';
  }
}
