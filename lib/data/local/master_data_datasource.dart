import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/machine_model.dart';
import 'hive_service.dart';

final masterDataDatasourceProvider = Provider<MasterDataDatasource>((ref) {
  return MasterDataDatasource(ref.read(hiveServiceProvider));
});

class MasterDataDatasource {
  MasterDataDatasource(this._hiveService);

  final HiveService _hiveService;

  static const _machinesKey = 'master_machines_v1';

  Future<List<MachineModel>?> fetchMachines() async {
    final raw = _hiveService.cacheBox.get(_machinesKey);
    if (raw is! List) {
      return null;
    }

    return raw
        .whereType<Map>()
        .map((json) => MachineModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> saveMachines(List<MachineModel> machines) async {
    await _hiveService.cacheBox.put(
      _machinesKey,
      machines.map((item) => item.toJson()).toList(),
    );
  }
}
