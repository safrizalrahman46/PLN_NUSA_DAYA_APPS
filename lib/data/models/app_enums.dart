enum UserRole { operator, supervisor, admin, superadmin }

enum SyncStatus { draft, pendingSync, pendingEdit, synced, failed }

enum ApprovalStatus { pendingReview, approved, rejected }

enum LocationStatus { valid, outsideArea, permissionDenied, gpsOff, unknown }

enum ReportStatus { onTime, late, missing, abnormal }

enum MachineStatus { operasi, standby, gangguanRusak }

enum NotificationPriority { tinggi, sedang, rendah }

enum NotificationTargetType {
  notificationDetail,
  pendingList,
  logsheetDetail,
  editLogsheet,
  errorDetail,
  reportList,
  reportExport,
  unitDetail,
  retention,
}

enum ErrorLogStatus { baru, diproses, selesai }

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

extension MachineStatusX on MachineStatus {
  String get label {
    switch (this) {
      case MachineStatus.operasi:
        return 'Operasi';
      case MachineStatus.standby:
        return 'Standby';
      case MachineStatus.gangguanRusak:
        return 'Gangguan-Rusak';
    }
  }

  String get apiValue {
    switch (this) {
      case MachineStatus.operasi:
        return 'operasi';
      case MachineStatus.standby:
        return 'standby';
      case MachineStatus.gangguanRusak:
        return 'gangguan-rusak';
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

ApprovalStatus parseApprovalStatus(String? value) => ApprovalStatus.values
    .firstWhere(
      (item) => item.name == value,
      orElse: () => ApprovalStatus.pendingReview,
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

MachineStatus parseMachineStatus(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'operasi':
    case 'operation':
    case 'active':
    case 'beroperasi':
      return MachineStatus.operasi;
    case 'standby':
    case 'pemeliharaan':
    case 'maintenance':
      return MachineStatus.standby;
    case 'gangguan-rusak':
    case 'gangguan_rusak':
    case 'gangguan/rusak':
    case 'rusak permanen':
    case 'rusak sementara / gangguan':
    case 'rusak sementara/gangguan':
    case 'gangguan':
    case 'rusak':
    case 'trouble':
      return MachineStatus.gangguanRusak;
    default:
      return MachineStatus.operasi;
  }
}

extension ApprovalStatusX on ApprovalStatus {
  String get label {
    switch (this) {
      case ApprovalStatus.pendingReview:
        return 'Terkirim';
      case ApprovalStatus.approved:
        return 'Disetujui';
      case ApprovalStatus.rejected:
        return 'Ditolak';
    }
  }
}

extension NotificationPriorityX on NotificationPriority {
  String get label {
    switch (this) {
      case NotificationPriority.tinggi:
        return 'Tinggi';
      case NotificationPriority.sedang:
        return 'Sedang';
      case NotificationPriority.rendah:
        return 'Rendah';
    }
  }
}

extension ErrorLogStatusX on ErrorLogStatus {
  String get label {
    switch (this) {
      case ErrorLogStatus.baru:
        return 'Baru';
      case ErrorLogStatus.diproses:
        return 'Diproses';
      case ErrorLogStatus.selesai:
        return 'Selesai';
    }
  }
}

NotificationPriority parseNotificationPriority(String? value) =>
    NotificationPriority.values.firstWhere(
      (item) => item.name == value,
      orElse: () => NotificationPriority.sedang,
    );

NotificationTargetType parseNotificationTargetType(String? value) =>
    NotificationTargetType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => NotificationTargetType.notificationDetail,
    );

ErrorLogStatus parseErrorLogStatus(String? value) => ErrorLogStatus.values
    .firstWhere(
      (item) => item.name == value,
      orElse: () => ErrorLogStatus.baru,
    );
