import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/user_model.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.user, required this.online});

  final UserModel? user;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkGradient
          : AppColors.heroGradient,
      borderColor: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateHelper.greeting(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? 'Operator PLTD',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.isOperator == true
                      ? 'Akses input semua unit PLTD'
                      : (user?.unitName ?? 'Belum ada unit aktif'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 14),
                StatusBadge(
                  label: online ? 'Online' : 'Offline',
                  color: online ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}
