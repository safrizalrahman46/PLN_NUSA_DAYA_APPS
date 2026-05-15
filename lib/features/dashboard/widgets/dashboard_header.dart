import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_brand_logo.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/user_model.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.user, required this.online});

  final UserModel? user;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name ?? 'Operator PLTD';
    final subTitle = user?.isOperator == true
        ? 'Akses input seluruh unit PLTD'
        : (user?.unitName ?? 'Belum ada unit aktif');

    return AppCard(
      gradient: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkGradient
          : AppColors.heroGradient,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppBrandLogo.full(width: 126, withContainer: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateHelper.formatHour(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            DateHelper.greeting(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            displayName,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subTitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusBadge(
                label: online ? 'Online' : 'Offline',
                color: online ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: Text(
                  user?.isOperator == true ? 'Operator' : 'Supervisor',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
