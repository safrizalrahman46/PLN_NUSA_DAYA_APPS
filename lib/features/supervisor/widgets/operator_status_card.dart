import 'package:flutter/material.dart';

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

    return AppCard(
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
                item['hasPhoto'] == true
                    ? Icons.photo_camera_front_rounded
                    : Icons.no_photography_rounded,
                color: item['hasPhoto'] == true ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Operator: ${item['operator']}'),
          Text(
            'Jam submit terakhir: ${lastSubmit == null ? '-' : DateHelper.formatDateTime(lastSubmit)}',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge.report(reportStatus),
              StatusBadge.location(locationStatus),
              StatusBadge(
                label: item['hasPhoto'] == true
                    ? 'Foto tersedia'
                    : 'Foto belum lengkap',
                color: item['hasPhoto'] == true ? Colors.green : Colors.orange,
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
