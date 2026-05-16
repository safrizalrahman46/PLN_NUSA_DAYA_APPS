import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/app_enums.dart';

class OperatorStatusCard extends StatelessWidget {
  const OperatorStatusCard({
    super.key,
    required this.item,
    required this.onDetail,
  });

  final Map<String, dynamic> item;
  final VoidCallback? onDetail;

  @override
  Widget build(BuildContext context) {
    final reportStatus = parseReportStatus(item['reportStatus'].toString());
    final locationStatus = parseLocationStatus(
      item['locationStatus'].toString(),
    );
    final rawSubmit = item['lastSubmit'];
    final lastSubmit = rawSubmit is DateTime
        ? rawSubmit
        : DateTime.tryParse(rawSubmit?.toString() ?? '');
    final hasPhoto = item['hasPhoto'] == true;

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
                      AppColors.primary,
                      AppColors.accent.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  hasPhoto
                      ? Icons.photo_camera_front_rounded
                      : Icons.no_photography_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['unit'].toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: 12,
            sigmaX: 6,
            sigmaY: 6,
            child: Text(
              'Operator: ${item['operator']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jam submit terakhir: ${lastSubmit == null ? '-' : DateHelper.formatDateTime(lastSubmit)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge.report(reportStatus),
              StatusBadge.location(locationStatus),
              StatusBadge(
                label: hasPhoto ? 'Foto tersedia' : 'Foto belum lengkap',
                color: hasPhoto ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(label: 'Detail', onPressed: onDetail, fullWidth: false),
        ],
      ),
    );
  }
}
