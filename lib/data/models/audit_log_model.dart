import 'app_enums.dart';

class AuditFieldChange {
  const AuditFieldChange({
    required this.field,
    required this.before,
    required this.after,
  });

  final String field;
  final String before;
  final String after;

  Map<String, dynamic> toJson() => {
    'field': field,
    'before': before,
    'after': after,
  };

  factory AuditFieldChange.fromJson(Map<String, dynamic> json) {
    return AuditFieldChange(
      field: json['field']?.toString() ?? '',
      before: json['before']?.toString() ?? '',
      after: json['after']?.toString() ?? '',
    );
  }
}

class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.entityId,
    required this.userId,
    required this.userName,
    required this.role,
    required this.editedAt,
    required this.syncStatus,
    required this.changes,
  });

  final String id;
  final String entityId;
  final String userId;
  final String userName;
  final UserRole role;
  final DateTime editedAt;
  final SyncStatus syncStatus;
  final List<AuditFieldChange> changes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityId': entityId,
    'userId': userId,
    'userName': userName,
    'role': role.name,
    'editedAt': editedAt.toIso8601String(),
    'syncStatus': syncStatus.name,
    'changes': changes.map((item) => item.toJson()).toList(),
  };

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    final changes = json['changes'];
    return AuditLogModel(
      id: json['id']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      role: parseUserRole(json['role']?.toString()),
      editedAt:
          DateTime.tryParse(json['editedAt']?.toString() ?? '') ?? DateTime.now(),
      syncStatus: parseSyncStatus(json['syncStatus']?.toString()),
      changes: changes is List
          ? changes
                .whereType<Map>()
                .map(
                  (item) => AuditFieldChange.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const <AuditFieldChange>[],
    );
  }
}
