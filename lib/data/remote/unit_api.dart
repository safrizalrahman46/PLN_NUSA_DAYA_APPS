import 'package:dio/dio.dart';

import '../dummy/dummy_data.dart';
import '../models/unit_model.dart';

class UnitApi {
  UnitApi(this._dio);

  final Dio _dio;

  Future<List<UnitModel>> getUnits() async {
    try {
      final response = await _dio.get('/units');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((item) => UnitModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException {
      return DummyData.units;
    }
  }
}
