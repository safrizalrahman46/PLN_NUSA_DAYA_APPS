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
          Text(
            'Status lokasi realtime',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge.location(result.status),
              StatusBadge(
                label: result.gpsEnabled ? 'GPS aktif' : 'GPS nonaktif',
                color: result.gpsEnabled ? Colors.green : Colors.red,
              ),
            ],
          ),
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
          _Row(label: 'Nama jalan', value: result.street),
          _Row(
            label: 'Area',
            value: result.subLocality == '-'
                ? result.locality
                : '${result.subLocality}, ${result.locality}',
          ),
          _Row(label: 'Provinsi', value: result.administrativeArea),
          _Row(label: 'Alamat lengkap', value: result.fullAddress),
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
    final narrow = MediaQuery.of(context).size.width < 380;
    if (narrow) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
