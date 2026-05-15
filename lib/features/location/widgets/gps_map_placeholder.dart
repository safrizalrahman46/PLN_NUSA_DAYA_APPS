import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/widgets/app_card.dart';
import '../../../data/models/unit_model.dart';
import '../location_service.dart';

class GpsMapPlaceholder extends StatelessWidget {
  const GpsMapPlaceholder({
    super.key,
    required this.unit,
    this.result,
    this.trailPoints = const <LatLng>[],
  });

  final UnitModel unit;
  final LocationValidationResult? result;
  final List<LatLng> trailPoints;

  @override
  Widget build(BuildContext context) {
    final unitPoint = LatLng(unit.latitude, unit.longitude);
    final currentPoint = result == null
        ? unitPoint
        : LatLng(result!.latitude, result!.longitude);
    final bounds = LatLngBounds.fromPoints(
      trailPoints.isEmpty
          ? [unitPoint, currentPoint]
          : [unitPoint, ...trailPoints, currentPoint],
    );
    final mapController = MapController();

    return AppCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 280,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentPoint,
              initialZoom: 13,
              onMapReady: () {
                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(42),
                  ),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.plnnusadaya.pltd_logsheet',
                maxZoom: 19,
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: unitPoint,
                    radius: unit.radiusMeter,
                    useRadiusInMeter: true,
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderStrokeWidth: 2,
                    borderColor: Colors.blue,
                  ),
                ],
              ),
              if (trailPoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: trailPoints,
                      strokeWidth: 4,
                      color: Colors.orange,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: unitPoint,
                    width: 84,
                    height: 84,
                    child: _MarkerBadge(
                      icon: Icons.factory_rounded,
                      color: Colors.blue.shade700,
                      label: 'PLTD',
                    ),
                  ),
                  Marker(
                    point: currentPoint,
                    width: 84,
                    height: 84,
                    child: _MarkerBadge(
                      icon: Icons.my_location_rounded,
                      color: Colors.red.shade600,
                      label: 'Operator',
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: const [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Radius ${unit.radiusMeter.toStringAsFixed(0)} m',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkerBadge extends StatelessWidget {
  const _MarkerBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.24),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
