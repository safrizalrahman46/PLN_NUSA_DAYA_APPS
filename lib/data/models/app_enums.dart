enum UserRole { operator, supervisor, admin, superadmin }

enum SyncStatus { draft, pendingSync, synced, failed }

enum LocationStatus { valid, outsideArea, permissionDenied, gpsOff, unknown }

enum ReportStatus { onTime, late, missing, abnormal }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.operator:
        return 'Operator';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superadmin:
        return 'Superadmin';
    }
  }
}

UserRole parseUserRole(String? value) => UserRole.values.firstWhere(
  (item) => item.name == value,
  orElse: () => UserRole.operator,
);

SyncStatus parseSyncStatus(String? value) => SyncStatus.values.firstWhere(
  (item) => item.name == value,
  orElse: () => SyncStatus.draft,
);

LocationStatus parseLocationStatus(String? value) =>
    LocationStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => LocationStatus.unknown,
    );

ReportStatus parseReportStatus(String? value) => ReportStatus.values.firstWhere(
  (item) => item.name == value,
  orElse: () => ReportStatus.onTime,
);
