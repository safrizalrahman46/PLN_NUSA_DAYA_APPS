import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/date_helper.dart';
import '../dummy/dummy_data.dart';
import '../local/local_logsheet_datasource.dart';
import '../models/app_enums.dart';
import '../models/dashboard_summary_model.dart';
import '../models/logsheet_model.dart';
import '../remote/supervisor_api.dart';

final supervisorRepositoryProvider = Provider<SupervisorRepository>((ref) {
  return SupervisorRepository(
    ref.read(localLogsheetDatasourceProvider),
    SupervisorApi(ref.read(dioProvider)),
  );
});

class SupervisorRepository {
  SupervisorRepository(this._localDatasource, this._api);

  final LocalLogsheetDatasource _localDatasource;
  final SupervisorApi _api;

  Future<DashboardSummaryModel> getDashboardSummary() async {
    final history = await _localDatasource.fetchAll();
    return DashboardSummaryModel(
      todayReports: history.where(_isToday).length,
      pendingSync: history
          .where(
            (item) =>
                item.syncStatus == SyncStatus.pendingSync ||
                item.syncStatus == SyncStatus.pendingEdit,
          )
          .length,
      successReports: history
          .where((item) => item.syncStatus == SyncStatus.synced)
          .length,
      abnormalReports: history
          .where((item) => item.reportStatus == ReportStatus.abnormal)
          .length,
      totalUnits: DummyData.units.length,
      totalOperators: DummyData.users.where((item) => item.isOperator).length,
      lateOperators: history
          .where((item) => item.reportStatus == ReportStatus.late)
          .length,
      nextReportAt: DateHelper.nextReportTime(),
    );
  }

  Future<List<Map<String, dynamic>>> getMonitoringItems() async {
    final remoteItems = await _api.getMonitoring();
    if (remoteItems.isNotEmpty) {
      final history = await _localDatasource.fetchAll();
      return remoteItems
          .map(
            (item) {
              final unitName = item['unit']?.toString() ??
                  item['unit_name']?.toString() ??
                  '-';
              final localLogsheet = history.cast<LogsheetModel?>().firstWhere(
                    (log) => log?.unitName == unitName,
                    orElse: () => null,
                  );
              return {
                'unit': unitName,
                'operator': item['operator'] ??
                    item['operator_name'] ??
                    localLogsheet?.operatorName ??
                    'Belum ada data',
                'lastSubmit': item['lastSubmit'] ??
                    item['last_submit'] ??
                    localLogsheet?.submittedAt,
                'reportStatus': item['reportStatus'] ??
                    item['report_status'] ??
                    localLogsheet?.reportStatus.name ??
                    ReportStatus.missing.name,
                'locationStatus': item['locationStatus'] ??
                    item['location_status'] ??
                    localLogsheet?.locationStatus.name ??
                    LocationStatus.unknown.name,
                'hasPhoto': item['hasPhoto'] ??
                    item['has_photo'] ??
                    ((localLogsheet?.machinePhotoPath.isNotEmpty ?? false) &&
                        (localLogsheet?.selfiePhotoPath.isNotEmpty ?? false)),
                'logsheet': localLogsheet,
              };
            },
          )
          .toList();
    }

    final history = await _localDatasource.fetchAll();
    return DummyData.units.map((unit) {
      final unitLogs = history.where((item) => item.unitId == unit.id).toList();
      final latest = unitLogs.isNotEmpty ? unitLogs.first : null;
      return {
        'unit': unit.name,
        'operator': latest?.operatorName ?? 'Belum ada data',
        'lastSubmit': latest?.submittedAt,
        'reportStatus': (latest?.reportStatus ?? ReportStatus.missing).name,
        'locationStatus':
            (latest?.locationStatus ?? LocationStatus.unknown).name,
        'hasPhoto': (latest?.machinePhotoPath.isNotEmpty ?? false) &&
            (latest?.selfiePhotoPath.isNotEmpty ?? false),
        'logsheet': latest,
      };
    }).toList();
  }

  Future<Map<String, Map<String, String>>> getHeatmap(DateTime date) async {
    final heatmap = DummyData.heatmap(date);
    final history = await _localDatasource.fetchAll();
    final sameDay = history.where((item) {
      return item.submittedAt.year == date.year &&
          item.submittedAt.month == date.month &&
          item.submittedAt.day == date.day;
    });

    for (final item in sameDay) {
      final slot = '${item.submittedAt.hour.toString().padLeft(2, '0')}:00';
      heatmap[item.unitId]?[slot] = switch (item.reportStatus) {
        ReportStatus.abnormal => 'warning',
        ReportStatus.late => 'warning',
        ReportStatus.missing => 'missing',
        ReportStatus.onTime => 'submitted',
      };
    }
    return heatmap;
  }

  Future<List<Map<String, dynamic>>> getReportRows() async {
    final remoteRows = await _api.getReports();
    if (remoteRows.isNotEmpty) {
      return remoteRows;
    }

    final history = await _localDatasource.fetchAll();
    return DummyData.units.map((unit) {
      final unitLogs = history.where((item) => item.unitId == unit.id).toList();
      return {
        'tanggal': DateHelper.formatDate(DateTime.now()),
        'unit': unit.name,
        'operator': unitLogs.isNotEmpty ? unitLogs.first.operatorName : '-',
        'jumlah': unitLogs.length,
        'tepatWaktu': unitLogs
            .where((item) => item.reportStatus == ReportStatus.onTime)
            .length,
        'terlambat': unitLogs
            .where((item) => item.reportStatus == ReportStatus.late)
            .length,
        'abnormal': unitLogs
            .where((item) => item.reportStatus == ReportStatus.abnormal)
            .length,
        'pending': unitLogs
            .where(
              (item) =>
                  item.syncStatus == SyncStatus.pendingSync ||
                  item.syncStatus == SyncStatus.pendingEdit,
            )
            .length,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final remoteNotifications = await _api.getNotifications();
    final pending = await _localDatasource.fetchPending();
    final items = [...remoteNotifications];
    if (pending.isNotEmpty) {
      items.insert(0, {
        'title': 'Masih ada data pending',
        'description':
            '${pending.length} logsheet menunggu sinkronisasi ke server.',
        'time': DateTime.now(),
        'priority': 'tinggi',
        'read': false,
        'type': 'sync',
      });
    }
    return items;
  }

  Future<List<LogsheetModel>> getAllLogsheets() => _localDatasource.fetchAll();

  bool _isToday(LogsheetModel item) {
    final now = DateTime.now();
    return item.submittedAt.year == now.year &&
        item.submittedAt.month == now.month &&
        item.submittedAt.day == now.day;
  }
}
