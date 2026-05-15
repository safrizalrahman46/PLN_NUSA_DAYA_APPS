import 'package:flutter/material.dart';

import '../../../core/utils/distance_helper.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/unit_model.dart';
import '../location_service.dart';

class GpsValidationCard extends StatelessWidget {
  const GpsValidationCard({
    super.key,
    required this.unit,
    required this.result,
  });

  final UnitModel unit;
  final LocationValidationResult result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status lokasi', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StatusBadge.location(result.status),
          const SizedBox(height: 14),
          _Row(label: 'Latitude', value: result.latitude.toStringAsFixed(6)),
          _Row(label: 'Longitude', value: result.longitude.toStringAsFixed(6)),
          _Row(
            label: 'Akurasi',
            value: '${result.accuracy.toStringAsFixed(1)} m',
          ),
          _Row(
            label: 'Jarak dari titik PLTD',
            value: DistanceHelper.format(result.distanceFromUnit),
          ),
          _Row(
            label: 'Radius maksimal',
            value: DistanceHelper.format(unit.radiusMeter),
          ),
          _Row(label: 'Lokasi unit', value: unit.locationName),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label)),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
