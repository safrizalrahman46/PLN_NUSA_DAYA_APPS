import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/machine_model.dart';
import '../remote/machine_api.dart';

final machineRepositoryProvider = Provider<MachineRepository>((ref) {
  return MachineRepository(MachineApi(ref.read(dioProvider)));
});

class MachineRepository {
  MachineRepository(this._api);

  final MachineApi _api;

  Future<List<MachineModel>> getMachines(String unitId) =>
      _api.getMachines(unitId);
}
