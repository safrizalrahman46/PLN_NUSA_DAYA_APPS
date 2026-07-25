import 'package:dio/dio.dart';

import '../dummy/dummy_data.dart';
import '../models/machine_model.dart';

class MachineApi {
  MachineApi(this._dio);

  final Dio _dio;

  // DIGIKIT API: GET /v1/format-logsheet-pltd?kd_region=05
  // Returns list of units then fetches machines for each unit via format endpoint
  Future<List<MachineModel>> getAllMachines({String kdRegion = '05'}) async {
    try {
      // Step 1: Get all units
      final unitsResp = await _dio.get(
        '/v1/format-logsheet-pltd',
        queryParameters: {'kd_region': kdRegion},
      );
      final unitsData = (unitsResp.data as Map<String, dynamic>?)?['units']
          as List<dynamic>?;
      if (unitsData == null || unitsData.isEmpty) return DummyData.machines;

      // Step 2: For each unit, fetch machines from format-logsheet endpoint
      final allMachines = <MachineModel>[];
      for (final unitJson in unitsData) {
        final unit = Map<String, dynamic>.from(unitJson as Map);
        final kdUnit = unit['kd_unit']?.toString() ?? '';
        final kdArea = unit['kd_area']?.toString() ?? '';
        final namaUnit = unit['nama_unit']?.toString() ?? '';
        if (kdUnit.isEmpty || kdArea.isEmpty) continue;

        try {
          final formatResp = await _dio.get(
            '/v1/format-logsheet-pltd',
            queryParameters: {
              'kd_region': kdRegion,
              'kd_area': kdArea,
              'kd_unit': kdUnit,
            },
          );
          final format = (formatResp.data as Map<String, dynamic>?)?['format']
              as Map<String, dynamic>?;
          final mesinList = format?['mesin'] as List<dynamic>?;
          if (mesinList == null) continue;

          for (final mesinJson in mesinList) {
            final mesin = Map<String, dynamic>.from(mesinJson as Map);
            // Inject unit-level fields for proper mapping
            mesin['kd_unit'] = kdUnit;
            mesin['unitId'] = kdUnit;
            mesin['up3'] = namaUnit;
            allMachines.add(MachineModel.fromJson(mesin));
          }
        } catch (_) {
          // Skip unit on error, continue with others
        }
      }

      if (allMachines.isEmpty) return DummyData.machines;
      return allMachines;
    } catch (_) {
      return DummyData.machines;
    }
  }

  // Fetch machines for a specific unit by kd_unit
  // unitId here is the kd_unit (e.g. '0264'), kdArea is e.g. '40'
  Future<List<MachineModel>> getMachinesByUnit({
    required String kdUnit,
    required String kdArea,
    String kdRegion = '05',
    String namaUnit = '',
  }) async {
    try {
      final response = await _dio.get(
        '/v1/format-logsheet-pltd',
        queryParameters: {
          'kd_region': kdRegion,
          'kd_area': kdArea,
          'kd_unit': kdUnit,
        },
      );
      final format = (response.data as Map<String, dynamic>?)?['format']
          as Map<String, dynamic>?;
      final mesinList = format?['mesin'] as List<dynamic>?;
      if (mesinList == null || mesinList.isEmpty) {
        return DummyData.machinesByUnit(kdUnit);
      }

      return mesinList.map((mesinJson) {
        final mesin = Map<String, dynamic>.from(mesinJson as Map);
        mesin['kd_unit'] = kdUnit;
        mesin['unitId'] = kdUnit;
        mesin['up3'] = namaUnit;
        return MachineModel.fromJson(mesin);
      }).toList();
    } catch (_) {
      return DummyData.machinesByUnit(kdUnit);
    }
  }

  // Legacy method retained for backward compatibility
  Future<List<MachineModel>> getMachines(String unitId) async {
    return DummyData.machinesByUnit(unitId);
  }
}
