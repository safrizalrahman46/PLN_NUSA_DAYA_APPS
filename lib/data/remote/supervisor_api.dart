import 'package:dio/dio.dart';

import '../dummy/dummy_data.dart';
import '../models/logsheet_model.dart';

class SupervisorApi {
  SupervisorApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('/supervisor/dashboard');
      return Map<String, dynamic>.from(response.data['data'] ?? response.data);
    } catch (_) {
      return {
        'total_units': DummyData.units.length,
        'total_operator': DummyData.users
            .where((item) => item.isOperator)
            .length,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final data = response.data['data'] as List<dynamic>;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return DummyData.notifications();
    }
  }

  Future<List<Map<String, dynamic>>> getMonitoring() async {
    try {
      final response = await _dio.get('/supervisor/monitoring');
      final data = response.data['data'] as List<dynamic>;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return _fallbackMonitoring(DummyData.seedLogsheets());
    }
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final response = await _dio.get('/reports');
      final data = response.data['data'] as List<dynamic>;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      final rows = <Map<String, dynamic>>[];
      final items = DummyData.seedLogsheets();
      for (final unit in DummyData.units) {
        final unitLogs = items.where((item) => item.unitId == unit.id).toList();
        rows.add({
          'tanggal': DateTime.now().toIso8601String(),
          'unit': unit.name,
          'operator': unitLogs.isNotEmpty ? unitLogs.first.operatorName : '-',
          'jumlah': unitLogs.length,
          'tepatWaktu': unitLogs
              .where((item) => item.reportStatus.name == 'onTime')
              .length,
          'terlambat': unitLogs
              .where((item) => item.reportStatus.name == 'late')
              .length,
          'abnormal': unitLogs
              .where((item) => item.reportStatus.name == 'abnormal')
              .length,
          'pending': unitLogs
              .where((item) => item.syncStatus.name == 'pendingSync')
              .length,
        });
      }
      return rows;
    }
  }

  List<Map<String, dynamic>> _fallbackMonitoring(List<LogsheetModel> items) {
    return DummyData.units.map((unit) {
      final unitLogs = items.where((item) => item.unitId == unit.id).toList();
      final latest = unitLogs.isNotEmpty ? unitLogs.first : null;
      return {
        'unit': unit.name,
        'operator': latest?.operatorName ?? 'Belum ada data',
        'lastSubmit': latest?.submittedAt.toIso8601String(),
        'reportStatus': latest?.reportStatus.name ?? 'missing',
        'locationStatus': latest?.locationStatus.name ?? 'unknown',
        'hasPhoto':
            (latest?.machinePhotoPath.isNotEmpty ?? false) || latest != null,
      };
    }).toList();
  }
}
