import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/sync_feedback.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/date_helper.dart';
import '../dummy/dummy_data.dart';
import '../local/local_logsheet_datasource.dart';
import '../models/app_enums.dart';
import '../models/audit_log_model.dart';
import '../models/dashboard_summary_model.dart';
import '../models/logsheet_model.dart';
import '../models/user_model.dart';
import '../remote/logsheet_api.dart';
import 'audit_log_repository.dart';
import 'error_log_repository.dart';
import 'notification_repository.dart';

final logsheetRepositoryProvider = Provider<LogsheetRepository>((ref) {
  return LogsheetRepository(
    LogsheetApi(ref.read(dioProvider)),
    ref.read(localLogsheetDatasourceProvider),
    ref.read(networkInfoProvider),
    ref.read(auditLogRepositoryProvider),
    ref.read(notificationRepositoryProvider),
    ref.read(errorLogRepositoryProvider),
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

class SyncBatchResult {
  const SyncBatchResult({
    this.attemptedCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.deferredCount = 0,
    this.offline = false,
    this.unstableConnection = false,
  });

  final int attemptedCount;
  final int successCount;
  final int failureCount;
  final int deferredCount;
  final bool offline;
  final bool unstableConnection;

  bool get hasFailures => failureCount > 0;

  SyncMessageTone get tone {
    if (offline || unstableConnection) {
      return SyncMessageTone.warning;
    }
    if (successCount > 0 && failureCount == 0) {
      return SyncMessageTone.success;
    }
    if (failureCount > 0) {
      return successCount > 0 ? SyncMessageTone.warning : SyncMessageTone.error;
    }
    return SyncMessageTone.neutral;
  }

  String get message {
    if (offline) {
      return 'Perangkat belum online. Data tetap aman di antrian upload.';
    }
    if (unstableConnection) {
      if (successCount > 0) {
        return '$successCount logsheet berhasil disinkronkan, $deferredCount lainnya ditunda karena jaringan/server belum stabil.';
      }
      return 'Jaringan atau server belum stabil. Data tetap aman dan akan dicoba lagi saat koneksi membaik.';
    }
    if (attemptedCount == 0) {
      return 'Tidak ada data yang perlu disinkronkan.';
    }
    if (successCount > 0 && failureCount == 0) {
      return '$successCount logsheet berhasil disinkronkan.';
    }
    if (successCount > 0 && failureCount > 0) {
      return '$successCount logsheet berhasil disinkronkan, $failureCount lainnya masih gagal.';
    }
    if (deferredCount > 0) {
      return '$deferredCount logsheet tetap diantrekan untuk dicoba ulang otomatis.';
    }
    return 'Sinkronisasi belum berhasil. Data tetap aman di antrian upload.';
  }
}

class LogsheetRepository {
  LogsheetRepository(
    this._api,
    this._localDatasource,
    this._networkInfo,
    this._auditLogRepository,
    this._notificationRepository,
    this._errorLogRepository,
  );

  final LogsheetApi _api;
  final LocalLogsheetDatasource _localDatasource;
  final NetworkInfo _networkInfo;
  final AuditLogRepository _auditLogRepository;
  final NotificationRepository _notificationRepository;
  final ErrorLogRepository _errorLogRepository;

  Future<DashboardSummaryModel> getOperatorSummary([String? operatorId]) async {
    final history = await getHistory(operatorId: operatorId);
    final today = DateTime.now();
    final todayHistory = history.where((item) {
      return item.submittedAt.year == today.year &&
          item.submittedAt.month == today.month &&
          item.submittedAt.day == today.day;
    });

    return DashboardSummaryModel(
      todayReports: todayHistory.length,
      pendingSync: history
          .where(
            (item) =>
                item.syncStatus == SyncStatus.pendingSync ||
                item.syncStatus == SyncStatus.pendingEdit,
          )
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

  Future<List<LogsheetModel>> getHistory({String? operatorId}) async {
    final localItems = await _localDatasource.fetchAll();
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return _filterByOperator(localItems, operatorId);
    }

    try {
      final remoteItems = await _api.getHistory();
      final merged = _mergeHistory(localItems, remoteItems);
      return _filterByOperator(merged, operatorId);
    } catch (_) {
      return _filterByOperator(localItems, operatorId);
    }
  }

  Future<List<LogsheetModel>> getPendingUploads({String? operatorId}) async {
    final items = await _localDatasource.fetchPending();
    if (operatorId == null || operatorId.isEmpty) {
      return items;
    }
    return items.where((item) => item.operatorId == operatorId).toList();
  }

  Future<LogsheetModel?> getByLocalId(String localId) {
    return _localDatasource.getByLocalId(localId);
  }

  Future<void> delete(String localId) {
    return _localDatasource.delete(localId);
  }

  Future<SubmissionResult> saveDraft(
    LogsheetModel logsheet, {
    LogsheetModel? previous,
    UserModel? editor,
  }) async {
    final base = previous == null
        ? logsheet
        : logsheet.copyWith(
            id: previous.id,
            createdAt: previous.createdAt,
            approvalStatus: previous.approvalStatus,
            rejectionReason: previous.rejectionReason,
          );
    final draft = base.copyWith(
      syncStatus: SyncStatus.draft,
      updatedAt: DateTime.now(),
      syncErrorMessage: null,
      proofId: base.proofId.isEmpty
          ? DummyData.generateProofId(DateTime.now())
          : base.proofId,
    );
    await _localDatasource.save(draft);
    await _recordAudit(previous: previous, next: draft, editor: editor);
    return SubmissionResult(
      logsheet: draft,
      message: 'Draft logsheet berhasil disimpan.',
      synced: false,
    );
  }

  Future<SubmissionResult> submit(
    LogsheetModel logsheet, {
    LogsheetModel? previous,
    UserModel? editor,
  }) async {
    final connected = await _networkInfo.isConnected;
    final now = DateTime.now();
    final base = previous == null
        ? logsheet
        : logsheet.copyWith(
            id: previous.id,
            createdAt: previous.createdAt,
            approvalStatus: previous.approvalStatus,
            rejectionReason: previous.rejectionReason,
          );

    final request = base.copyWith(
      submittedAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.synced,
      approvalStatus: ApprovalStatus.pendingReview,
      rejectionReason: '',
      syncErrorMessage: null,
      proofId: base.proofId.isEmpty
          ? DummyData.generateProofId(now)
          : base.proofId,
    );

    if (!connected) {
      final pending = await _storePendingSubmission(
        request,
        previous: previous,
        editor: editor,
      );
      return SubmissionResult(
        logsheet: pending,
        message: 'Logsheet disimpan offline dan menunggu sinkronisasi.',
        synced: false,
      );
    }

    try {
      final response = await _api.submitLogsheet(request);
      final synced = _mergeSyncedLogsheet(
        request: request,
        response: response,
        syncedAt: now,
      );
      await _localDatasource.save(synced);
      await _recordAudit(previous: previous, next: synced, editor: editor);
      await _notificationRepository.add(
        title: 'Logsheet berhasil terkirim',
        description:
            '${synced.unitName} • ${synced.machineShortLabel} berhasil dikirim ke server.',
        priority: NotificationPriority.rendah,
        type: 'sync',
        targetType: NotificationTargetType.logsheetDetail,
        userId: synced.operatorId,
        localId: synced.localId,
        unitId: synced.unitId,
        recipientRoles: const ['operator'],
      );
      return SubmissionResult(
        logsheet: synced,
        message: 'Logsheet berhasil dikirim.',
        synced: true,
      );
    } catch (error, stackTrace) {
      final apiError = ApiException.fromObject(
        error,
        fallbackMessage: 'Gagal mengirim logsheet ke server.',
      );
      if (apiError.shouldQueueForRetry) {
        final pending = await _storePendingSubmission(
          request,
          previous: previous,
          editor: editor,
          syncErrorMessage: _friendlyPendingReason(apiError),
        );
        await _errorLogRepository.logException(
          error: error,
          stackTrace: stackTrace,
          page: 'submit.logsheet',
          detail:
              'Submit realtime dialihkan ke Pending Upload untuk ${request.proofId}.',
          metadata: {
            'localId': request.localId,
            'unitId': request.unitId,
            'operatorId': request.operatorId,
            'reason': apiError.message,
          },
        );
        return SubmissionResult(
          logsheet: pending,
          message:
              'Koneksi ke server sedang lambat. Data disimpan aman dan masuk ke Pending Upload.',
          synced: false,
        );
      }
      rethrow;
    }
  }

  Future<SyncBatchResult> syncPendingLogsheets({String? localId}) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return const SyncBatchResult(offline: true);
    }

    final pending = await getPendingUploads();
    final queuedItems = pending.where((log) {
      if (log.syncStatus == SyncStatus.draft) {
        return false;
      }
      if (localId == null || localId.isEmpty) {
        return true;
      }
      return log.localId == localId;
    }).toList();

    var successCount = 0;
    var failureCount = 0;
    var deferredCount = 0;

    for (var index = 0; index < queuedItems.length; index++) {
      final item = queuedItems[index];
      final now = DateTime.now();
      try {
        final request = item.copyWith(
          syncStatus: SyncStatus.synced,
          updatedAt: now,
          syncErrorMessage: null,
        );
        final response = await _api.submitLogsheet(request);
        final synced = _mergeSyncedLogsheet(
          request: request,
          response: response,
          syncedAt: now,
        );
        await _localDatasource.save(synced);
        await _notificationRepository.add(
          title: 'Sinkronisasi berhasil',
          description:
              '${synced.unitName} • ${synced.machineShortLabel} berhasil disinkronkan.',
          priority: NotificationPriority.rendah,
          type: 'sync',
          targetType: NotificationTargetType.logsheetDetail,
          userId: synced.operatorId,
          localId: synced.localId,
          unitId: synced.unitId,
          recipientRoles: const ['operator'],
        );
        successCount++;
      } catch (error, stackTrace) {
        final apiError = ApiException.fromObject(
          error,
          fallbackMessage: 'Gagal menyinkronkan logsheet ke server.',
        );
        if (apiError.shouldQueueForRetry) {
          final reason = _friendlyPendingReason(apiError);
          final queued = _restoreQueuedSubmission(
            item,
            reason: reason,
            updatedAt: now,
          );
          await _localDatasource.save(queued);
          deferredCount++;

          for (final remaining in queuedItems.skip(index + 1)) {
            final restored = _restoreQueuedSubmission(
              remaining,
              reason: reason,
              updatedAt: now,
            );
            await _localDatasource.save(restored);
            deferredCount++;
          }

          return SyncBatchResult(
            attemptedCount: queuedItems.length,
            successCount: successCount,
            failureCount: failureCount,
            deferredCount: deferredCount,
            unstableConnection: true,
          );
        }

        final failed = item.copyWith(
          syncStatus: SyncStatus.failed,
          updatedAt: now,
          syncErrorMessage: _friendlySyncFailureMessage(apiError),
        );
        await _localDatasource.save(failed);
        await _notificationRepository.add(
          title: 'Sinkronisasi gagal',
          description:
              '${item.unitName} • ${item.machineShortLabel} gagal dikirim. Buka detail untuk melihat error.',
          priority: NotificationPriority.tinggi,
          type: 'sync',
          targetType: NotificationTargetType.editLogsheet,
          userId: item.operatorId,
          localId: item.localId,
          unitId: item.unitId,
          recipientRoles: const ['operator'],
        );
        await _errorLogRepository.logException(
          error: error,
          stackTrace: stackTrace,
          page: 'syncPendingLogsheets',
          detail:
              'Gagal sinkronisasi untuk ${item.proofId} (${item.unitName} • ${item.machineShortLabel}).',
          metadata: {
            'localId': item.localId,
            'unitId': item.unitId,
            'operatorId': item.operatorId,
          },
        );
        failureCount++;
      }
    }

    return SyncBatchResult(
      attemptedCount: queuedItems.length,
      successCount: successCount,
      failureCount: failureCount,
      deferredCount: deferredCount,
    );
  }

  Future<LogsheetModel?> updateApproval(
    String localId,
    ApprovalStatus approvalStatus, {
    String rejectionReason = '',
  }) async {
    final existing = await _localDatasource.getByLocalId(localId);
    if (existing == null) return null;
    final updated = existing.copyWith(
      approvalStatus: approvalStatus,
      rejectionReason: rejectionReason,
      updatedAt: DateTime.now(),
    );
    await _localDatasource.save(updated);
    await _notificationRepository.add(
      title: approvalStatus == ApprovalStatus.approved
          ? 'Data disetujui supervisor'
          : 'Data ditolak supervisor',
      description: approvalStatus == ApprovalStatus.approved
          ? '${existing.unitName} • ${existing.machineShortLabel} telah disetujui.'
          : '${existing.unitName} • ${existing.machineShortLabel} ditolak. ${rejectionReason.isEmpty ? 'Buka detail untuk alasan penolakan.' : rejectionReason}',
      priority: approvalStatus == ApprovalStatus.approved
          ? NotificationPriority.rendah
          : NotificationPriority.tinggi,
      type: 'approval',
      targetType: NotificationTargetType.logsheetDetail,
      userId: existing.operatorId,
      localId: existing.localId,
      unitId: existing.unitId,
      recipientRoles: const ['operator'],
    );
    return updated;
  }

  Future<void> _recordAudit({
    required LogsheetModel? previous,
    required LogsheetModel next,
    required UserModel? editor,
  }) async {
    if (previous == null || editor == null) return;
    final before = previous.toJson();
    final after = next.toJson();
    final changes = <AuditFieldChange>[];
    for (final entry in after.entries) {
      if (entry.key == 'updatedAt' || entry.key == 'lastEditedAt') continue;
      final beforeValue = before[entry.key]?.toString() ?? '';
      final afterValue = entry.value?.toString() ?? '';
      if (beforeValue != afterValue) {
        changes.add(
          AuditFieldChange(
            field: entry.key,
            before: beforeValue,
            after: afterValue,
          ),
        );
      }
    }

    if (changes.isEmpty) return;
    await _auditLogRepository.save(
      AuditLogModel(
        id: '${next.localId}-${next.updatedAt.microsecondsSinceEpoch}',
        entityId: next.localId,
        userId: editor.id,
        userName: editor.name,
        role: editor.role,
        editedAt: next.updatedAt,
        syncStatus: next.syncStatus,
        changes: changes,
      ),
    );
  }

  Future<LogsheetModel> _storePendingSubmission(
    LogsheetModel request, {
    required LogsheetModel? previous,
    required UserModel? editor,
    String? syncErrorMessage,
  }) async {
    final pending = request.copyWith(
      syncStatus: previous != null && previous.syncStatus == SyncStatus.synced
          ? SyncStatus.pendingEdit
          : SyncStatus.pendingSync,
      approvalStatus: ApprovalStatus.pendingReview,
      rejectionReason: '',
      updatedAt: DateTime.now(),
      syncErrorMessage: syncErrorMessage,
    );
    await _localDatasource.save(pending);
    await _recordAudit(previous: previous, next: pending, editor: editor);
    await _notificationRepository.add(
      title: 'Data disimpan untuk sinkronisasi',
      description:
          '${pending.unitName} • ${pending.machineShortLabel} akan dikirim otomatis saat koneksi kembali online.',
      priority: NotificationPriority.sedang,
      type: 'sync',
      targetType: NotificationTargetType.editLogsheet,
      userId: pending.operatorId,
      localId: pending.localId,
      unitId: pending.unitId,
      recipientRoles: const ['operator'],
    );
    return pending;
  }

  LogsheetModel _restoreQueuedSubmission(
    LogsheetModel logsheet, {
    required String reason,
    required DateTime updatedAt,
  }) {
    return logsheet.copyWith(
      syncStatus: logsheet.syncStatus == SyncStatus.pendingEdit
          ? SyncStatus.pendingEdit
          : SyncStatus.pendingSync,
      updatedAt: updatedAt,
      syncErrorMessage: reason,
    );
  }

  LogsheetModel _mergeSyncedLogsheet({
    required LogsheetModel request,
    required LogsheetModel response,
    required DateTime syncedAt,
  }) {
    return request.copyWith(
      id: response.id.isEmpty ? request.id : response.id,
      proofId: response.proofId.isEmpty ? request.proofId : response.proofId,
      sessionId: response.sessionId.isEmpty
          ? request.sessionId
          : response.sessionId,
      approvalStatus: response.approvalStatus,
      rejectionReason: response.rejectionReason.isEmpty
          ? request.rejectionReason
          : response.rejectionReason,
      lastEditedBy: response.lastEditedBy.isEmpty
          ? request.lastEditedBy
          : response.lastEditedBy,
      lastEditedAt: response.lastEditedAt ?? request.lastEditedAt,
      archivedAt: response.archivedAt ?? request.archivedAt,
      syncStatus: SyncStatus.synced,
      syncErrorMessage: null,
      submittedAt: response.submittedAt,
      updatedAt: syncedAt,
    );
  }

  List<LogsheetModel> _mergeHistory(
    List<LogsheetModel> localItems,
    List<LogsheetModel> remoteItems,
  ) {
    final merged = <String, LogsheetModel>{};
    for (final item in [...remoteItems, ...localItems]) {
      final key = _historyKey(item);
      final existing = merged[key];
      if (existing == null || item.updatedAt.isAfter(existing.updatedAt)) {
        merged[key] = item;
      }
    }
    final values = merged.values.toList();
    values.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return values;
  }

  String _historyKey(LogsheetModel item) {
    if (item.id.trim().isNotEmpty) {
      return 'id:${item.id.trim()}';
    }
    if (item.localId.trim().isNotEmpty) {
      return 'local:${item.localId.trim()}';
    }
    if (item.proofId.trim().isNotEmpty) {
      return 'proof:${item.proofId.trim()}';
    }
    return '${item.unitId}-${item.machineId}-${item.submittedAt.toIso8601String()}';
  }

  List<LogsheetModel> _filterByOperator(
    List<LogsheetModel> items,
    String? operatorId,
  ) {
    if (operatorId == null || operatorId.isEmpty) {
      return items;
    }
    return items.where((item) => item.operatorId == operatorId).toList();
  }

  String _friendlyPendingReason(ApiException error) {
    switch (error.type) {
      case ApiExceptionType.timeout:
        return 'Server terlalu lama merespons. Data disimpan aman dan menunggu retry.';
      case ApiExceptionType.connection:
        return 'Koneksi ke server terputus. Data disimpan aman dan menunggu retry.';
      default:
        return error.message;
    }
  }

  String _friendlySyncFailureMessage(ApiException error) {
    switch (error.type) {
      case ApiExceptionType.timeout:
        return 'Server terlalu lama merespons. Coba sync lagi saat jaringan stabil.';
      case ApiExceptionType.connection:
        return 'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.';
      case ApiExceptionType.server:
        return 'Server sedang bermasalah. Coba ulang beberapa saat lagi.';
      default:
        return error.message;
    }
  }
}
