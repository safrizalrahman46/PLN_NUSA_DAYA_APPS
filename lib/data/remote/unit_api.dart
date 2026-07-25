import 'package:dio/dio.dart';

import '../dummy/dummy_data.dart';
import '../models/unit_model.dart';

class UnitApi {
  UnitApi(this._dio);

  final Dio _dio;

  // DIGIKIT API: GET /v1/format-logsheet-pltd?kd_region=05
  // Mengembalikan daftar unit di wilayah Kalimantan 3
  Future<List<UnitModel>> getUnits({String kdRegion = '05'}) async {
    try {
      final response = await _dio.get(
        '/v1/format-logsheet-pltd',
        queryParameters: {'kd_region': kdRegion},
      );
      final data = response.data as Map<String, dynamic>;
      final unitsData = data['units'] as List<dynamic>?;
      if (unitsData == null || unitsData.isEmpty) return DummyData.units;
      return unitsData
          .map((item) => UnitModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return DummyData.units;
    }
  }

  // DIGIKIT API: GET /v1/format-logsheet-pltd?kd_region=05&kd_area=40&kd_unit=0264
  // Mendapatkan format logsheet untuk unit tertentu termasuk daftar mesin
  Future<Map<String, dynamic>> getFormatLogsheet({
    required String kdRegion,
    required String kdArea,
    required String kdUnit,
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
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
