import '../core/network/dio_client.dart';
import '../models/unit_model.dart';
import '../models/logsheet_format_model.dart';

class LogsheetRepository {
  final DioClient _dioClient;

  LogsheetRepository(this._dioClient);

  /// Fetch list of units under a region/area
  Future<List<UnitModel>> getUnits({String? kdRegion, String? kdArea}) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/format-logsheet-pltd',
        queryParameters: {
          if (kdRegion != null) 'kd_region': kdRegion,
          if (kdArea != null) 'kd_area': kdArea,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final List<dynamic> list = data['units'] as List? ?? [];
      return list.map((item) => UnitModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch format details for a specific unit
  Future<LogsheetFormatModel> getFormat({
    required String kdArea,
    required String kdUnit,
    String? kdRegion,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/format-logsheet-pltd',
        queryParameters: {
          'kd_area': kdArea,
          'kd_unit': kdUnit,
          if (kdRegion != null) 'kd_region': kdRegion,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return LogsheetFormatModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Submit completed logsheet report text
  Future<Map<String, dynamic>> submitLogsheet({
    required String kdRegion,
    required String messageText,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/v1/logsheet-pltd',
        data: {
          'kd_region': kdRegion,
          'message_text': messageText,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
