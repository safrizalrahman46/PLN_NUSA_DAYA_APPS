import 'package:geolocator/geolocator.dart';

import '../../core/utils/distance_helper.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/unit_model.dart';

class LocationValidationResult {
  const LocationValidationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.distanceFromUnit,
    required this.status,
    required this.gpsEnabled,
    required this.permissionGranted,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final double distanceFromUnit;
  final LocationStatus status;
  final bool gpsEnabled;
  final bool permissionGranted;
}

class LocationService {
  Future<LocationValidationResult> validate(
    UnitModel unit, {
    bool highAccuracy = true,
  }) async {
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      return const LocationValidationResult(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        distanceFromUnit: 0,
        status: LocationStatus.gpsOff,
        gpsEnabled: false,
        permissionGranted: false,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationValidationResult(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        distanceFromUnit: 0,
        status: LocationStatus.permissionDenied,
        gpsEnabled: true,
        permissionGranted: false,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: highAccuracy
            ? LocationAccuracy.best
            : LocationAccuracy.medium,
      ),
    );
    final distance = DistanceHelper.haversineMeter(
      startLat: unit.latitude,
      startLng: unit.longitude,
      endLat: position.latitude,
      endLng: position.longitude,
    );
    final status = distance <= unit.radiusMeter
        ? LocationStatus.valid
        : LocationStatus.outsideArea;

    return LocationValidationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      distanceFromUnit: distance,
      status: status,
      gpsEnabled: true,
      permissionGranted: true,
    );
  }
}
