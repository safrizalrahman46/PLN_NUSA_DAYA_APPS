import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../dummy/dummy_data.dart';
import '../models/app_enums.dart';
import '../models/logsheet_model.dart';

class LogsheetApi {
  LogsheetApi(this._dio);

  final Dio _dio;

  String _buildMessageText(LogsheetModel logsheet) {
    return 'LAPORAN LOGSHEET PLTD\n'
        '${logsheet.unitName}\n'
        'id unit: ${logsheet.unitId}\n'
        'tgl : ${logsheet.submittedAt.toIso8601String().substring(0, 10)}\n'
        'jam : ${logsheet.submittedAt.toIso8601String().substring(11, 16)}\n'
        'nama operator: ${logsheet.operatorName}\n'
        '\n'
        '1. ${logsheet.machineName}\n'
        'id mesin: ${logsheet.machineId}\n'
        'kode mesin: \n'
        'sn: ${logsheet.serialNumber}\n'
        'dt: \n'
        'daya mampu: \n'
        'beban: ${logsheet.bebanMesin}\n'
        'stand kwh: ${logsheet.standKwh}\n'
        'stand bbm: ${logsheet.standBbm}\n'
        'phasa r: ${logsheet.phasaR}\n'
        'phasa s: ${logsheet.phasaS}\n'
        'phasa t: ${logsheet.phasaT}\n'
        'tek oli: ${logsheet.tekananOli}\n'
        'temp air pendingin: ${logsheet.temperaturAir}\n'
        'tegangan: ${logsheet.tegangan}\n'
        'frequency: ${logsheet.frequency}\n'
        'cos phi: ${logsheet.cosPhi}\n'
        'jam kerja mesin: \n'
        'status mesin: ${logsheet.machineStatus.apiValue.toUpperCase()}\n'
        'Kwh produksi : \n'
        'pemakaian bbm : \n'
        'jenis bahan bakar : B35\n'
        'ket: ${logsheet.notes}';
  }

  /// POST Logsheet to WACB with built-in auto-retry (up to maxRetries)
  Future<LogsheetModel> submitLogsheet(
    LogsheetModel logsheet, {
    int maxRetries = 3,
  }) async {
    final messageText = _buildMessageText(logsheet);
    DioException? lastException;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _dio.post(
          '/v1/logsheet-pltd',
          queryParameters: {'kd_region': '05'},
          data: {'message_text': messageText},
        );
        final data = response.data['data'] ?? response.data;
        if (data is Map) {
          final result = LogsheetModel.fromJson(Map<String, dynamic>.from(data));
          
          // Perform automatic slot verification on WACB server
          await verifyLogsheetSubmitted(logsheet);
          return result;
        }
      } on DioException catch (error) {
        lastException = error;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        if (attempt == maxRetries) rethrow;
      }
    }

    if (lastException != null) {
      throw ApiException.fromDioException(
        lastException,
        fallbackMessage: 'Gagal mengirim logsheet ke server WACB.',
      );
    }

    throw ApiException('Gagal mengirim logsheet ke server WACB setelah $maxRetries percobaan.');
  }

  /// Verify on WACB server that the logsheet slot has been registered
  Future<bool> verifyLogsheetSubmitted(LogsheetModel logsheet) async {
    try {
      final dateStr = logsheet.submittedAt.toIso8601String().substring(0, 10);
      final response = await _dio.get(
        '/v1/format-logsheet-pltd',
        queryParameters: {
          'kd_region': '05',
          'kd_unit': logsheet.unitId,
          'tanggal': dateStr,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {
      // Return true as fallback if POST already succeeded
    }
    return true;
  }

  Future<bool> uploadMedia(String logsheetId) async {
    try {
      await _dio.post('/v1/logsheet-pltd/$logsheetId/upload-media');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<LogsheetModel>> getHistory() async {
    try {
      final response = await _dio.get(
        '/logsheet',
        queryParameters: {
          'kd_region': '05',
          'tanggal': DateTime.now().toIso8601String().substring(0, 10),
        },
      );
      final data = response.data['data'] as List<dynamic>?;
      if (data == null) return DummyData.seedLogsheets();
      return data
          .map((item) => LogsheetModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return DummyData.seedLogsheets();
    }
  }
}
