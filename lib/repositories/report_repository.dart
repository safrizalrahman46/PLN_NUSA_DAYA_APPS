import '../core/network/dio_client.dart';
import '../models/report_model.dart';
import '../models/report_detail_model.dart';

class ReportRepository {
  final DioClient _dioClient;

  ReportRepository(this._dioClient);

  /// Fetch all reports for a region, date, and optional unit
  Future<List<ReportModel>> getReports({
    required String kdRegion,
    required String tanggal,
    String? kdUnit,
  }) async {
    try {
      // Changed from POST to GET to match backend requirements and avoid 405 errors
      final response = await _dioClient.dio.get(
        '/logsheet',
        queryParameters: {
          'kd_region': kdRegion,
          'tanggal': tanggal,
          if (kdUnit != null) 'kd_unit': kdUnit,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final List<dynamic> list = data['data'] as List? ?? [];
      return list.map((item) => ReportModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch detailed report logs for a specific timestamp slot
  Future<ReportDetailModel> getReportDetail({
    required String idBebanUld,
    required String kdRegion,
    required String tanggal,
    required String jam,
  }) async {
    try {
      // Changed from POST to GET to match backend requirements and avoid 405 errors
      final response = await _dioClient.dio.get(
        '/getLogsheet/$idBebanUld',
        queryParameters: {
          'kd_region': kdRegion,
          'tanggal': tanggal,
          'jam': jam,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final Map<String, dynamic> detailData = data['data'] as Map<String, dynamic>? ?? {};
      return ReportDetailModel.fromJson(detailData);
    } catch (e) {
      rethrow;
    }
  }
}
