import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_brand_logo.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/user_model.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.user, required this.online});

  final UserModel? user;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = user?.name ?? 'Operator PLTD';
    final subTitle = user?.isOperator == true
        ? 'Akses input seluruh unit PLTD'
        : (user?.unitName ?? 'Belum ada unit aktif');

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkGradient : AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Aurora orb — top right
          Positioned(
            right: -50,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraCyan.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Aurora orb — bottom left
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraViolet.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Aurora orb — center right
          Positioned(
            right: 60,
            bottom: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraBlue.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppBrandLogo.full(width: 116, withContainer: true),
                    const Spacer(),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      borderRadius: 999,
                      sigmaX: 8,
                      sigmaY: 8,
                      borderColor: Colors.white.withValues(alpha: 0.30),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateHelper.formatHour(DateTime.now()),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    StatusBadge(
                      label: online ? 'Online' : 'Offline',
                      color: online ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      borderRadius: 999,
                      sigmaX: 6,
                      sigmaY: 6,
                      borderColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        user?.isOperator == true ? 'Operator' : 'Supervisor',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      borderRadius: 999,
                      sigmaX: 6,
                      sigmaY: 6,
                      borderColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        DateHelper.formatDate(DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
