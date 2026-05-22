import '../../core/utils/number_helper.dart';

class UnitModel {
  const UnitModel({
    required this.id,
    required this.name,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeter,
    required this.status,
  });

  final String id;
  final String name;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radiusMeter;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeter': radiusMeter,
    'status': status,
  };

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      locationName: json['locationName']?.toString() ?? '',
      latitude: NumberHelper.parseDynamic(json['latitude']),
      longitude: NumberHelper.parseDynamic(json['longitude']),
      radiusMeter: NumberHelper.parseDynamic(json['radiusMeter']),
      status: json['status']?.toString() ?? 'active',
    );
  }
}
