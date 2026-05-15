import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class NextReportCard extends StatelessWidget {
  const NextReportCard({
    super.key,
    required this.nextReportAt,
    required this.countdownText,
  });

  final DateTime nextReportAt;
  final String countdownText;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.96),
          AppColors.primaryDark,
        ],
      ),
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadwal laporan berikutnya',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            DateHelper.formatDateTime(nextReportAt),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  countdownText,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: 130,
                child: AppButton(
                  label: 'Siap Input',
                  onPressed: () {},
                  type: AppButtonType.tonal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
