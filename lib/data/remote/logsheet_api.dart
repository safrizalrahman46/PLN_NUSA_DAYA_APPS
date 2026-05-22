import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../dummy/dummy_data.dart';
import '../models/logsheet_model.dart';

class LogsheetApi {
  LogsheetApi(this._dio);

  final Dio _dio;

  Future<LogsheetModel> submitLogsheet(LogsheetModel logsheet) async {
    try {
      final response = await _dio.post('/logsheets', data: logsheet.toJson());
      final data = response.data['data'] ?? response.data;
      return LogsheetModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw ApiException.fromDioException(
        error,
        fallbackMessage: 'Gagal mengirim logsheet ke server.',
      );
    }
  }

  Future<bool> uploadMedia(String logsheetId) async {
    try {
      await _dio.post('/logsheets/$logsheetId/upload-media');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<LogsheetModel>> getHistory() async {
    try {
      final response = await _dio.get('/logsheets/history');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map(
            (item) => LogsheetModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException {
      return DummyData.seedLogsheets();
    }
  }
}
