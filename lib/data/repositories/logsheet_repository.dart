import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/date_helper.dart';
import '../dummy/dummy_data.dart';
import '../local/local_logsheet_datasource.dart';
import '../models/app_enums.dart';
import '../models/dashboard_summary_model.dart';
import '../models/logsheet_model.dart';
import '../remote/logsheet_api.dart';

final logsheetRepositoryProvider = Provider<LogsheetRepository>((ref) {
  return LogsheetRepository(
    LogsheetApi(ref.read(dioProvider)),
    ref.read(localLogsheetDatasourceProvider),
    ref.read(networkInfoProvider),
  );
});

class SubmissionResult {
  const SubmissionResult({
    required this.logsheet,
    required this.message,
    required this.synced,
  });

  final LogsheetModel logsheet;
  final String message;
  final bool synced;
}

class LogsheetRepository {
  LogsheetRepository(this._api, this._localDatasource, this._networkInfo);

  final LogsheetApi _api;
  final LocalLogsheetDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  Future<DashboardSummaryModel> getOperatorSummary() async {
    final history = await getHistory();
    final today = DateTime.now();
    final todayHistory = history.where((item) {
      return item.submittedAt.year == today.year &&
          item.submittedAt.month == today.month &&
          item.submittedAt.day == today.day;
    });

    return DashboardSummaryModel(
      todayReports: todayHistory.length,
      pendingSync: history
          .where((item) => item.syncStatus == SyncStatus.pendingSync)
          .length,
      successReports: todayHistory
          .where((item) => item.syncStatus == SyncStatus.synced)
          .length,
      abnormalReports: todayHistory
          .where((item) => item.reportStatus == ReportStatus.abnormal)
          .length,
      totalUnits: DummyData.units.length,
      totalOperators: DummyData.users.where((item) => item.isOperator).length,
      lateOperators: todayHistory
          .where((item) => item.reportStatus == ReportStatus.late)
          .length,
      nextReportAt: DateHelper.nextReportTime(),
    );
  }

  Future<List<LogsheetModel>> getHistory() => _localDatasource.fetchAll();

  Future<List<LogsheetModel>> getPendingUploads() =>
      _localDatasource.fetchPending();

  Future<SubmissionResult> saveDraft(LogsheetModel logsheet) async {
    final draft = logsheet.copyWith(
      syncStatus: SyncStatus.draft,
      updatedAt: DateTime.now(),
      proofId: logsheet.proofId.isEmpty
          ? DummyData.generateProofId(DateTime.now())
          : logsheet.proofId,
    );
    await _localDatasource.save(draft);
    return SubmissionResult(
      logsheet: draft,
      message: 'Draft logsheet berhasil disimpan.',
      synced: false,
    );
  }

  Future<SubmissionResult> submit(LogsheetModel logsheet) async {
    final connected = await _networkInfo.isConnected;
    final now = DateTime.now();

    if (!connected) {
      final pending = logsheet.copyWith(
        syncStatus: SyncStatus.pendingSync,
        submittedAt: now,
        updatedAt: now,
        proofId: logsheet.proofId.isEmpty
            ? DummyData.generateProofId(now)
            : logsheet.proofId,
      );
      await _localDatasource.save(pending);
      return SubmissionResult(
        logsheet: pending,
        message: 'Logsheet disimpan offline dan menunggu sinkronisasi.',
        synced: false,
      );
    }

    final synced = await _api.submitLogsheet(
      logsheet.copyWith(
        submittedAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.synced,
        proofId: logsheet.proofId.isEmpty
            ? DummyData.generateProofId(now)
            : logsheet.proofId,
      ),
    );
    await _localDatasource.save(synced);
    return SubmissionResult(
      logsheet: synced,
      message: 'Logsheet berhasil dikirim.',
      synced: true,
    );
  }

  Future<int> syncPendingLogsheets() async {
    final connected = await _networkInfo.isConnected;
    if (!connected) return 0;

    final pending = await getPendingUploads();
    var successCount = 0;

    for (final item in pending.where(
      (log) => log.syncStatus != SyncStatus.draft,
    )) {
      try {
        final synced = await _api.submitLogsheet(
          item.copyWith(
            syncStatus: SyncStatus.synced,
            updatedAt: DateTime.now(),
          ),
        );
        await _localDatasource.save(synced.copyWith(syncErrorMessage: null));
        successCount++;
      } catch (error) {
        await _localDatasource.save(
          item.copyWith(
            syncStatus: SyncStatus.failed,
            updatedAt: DateTime.now(),
            syncErrorMessage: error.toString(),
          ),
        );
      }
    }

    return successCount;
  }
}
