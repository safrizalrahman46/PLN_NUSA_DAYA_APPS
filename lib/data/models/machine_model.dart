class MachineModel {
  const MachineModel({
    required this.id,
    required this.unitId,
    required this.up3,
    required this.machineName,
    required this.brand,
    required this.machineType,
    required this.serialNumber,
    required this.generatorCode,
    required this.ownershipStatus,
    required this.performanceLabel,
    required this.capacity,
    this.availableCapacity = '',
    this.dispatchCapacity = '',
    required this.status,
    this.conditionLabel = '',
  });

  final String id;
  final String unitId;
  final String up3;
  final String machineName;
  final String brand;
  final String machineType;
  final String serialNumber;
  final String generatorCode;
  final String ownershipStatus;
  final String performanceLabel;
  final String capacity;
  final String availableCapacity;
  final String dispatchCapacity;
  final String status;
  final String conditionLabel;

  String get displayLabel => machineName.isEmpty ? serialNumber : machineName;

  String get displaySubtitle {
    final parts = <String>[
      if (brand.trim().isNotEmpty) brand.trim(),
      if (machineType.trim().isNotEmpty) machineType.trim(),
      if (serialNumber.trim().isNotEmpty) 'SN ${serialNumber.trim()}',
      if (capacity.trim().isNotEmpty) capacity.trim(),
      if (availableCapacity.trim().isNotEmpty)
        'DMN ${availableCapacity.trim()}',
      if (dispatchCapacity.trim().isNotEmpty)
        'Pasok ${dispatchCapacity.trim()}',
      if (conditionLabel.trim().isNotEmpty) conditionLabel.trim(),
    ];
    return parts.join(' • ');
  }

  String get masterInfoLine {
    final parts = <String>[
      if (up3.trim().isNotEmpty) up3.trim(),
      if (generatorCode.trim().isNotEmpty) generatorCode.trim(),
      if (ownershipStatus.trim().isNotEmpty) 'Milik ${ownershipStatus.trim()}',
      if (performanceLabel.trim().isNotEmpty)
        'Kinerja ${performanceLabel.trim()}',
    ];
    return parts.join(' • ');
  }

  String get shortLabel {
    final match = RegExp(r'#\d+').firstMatch(machineName);
    if (match != null) {
      return match.group(0)!;
    }
    if (brand.trim().isNotEmpty) {
      return brand.trim();
    }
    return serialNumber.trim().isEmpty ? '-' : serialNumber.trim();
  }

  MachineModel copyWith({
    String? id,
    String? unitId,
    String? up3,
    String? machineName,
    String? brand,
    String? machineType,
    String? serialNumber,
    String? generatorCode,
    String? ownershipStatus,
    String? performanceLabel,
    String? capacity,
    String? availableCapacity,
    String? dispatchCapacity,
    String? status,
    String? conditionLabel,
  }) {
    return MachineModel(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      up3: up3 ?? this.up3,
      machineName: machineName ?? this.machineName,
      brand: brand ?? this.brand,
      machineType: machineType ?? this.machineType,
      serialNumber: serialNumber ?? this.serialNumber,
      generatorCode: generatorCode ?? this.generatorCode,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      performanceLabel: performanceLabel ?? this.performanceLabel,
      capacity: capacity ?? this.capacity,
      availableCapacity: availableCapacity ?? this.availableCapacity,
      dispatchCapacity: dispatchCapacity ?? this.dispatchCapacity,
      status: status ?? this.status,
      conditionLabel: conditionLabel ?? this.conditionLabel,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'unitId': unitId,
    'up3': up3,
    'machineName': machineName,
    'name': machineName,
    'brand': brand,
    'machineType': machineType,
    'type': machineType,
    'serialNumber': serialNumber,
    'generatorCode': generatorCode,
    'code': generatorCode,
    'ownershipStatus': ownershipStatus,
    'ownership': ownershipStatus,
    'performanceLabel': performanceLabel,
    'performance': performanceLabel,
    'capacity': capacity,
    'availableCapacity': availableCapacity,
    'dispatchCapacity': dispatchCapacity,
    'status': status,
    'conditionLabel': conditionLabel,
  };

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id: json['id']?.toString() ?? json['id_mesin']?.toString() ?? '',
      unitId:
          json['unitId']?.toString() ?? json['kd_unit']?.toString() ?? '',
      up3: json['up3']?.toString() ?? json['kd_unit']?.toString() ?? '',
      machineName:
          json['machineName']?.toString() ??
          json['name']?.toString() ??
          json['nama_mesin']?.toString() ??
          json['serialNumber']?.toString() ??
          '',
      brand:
          json['brand']?.toString() ?? json['merk']?.toString() ?? '',
      machineType:
          json['machineType']?.toString() ??
          json['type']?.toString() ??
          '',
      serialNumber:
          json['serialNumber']?.toString() ??
          json['no_seri']?.toString() ??
          json['sn']?.toString() ??
          '',
      generatorCode:
          json['generatorCode']?.toString() ??
          json['code']?.toString() ??
          json['kode_mesin_silm']?.toString() ??
          '',
      ownershipStatus:
          json['ownershipStatus']?.toString() ??
          json['ownership']?.toString() ??
          json['kd_kepemilikan']?.toString() ??
          '',
      performanceLabel:
          json['performanceLabel']?.toString() ??
          json['performance']?.toString() ??
          '',
      capacity:
          json['capacity']?.toString() ??
          json['daya_terpasang']?.toString() ??
          json['dt']?.toString() ??
          '',
      availableCapacity:
          json['availableCapacity']?.toString() ??
          json['daya_mampu']?.toString() ??
          '',
      dispatchCapacity:
          json['dispatchCapacity']?.toString() ??
          json['daya_mampu']?.toString() ??
          '',
      status:
          json['status']?.toString() ??
          json['kd_status_mesin']?.toString() ??
          'active',
      conditionLabel:
          json['conditionLabel']?.toString() ??
          json['condition']?.toString() ??
          '',
    );
  }
}
