import '../../core/utils/number_helper.dart';

class UnitModel {
  const UnitModel({
    required this.id,
    required this.name,
    this.kdArea = '',
    this.locationName = '',
    this.latitude = 0,
    this.longitude = 0,
    this.radiusMeter = 0,
    this.status = 'active',
  });

  final String id;
  final String name;
  final String kdArea;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusMeter;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kdArea': kdArea,
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeter': radiusMeter,
    'status': status,
  };

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString() ??
          json['kd_unit']?.toString() ??
          '',
      name: json['name']?.toString() ??
          json['nama_unit']?.toString() ??
          '',
      kdArea: json['kdArea']?.toString() ??
          json['kd_area']?.toString() ??
          '',
      locationName: json['locationName']?.toString() ??
          json['nama_area']?.toString() ??
          '',
      latitude: NumberHelper.parseDynamic(json['latitude']),
      longitude: NumberHelper.parseDynamic(json['longitude']),
      radiusMeter: NumberHelper.parseDynamic(json['radiusMeter']),
      status: json['status']?.toString() ?? 'active',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kdArea == other.kdArea;

  @override
  int get hashCode => id.hashCode ^ kdArea.hashCode;
}
