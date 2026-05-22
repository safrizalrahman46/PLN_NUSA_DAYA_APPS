import '../../core/utils/number_helper.dart';

import 'app_enums.dart';

class LogsheetModel {
  const LogsheetModel({
    required this.id,
    required this.localId,
    required this.proofId,
    required this.operatorId,
    required this.operatorName,
    required this.unitId,
    required this.unitName,
    required this.machineId,
    required this.machineUp3,
    required this.machineName,
    required this.machineBrand,
    required this.machineType,
    required this.serialNumber,
    required this.machineGeneratorCode,
    required this.machineOwnershipStatus,
    required this.machinePerformanceLabel,
    required this.machineInstalledCapacity,
    required this.machineAvailableCapacity,
    required this.machineDispatchCapacity,
    required this.machineConditionLabel,
    required this.machineStatus,
    required this.bebanMesin,
    required this.standKwh,
    required this.standBbm,
    required this.tekananOli,
    required this.temperaturAir,
    required this.phasaR,
    required this.phasaS,
    required this.phasaT,
    required this.tegangan,
    required this.cosPhi,
    required this.frequency,
    required this.notes,
    required this.selfiePhotoPath,
    required this.machinePhotoPath,
    required this.latitude,
    required this.longitude,
    required this.locationAccuracy,
    required this.distanceFromUnit,
    required this.locationStatus,
    required this.submittedAt,
    required this.syncStatus,
    required this.reportStatus,
    required this.abnormalNotes,
    required this.createdAt,
    required this.updatedAt,
    this.fieldCondition = '',
    this.syncErrorMessage,
    this.approvalStatus = ApprovalStatus.pendingReview,
    this.rejectionReason = '',
    this.sessionId = '',
    this.lastEditedBy = '',
    this.lastEditedAt,
    this.archivedAt,
  });

  final String id;
  final String localId;
  final String proofId;
  final String operatorId;
  final String operatorName;
  final String unitId;
  final String unitName;
  final String machineId;
  final String machineUp3;
  final String machineName;
  final String machineBrand;
  final String machineType;
  final String serialNumber;
  final String machineGeneratorCode;
  final String machineOwnershipStatus;
  final String machinePerformanceLabel;
  final String machineInstalledCapacity;
  final String machineAvailableCapacity;
  final String machineDispatchCapacity;
  final String machineConditionLabel;
  final MachineStatus machineStatus;
  final double bebanMesin;
  final double standKwh;
  final double standBbm;
  final double tekananOli;
  final double temperaturAir;
  final double phasaR;
  final double phasaS;
  final double phasaT;
  final double tegangan;
  final double cosPhi;
  final double frequency;
  final String notes;
  final String selfiePhotoPath;
  final String machinePhotoPath;
  final double latitude;
  final double longitude;
  final double locationAccuracy;
  final double distanceFromUnit;
  final LocationStatus locationStatus;
  final DateTime submittedAt;
  final SyncStatus syncStatus;
  final ReportStatus reportStatus;
  final String abnormalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String fieldCondition;
  final String? syncErrorMessage;
  final ApprovalStatus approvalStatus;
  final String rejectionReason;
  final String sessionId;
  final String lastEditedBy;
  final DateTime? lastEditedAt;
  final DateTime? archivedAt;

  bool get isAbnormal =>
      reportStatus == ReportStatus.abnormal || abnormalNotes.isNotEmpty;

  bool get isRejected => approvalStatus == ApprovalStatus.rejected;

  bool get isApproved => approvalStatus == ApprovalStatus.approved;

  bool get canEdit =>
      syncStatus == SyncStatus.draft ||
      syncStatus == SyncStatus.pendingSync ||
      syncStatus == SyncStatus.pendingEdit ||
      syncStatus == SyncStatus.failed ||
      approvalStatus == ApprovalStatus.rejected;

  String get lifecycleStatusLabel {
    if (approvalStatus == ApprovalStatus.approved) {
      return approvalStatus.label;
    }
    if (approvalStatus == ApprovalStatus.rejected) {
      return approvalStatus.label;
    }
    switch (syncStatus) {
      case SyncStatus.draft:
        return 'Draft';
      case SyncStatus.pendingSync:
        return 'Pending Sync';
      case SyncStatus.pendingEdit:
        return 'Pending Edit';
      case SyncStatus.synced:
        return approvalStatus.label;
      case SyncStatus.failed:
        return 'Sync Gagal';
    }
  }

  String get machineDisplayName =>
      machineName.trim().isEmpty ? serialNumber : machineName;

  String get machineIdentity {
    final parts = <String>[
      if (machineBrand.trim().isNotEmpty) machineBrand.trim(),
      if (machineType.trim().isNotEmpty) machineType.trim(),
      if (serialNumber.trim().isNotEmpty) 'SN ${serialNumber.trim()}',
    ];
    return parts.join(' • ');
  }

  String get machineCapacityInfo {
    final parts = <String>[
      if (machineInstalledCapacity.trim().isNotEmpty)
        'Terpasang ${machineInstalledCapacity.trim()}',
      if (machineAvailableCapacity.trim().isNotEmpty)
        'DMN ${machineAvailableCapacity.trim()}',
      if (machineDispatchCapacity.trim().isNotEmpty)
        'Pasok ${machineDispatchCapacity.trim()}',
    ];
    return parts.join(' • ');
  }

  String get machineMasterInfo {
    final parts = <String>[
      if (machineUp3.trim().isNotEmpty) machineUp3.trim(),
      if (machineGeneratorCode.trim().isNotEmpty) machineGeneratorCode.trim(),
      if (machineOwnershipStatus.trim().isNotEmpty)
        'Milik ${machineOwnershipStatus.trim()}',
      if (machinePerformanceLabel.trim().isNotEmpty)
        'Kinerja ${machinePerformanceLabel.trim()}',
      if (machineConditionLabel.trim().isNotEmpty) machineConditionLabel.trim(),
    ];
    return parts.join(' • ');
  }

  String get machineShortLabel {
    final match = RegExp(r'#\d+').firstMatch(machineDisplayName);
    if (match != null) {
      return match.group(0)!;
    }
    if (machineBrand.trim().isNotEmpty) {
      return machineBrand.trim();
    }
    return serialNumber.trim().isEmpty ? '-' : serialNumber.trim();
  }

  LogsheetModel copyWith({
    String? id,
    String? localId,
    String? proofId,
    String? operatorId,
    String? operatorName,
    String? unitId,
    String? unitName,
    String? machineId,
    String? machineUp3,
    String? machineName,
    String? machineBrand,
    String? machineType,
    String? serialNumber,
    String? machineGeneratorCode,
    String? machineOwnershipStatus,
    String? machinePerformanceLabel,
    String? machineInstalledCapacity,
    String? machineAvailableCapacity,
    String? machineDispatchCapacity,
    String? machineConditionLabel,
    MachineStatus? machineStatus,
    double? bebanMesin,
    double? standKwh,
    double? standBbm,
    double? tekananOli,
    double? temperaturAir,
    double? phasaR,
    double? phasaS,
    double? phasaT,
    double? tegangan,
    double? cosPhi,
    double? frequency,
    String? notes,
    String? selfiePhotoPath,
    String? machinePhotoPath,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromUnit,
    LocationStatus? locationStatus,
    DateTime? submittedAt,
    SyncStatus? syncStatus,
    ReportStatus? reportStatus,
    String? abnormalNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fieldCondition,
    String? syncErrorMessage,
    ApprovalStatus? approvalStatus,
    String? rejectionReason,
    String? sessionId,
    String? lastEditedBy,
    DateTime? lastEditedAt,
    DateTime? archivedAt,
  }) {
    return LogsheetModel(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      proofId: proofId ?? this.proofId,
      operatorId: operatorId ?? this.operatorId,
      operatorName: operatorName ?? this.operatorName,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      machineId: machineId ?? this.machineId,
      machineUp3: machineUp3 ?? this.machineUp3,
      machineName: machineName ?? this.machineName,
      machineBrand: machineBrand ?? this.machineBrand,
      machineType: machineType ?? this.machineType,
      serialNumber: serialNumber ?? this.serialNumber,
      machineGeneratorCode: machineGeneratorCode ?? this.machineGeneratorCode,
      machineOwnershipStatus:
          machineOwnershipStatus ?? this.machineOwnershipStatus,
      machinePerformanceLabel:
          machinePerformanceLabel ?? this.machinePerformanceLabel,
      machineInstalledCapacity:
          machineInstalledCapacity ?? this.machineInstalledCapacity,
      machineAvailableCapacity:
          machineAvailableCapacity ?? this.machineAvailableCapacity,
      machineDispatchCapacity:
          machineDispatchCapacity ?? this.machineDispatchCapacity,
      machineConditionLabel:
          machineConditionLabel ?? this.machineConditionLabel,
      machineStatus: machineStatus ?? this.machineStatus,
      bebanMesin: bebanMesin ?? this.bebanMesin,
      standKwh: standKwh ?? this.standKwh,
      standBbm: standBbm ?? this.standBbm,
      tekananOli: tekananOli ?? this.tekananOli,
      temperaturAir: temperaturAir ?? this.temperaturAir,
      phasaR: phasaR ?? this.phasaR,
      phasaS: phasaS ?? this.phasaS,
      phasaT: phasaT ?? this.phasaT,
      tegangan: tegangan ?? this.tegangan,
      cosPhi: cosPhi ?? this.cosPhi,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      selfiePhotoPath: selfiePhotoPath ?? this.selfiePhotoPath,
      machinePhotoPath: machinePhotoPath ?? this.machinePhotoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      distanceFromUnit: distanceFromUnit ?? this.distanceFromUnit,
      locationStatus: locationStatus ?? this.locationStatus,
      submittedAt: submittedAt ?? this.submittedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      reportStatus: reportStatus ?? this.reportStatus,
      abnormalNotes: abnormalNotes ?? this.abnormalNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fieldCondition: fieldCondition ?? this.fieldCondition,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      sessionId: sessionId ?? this.sessionId,
      lastEditedBy: lastEditedBy ?? this.lastEditedBy,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'localId': localId,
    'proofId': proofId,
    'operatorId': operatorId,
    'operatorName': operatorName,
    'unitId': unitId,
    'unitName': unitName,
    'machineId': machineId,
    'machineUp3': machineUp3,
    'up3': machineUp3,
    'machineName': machineName,
    'name': machineName,
    'machineBrand': machineBrand,
    'brand': machineBrand,
    'machineType': machineType,
    'type': machineType,
    'serialNumber': serialNumber,
    'machineGeneratorCode': machineGeneratorCode,
    'generatorCode': machineGeneratorCode,
    'machineOwnershipStatus': machineOwnershipStatus,
    'ownershipStatus': machineOwnershipStatus,
    'machinePerformanceLabel': machinePerformanceLabel,
    'performanceLabel': machinePerformanceLabel,
    'machineInstalledCapacity': machineInstalledCapacity,
    'installedCapacity': machineInstalledCapacity,
    'machineAvailableCapacity': machineAvailableCapacity,
    'availableCapacity': machineAvailableCapacity,
    'machineDispatchCapacity': machineDispatchCapacity,
    'dispatchCapacity': machineDispatchCapacity,
    'machineConditionLabel': machineConditionLabel,
    'conditionLabel': machineConditionLabel,
    'machineStatus': machineStatus.apiValue,
    'status': machineStatus.apiValue,
    'bebanMesin': bebanMesin,
    'standKwh': standKwh,
    'standBbm': standBbm,
    'tekananOli': tekananOli,
    'temperaturAir': temperaturAir,
    'phasaR': phasaR,
    'phasaS': phasaS,
    'phasaT': phasaT,
    'tegangan': tegangan,
    'cosPhi': cosPhi,
    'frequency': frequency,
    'notes': notes,
    'selfiePhotoPath': selfiePhotoPath,
    'machinePhotoPath': machinePhotoPath,
    'latitude': latitude,
    'longitude': longitude,
    'locationAccuracy': locationAccuracy,
    'distanceFromUnit': distanceFromUnit,
    'locationStatus': locationStatus.name,
    'submittedAt': submittedAt.toIso8601String(),
    'syncStatus': syncStatus.name,
    'reportStatus': reportStatus.name,
    'abnormalNotes': abnormalNotes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'fieldCondition': fieldCondition,
    'syncErrorMessage': syncErrorMessage,
    'approvalStatus': approvalStatus.name,
    'rejectionReason': rejectionReason,
    'sessionId': sessionId,
    'lastEditedBy': lastEditedBy,
    'lastEditedAt': lastEditedAt?.toIso8601String(),
    'archivedAt': archivedAt?.toIso8601String(),
  };

  factory LogsheetModel.fromJson(Map<String, dynamic> json) {
    return LogsheetModel(
      id: json['id']?.toString() ?? '',
      localId: json['localId']?.toString() ?? '',
      proofId: json['proofId']?.toString() ?? '',
      operatorId: json['operatorId']?.toString() ?? '',
      operatorName: json['operatorName']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      unitName: json['unitName']?.toString() ?? '',
      machineId: json['machineId']?.toString() ?? '',
      machineUp3:
          json['machineUp3']?.toString() ?? json['up3']?.toString() ?? '',
      machineName:
          json['machineName']?.toString() ??
          json['name']?.toString() ??
          json['machineDisplayName']?.toString() ??
          json['serialNumber']?.toString() ??
          '',
      machineBrand:
          json['machineBrand']?.toString() ?? json['brand']?.toString() ?? '',
      machineType:
          json['machineType']?.toString() ?? json['type']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ?? '',
      machineGeneratorCode:
          json['machineGeneratorCode']?.toString() ??
          json['generatorCode']?.toString() ??
          '',
      machineOwnershipStatus:
          json['machineOwnershipStatus']?.toString() ??
          json['ownershipStatus']?.toString() ??
          '',
      machinePerformanceLabel:
          json['machinePerformanceLabel']?.toString() ??
          json['performanceLabel']?.toString() ??
          '',
      machineInstalledCapacity:
          json['machineInstalledCapacity']?.toString() ??
          json['installedCapacity']?.toString() ??
          '',
      machineAvailableCapacity:
          json['machineAvailableCapacity']?.toString() ??
          json['availableCapacity']?.toString() ??
          '',
      machineDispatchCapacity:
          json['machineDispatchCapacity']?.toString() ??
          json['dispatchCapacity']?.toString() ??
          '',
      machineConditionLabel:
          json['machineConditionLabel']?.toString() ??
          json['conditionLabel']?.toString() ??
          '',
      machineStatus: parseMachineStatus(
        json['machineStatus']?.toString() ?? json['status']?.toString(),
      ),
      bebanMesin: NumberHelper.parseDynamic(json['bebanMesin']),
      standKwh: NumberHelper.parseDynamic(json['standKwh']),
      standBbm: NumberHelper.parseDynamic(json['standBbm']),
      tekananOli: NumberHelper.parseDynamic(json['tekananOli']),
      temperaturAir: NumberHelper.parseDynamic(json['temperaturAir']),
      phasaR: NumberHelper.parseDynamic(json['phasaR']),
      phasaS: NumberHelper.parseDynamic(json['phasaS']),
      phasaT: NumberHelper.parseDynamic(json['phasaT']),
      tegangan: NumberHelper.parseDynamic(json['tegangan']),
      cosPhi: NumberHelper.parseDynamic(json['cosPhi']),
      frequency: NumberHelper.parseDynamic(json['frequency']),
      notes: json['notes']?.toString() ?? '',
      selfiePhotoPath: json['selfiePhotoPath']?.toString() ?? '',
      machinePhotoPath: json['machinePhotoPath']?.toString() ?? '',
      latitude: NumberHelper.parseDynamic(json['latitude']),
      longitude: NumberHelper.parseDynamic(json['longitude']),
      locationAccuracy: NumberHelper.parseDynamic(json['locationAccuracy']),
      distanceFromUnit: NumberHelper.parseDynamic(json['distanceFromUnit']),
      locationStatus: parseLocationStatus(json['locationStatus']?.toString()),
      submittedAt:
          DateTime.tryParse(json['submittedAt']?.toString() ?? '') ??
          DateTime.now(),
      syncStatus: parseSyncStatus(json['syncStatus']?.toString()),
      reportStatus: parseReportStatus(json['reportStatus']?.toString()),
      abnormalNotes: json['abnormalNotes']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      fieldCondition: json['fieldCondition']?.toString() ?? '',
      syncErrorMessage: json['syncErrorMessage']?.toString(),
      approvalStatus: parseApprovalStatus(json['approvalStatus']?.toString()),
      rejectionReason: json['rejectionReason']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      lastEditedBy: json['lastEditedBy']?.toString() ?? '',
      lastEditedAt: DateTime.tryParse(json['lastEditedAt']?.toString() ?? ''),
      archivedAt: DateTime.tryParse(json['archivedAt']?.toString() ?? ''),
    );
  }
}
