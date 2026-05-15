import 'package:geocoding/geocoding.dart';
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
    this.street = '-',
    this.subLocality = '-',
    this.locality = '-',
    this.administrativeArea = '-',
    this.country = '-',
    this.fullAddress = '-',
    this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final double distanceFromUnit;
  final LocationStatus status;
  final bool gpsEnabled;
  final bool permissionGranted;
  final String street;
  final String subLocality;
  final String locality;
  final String administrativeArea;
  final String country;
  final String fullAddress;
  final DateTime? recordedAt;
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

    final permission = await _ensurePermission();
    if (!permission) {
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
      locationSettings: _settings(highAccuracy),
    );
    return _toValidationResult(position, unit);
  }

  Stream<LocationValidationResult> watchValidation(
    UnitModel unit, {
    bool highAccuracy = true,
  }) async* {
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      yield const LocationValidationResult(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        distanceFromUnit: 0,
        status: LocationStatus.gpsOff,
        gpsEnabled: false,
        permissionGranted: false,
      );
      return;
    }

    final permission = await _ensurePermission();
    if (!permission) {
      yield const LocationValidationResult(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        distanceFromUnit: 0,
        status: LocationStatus.permissionDenied,
        gpsEnabled: true,
        permissionGranted: false,
      );
      return;
    }

    await for (final position in Geolocator.getPositionStream(
      locationSettings: _settings(highAccuracy),
    )) {
      yield await _toValidationResult(position, unit);
    }
  }

  Future<LocationValidationResult> _toValidationResult(
    Position position,
    UnitModel unit,
  ) async {
    final distance = DistanceHelper.haversineMeter(
      startLat: unit.latitude,
      startLng: unit.longitude,
      endLat: position.latitude,
      endLng: position.longitude,
    );
    final status = distance <= unit.radiusMeter
        ? LocationStatus.valid
        : LocationStatus.outsideArea;
    final placemark = await _reverseGeocode(
      position.latitude,
      position.longitude,
    );

    return LocationValidationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      distanceFromUnit: distance,
      status: status,
      gpsEnabled: true,
      permissionGranted: true,
      street: placemark?.street?.trim().isNotEmpty == true
          ? placemark!.street!
          : '-',
      subLocality: placemark?.subLocality?.trim().isNotEmpty == true
          ? placemark!.subLocality!
          : '-',
      locality: placemark?.locality?.trim().isNotEmpty == true
          ? placemark!.locality!
          : '-',
      administrativeArea:
          placemark?.administrativeArea?.trim().isNotEmpty == true
          ? placemark!.administrativeArea!
          : '-',
      country: placemark?.country?.trim().isNotEmpty == true
          ? placemark!.country!
          : '-',
      fullAddress: _buildAddressLine(placemark),
      recordedAt: DateTime.now(),
    );
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  LocationSettings _settings(bool highAccuracy) {
    return LocationSettings(
      accuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
      distanceFilter: highAccuracy ? 10 : 25,
    );
  }

  Future<Placemark?> _reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return null;
      }
      return placemarks.first;
    } catch (_) {
      return null;
    }
  }

  String _buildAddressLine(Placemark? placemark) {
    if (placemark == null) {
      return '-';
    }

    final segments = [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.country,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).toList();

    if (segments.isEmpty) {
      return '-';
    }
    return segments.join(', ');
  }
}
