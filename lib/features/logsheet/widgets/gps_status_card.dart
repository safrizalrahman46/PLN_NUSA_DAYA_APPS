import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_badge.dart';
import '../../location/location_service.dart';

class GpsStatusCard extends StatelessWidget {
  const GpsStatusCard({
    super.key,
    required this.result,
    required this.onValidate,
  });

  final LocationValidationResult? result;
  final VoidCallback onValidate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Validasi GPS',
            subtitle: 'Validasi posisi operator saat submit',
          ),
          const SizedBox(height: 16),
          if (result == null)
            const Text('Lokasi belum diambil')
          else ...[
            StatusBadge.location(result!.status),
            const SizedBox(height: 12),
            Text('Latitude: ${result!.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${result!.longitude.toStringAsFixed(6)}'),
            Text('Akurasi: ${result!.accuracy.toStringAsFixed(1)} m'),
            Text(
              'Jarak dari unit: ${result!.distanceFromUnit.toStringAsFixed(1)} m',
            ),
            Text('Jalan: ${result!.street}'),
            Text('Area: ${result!.locality}'),
          ],
          const SizedBox(height: 14),
          AppButton(
            label: 'Ambil / Refresh Lokasi',
            onPressed: onValidate,
            fullWidth: false,
          ),
        ],
      ),
    );
  }
}
