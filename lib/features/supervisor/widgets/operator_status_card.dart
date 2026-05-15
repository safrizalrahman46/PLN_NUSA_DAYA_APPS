import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
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

    return AppCard(
      gradient: AppColors.softSurfaceGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['unit'].toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Icon(
                hasPhoto
                    ? Icons.photo_camera_front_rounded
                    : Icons.no_photography_rounded,
                color: hasPhoto ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
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
