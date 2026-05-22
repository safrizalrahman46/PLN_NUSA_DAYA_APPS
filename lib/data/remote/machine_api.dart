import 'package:dio/dio.dart';

import '../dummy/dummy_data.dart';
import '../models/machine_model.dart';

class MachineApi {
  MachineApi(this._dio);

  final Dio _dio;

  Future<List<MachineModel>> getAllMachines() async {
    try {
      final response = await _dio.get('/machines');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((item) => MachineModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException {
      return DummyData.machines;
    }
  }

  Future<List<MachineModel>> getMachines(String unitId) async {
    try {
      final response = await _dio.get(
        '/machines',
        queryParameters: {'unit_id': unitId},
      );
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((item) => MachineModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException {
      return DummyData.machinesByUnit(unitId);
    }
  }
}
