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
    final narrow = MediaQuery.of(context).size.width < 380;

    return AppCard(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.98),
          AppColors.primaryDark,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
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
            ).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Interval pelaporan 1 jam',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          OverflowBar(
            spacing: 12,
            overflowSpacing: 12,
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: narrow ? double.infinity : null,
                child: Text(
                  countdownText,
                  textAlign: narrow ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: narrow ? double.infinity : 130,
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
