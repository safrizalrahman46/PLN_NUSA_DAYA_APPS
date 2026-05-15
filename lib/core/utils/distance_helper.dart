import 'dart:math';

class DistanceHelper {
  DistanceHelper._();

  static double haversineMeter({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(endLat - startLat);
    final dLng = _toRadians(endLng - startLng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) *
            cos(_toRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static String format(double meter) {
    if (meter >= 1000) return '${(meter / 1000).toStringAsFixed(2)} km';
    return '${meter.toStringAsFixed(0)} m';
  }

  static double _toRadians(double degree) => degree * pi / 180;
}
