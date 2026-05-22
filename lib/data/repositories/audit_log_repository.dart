import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/hive_service.dart';
import '../models/audit_log_model.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return AuditLogRepository(ref.read(hiveServiceProvider));
});

class AuditLogRepository {
  AuditLogRepository(this._hiveService);

  final HiveService _hiveService;

  Future<void> save(AuditLogModel log) async {
    await _hiveService.auditLogBox.put(log.id, log.toJson());
  }

  Future<List<AuditLogModel>> getByEntityId(String entityId) async {
    final items = _hiveService.auditLogBox.values
        .whereType<Map>()
        .map((item) => AuditLogModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.entityId == entityId)
        .toList();
    items.sort((a, b) => b.editedAt.compareTo(a.editedAt));
    return items;
  }
}
