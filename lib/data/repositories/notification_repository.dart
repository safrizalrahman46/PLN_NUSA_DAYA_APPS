import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../dummy/dummy_data.dart';
import '../local/hive_service.dart';
import '../local/local_logsheet_datasource.dart';
import '../models/app_enums.dart';
import '../models/app_notification_model.dart';
import '../models/user_model.dart';
import 'error_log_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    ref.read(hiveServiceProvider),
    ref.read(localLogsheetDatasourceProvider),
    ref.read(errorLogRepositoryProvider),
  );
});

class NotificationRepository {
  NotificationRepository(
    this._hiveService,
    this._localDatasource,
    this._errorLogRepository,
  );

  final HiveService _hiveService;
  final LocalLogsheetDatasource _localDatasource;
  final ErrorLogRepository _errorLogRepository;
  final _uuid = const Uuid();

  Future<void> save(AppNotificationModel item) async {
    await _hiveService.notificationBox.put(item.id, item.toJson());
  }

  Future<void> add({
    required String title,
    required String description,
    required NotificationPriority priority,
    required String type,
    required NotificationTargetType targetType,
    List<String> recipientRoles = const <String>[],
    String? userId,
    String? localId,
    String? errorLogId,
    String? unitId,
    Map<String, dynamic> payload = const {},
  }) async {
    await save(
      AppNotificationModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        time: DateTime.now(),
        priority: priority,
        type: type,
        targetType: targetType,
        recipientRoles: recipientRoles,
        userId: userId,
        localId: localId,
        errorLogId: errorLogId,
        unitId: unitId,
        payload: payload,
      ),
    );
  }

  Future<List<AppNotificationModel>> getNotifications(UserModel? user) async {
    await _seedIfNeeded();
    await _ensureSystemNotifications();

    final items = _hiveService.notificationBox.values
        .whereType<Map>()
        .map(
          (item) => AppNotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) {
          final matchUser = item.userId == null || item.userId == user?.id;
          final roles = item.recipientRoles;
          final matchRole = roles.isEmpty || roles.contains(user?.role.name);
          return matchUser && matchRole;
        })
        .toList();
    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  Future<void> markAsRead(String id) async {
    final raw = _hiveService.notificationBox.get(id);
    if (raw is! Map) return;
    final item = AppNotificationModel.fromJson(Map<String, dynamic>.from(raw));
    await save(item.copyWith(read: true));
  }

  Future<void> markAllAsRead() async {
    final keys = _hiveService.notificationBox.keys.toList();
    for (final key in keys) {
      final raw = _hiveService.notificationBox.get(key);
      if (raw is! Map) continue;
      final item = AppNotificationModel.fromJson(Map<String, dynamic>.from(raw));
      if (!item.read) {
        await save(item.copyWith(read: true));
      }
    }
  }

  Future<void> _seedIfNeeded() async {
    if (_hiveService.notificationBox.isNotEmpty) return;
    for (final raw in DummyData.notifications()) {
      await save(
        AppNotificationModel(
          id: _uuid.v4(),
          title: raw['title'].toString(),
          description: raw['description'].toString(),
          time: raw['time'] as DateTime? ?? DateTime.now(),
          priority: parseNotificationPriority(raw['priority']?.toString()),
          type: raw['type']?.toString() ?? 'general',
          targetType: _targetTypeFromLegacy(raw['type']?.toString()),
          read: raw['read'] == true,
          recipientRoles: const ['supervisor', 'admin', 'superadmin'],
        ),
      );
    }
  }

  Future<void> _ensureSystemNotifications() async {
    final pending = await _localDatasource.fetchPending();
    for (final item in pending) {
      final id = 'pending-${item.localId}';
      if (_hiveService.notificationBox.containsKey(id)) continue;
      await save(
        AppNotificationModel(
          id: id,
          title: item.syncStatus == SyncStatus.failed
              ? 'Sync gagal perlu ditinjau'
              : 'Data menunggu sinkronisasi',
          description:
              '${item.unitName} • ${item.machineShortLabel} • status ${item.lifecycleStatusLabel}.',
          time: item.updatedAt,
          priority: item.syncStatus == SyncStatus.failed
              ? NotificationPriority.tinggi
              : NotificationPriority.sedang,
          type: 'sync',
          targetType: item.canEdit
              ? NotificationTargetType.editLogsheet
              : NotificationTargetType.pendingList,
          userId: item.operatorId,
          localId: item.localId,
          unitId: item.unitId,
          recipientRoles: const ['operator'],
        ),
      );
    }

    final errors = await _errorLogRepository.getAll();
    for (final item in errors.take(20)) {
      final id = 'error-${item.id}';
      if (_hiveService.notificationBox.containsKey(id)) continue;
      await save(
        AppNotificationModel(
          id: id,
          title: 'Error ${item.errorType}',
          description: item.message,
          time: item.createdAt,
          priority: NotificationPriority.tinggi,
          type: 'error',
          targetType: NotificationTargetType.errorDetail,
          errorLogId: item.id,
          recipientRoles: const ['supervisor', 'admin', 'superadmin'],
        ),
      );
    }
  }

  NotificationTargetType _targetTypeFromLegacy(String? type) {
    switch (type) {
      case 'sync':
        return NotificationTargetType.pendingList;
      case 'abnormal':
        return NotificationTargetType.reportList;
      case 'gps':
        return NotificationTargetType.reportList;
      case 'missing':
        return NotificationTargetType.reportList;
      default:
        return NotificationTargetType.notificationDetail;
    }
  }
}
