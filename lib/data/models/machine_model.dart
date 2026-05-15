class MachineModel {
  const MachineModel({
    required this.id,
    required this.unitId,
    required this.serialNumber,
    required this.capacity,
    required this.status,
  });

  final String id;
  final String unitId;
  final String serialNumber;
  final String capacity;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'unitId': unitId,
    'serialNumber': serialNumber,
    'capacity': capacity,
    'status': status,
  };

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id: json['id']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
    );
  }
}
