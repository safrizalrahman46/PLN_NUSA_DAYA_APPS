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
    required this.serialNumber,
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
  });

  final String id;
  final String localId;
  final String proofId;
  final String operatorId;
  final String operatorName;
  final String unitId;
  final String unitName;
  final String machineId;
  final String serialNumber;
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

  bool get isAbnormal =>
      reportStatus == ReportStatus.abnormal || abnormalNotes.isNotEmpty;

  LogsheetModel copyWith({
    String? id,
    String? localId,
    String? proofId,
    String? operatorId,
    String? operatorName,
    String? unitId,
    String? unitName,
    String? machineId,
    String? serialNumber,
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
      serialNumber: serialNumber ?? this.serialNumber,
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
    'serialNumber': serialNumber,
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
      serialNumber: json['serialNumber']?.toString() ?? '',
      bebanMesin: (json['bebanMesin'] as num?)?.toDouble() ?? 0,
      standKwh: (json['standKwh'] as num?)?.toDouble() ?? 0,
      standBbm: (json['standBbm'] as num?)?.toDouble() ?? 0,
      tekananOli: (json['tekananOli'] as num?)?.toDouble() ?? 0,
      temperaturAir: (json['temperaturAir'] as num?)?.toDouble() ?? 0,
      phasaR: (json['phasaR'] as num?)?.toDouble() ?? 0,
      phasaS: (json['phasaS'] as num?)?.toDouble() ?? 0,
      phasaT: (json['phasaT'] as num?)?.toDouble() ?? 0,
      tegangan: (json['tegangan'] as num?)?.toDouble() ?? 0,
      cosPhi: (json['cosPhi'] as num?)?.toDouble() ?? 0,
      frequency: (json['frequency'] as num?)?.toDouble() ?? 0,
      notes: json['notes']?.toString() ?? '',
      selfiePhotoPath: json['selfiePhotoPath']?.toString() ?? '',
      machinePhotoPath: json['machinePhotoPath']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble() ?? 0,
      distanceFromUnit: (json['distanceFromUnit'] as num?)?.toDouble() ?? 0,
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
    );
  }
}
