import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_badge.dart';
import '../../location/location_service.dart';

class GpsStatusCard extends StatelessWidget {
  const GpsStatusCard({
    super.key,
    required this.result,
    required this.onValidate,
    this.sessionLabel,
  });

  final LocationValidationResult? result;
  final VoidCallback onValidate;
  final String? sessionLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: SectionTitle(
                  title: 'Validasi GPS (Opsional)',
                  subtitle: 'Validasi posisi operator saat submit (Opsional)',
                ),
              ),
            ],
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
          if (sessionLabel != null && sessionLabel!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                sessionLabel!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
