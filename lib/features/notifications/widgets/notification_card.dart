import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/app_enums.dart';
import '../../../data/models/app_notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onMarkRead,
  });

  final AppNotificationModel item;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final isRead = item.read;
    final color = switch (item.priority) {
      NotificationPriority.tinggi => Colors.red,
      NotificationPriority.sedang => Colors.orange,
      NotificationPriority.rendah => Colors.blue,
    };
    final icon = switch (item.type) {
      'missing' => Icons.schedule_send_rounded,
      'abnormal' => Icons.warning_amber_rounded,
      'sync' => Icons.sync_problem_rounded,
      'gps' => Icons.location_off_rounded,
      'error' => Icons.bug_report_rounded,
      'approval' => Icons.fact_check_rounded,
      _ => Icons.notifications_active_rounded,
    };

    return GlassCard(
      onTap: onTap,
      borderColor: isRead ? null : color.withValues(alpha: 0.35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.w600 : FontWeight.w800,
                            ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.priority.label.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isRead ? 'Sudah dibaca' : 'Belum dibaca',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isRead ? Colors.grey : color,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateHelper.formatDateTime(item.time),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSoft,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (onMarkRead != null)
                      TextButton(
                        onPressed: onMarkRead,
                        child: const Text('Tandai Dibaca'),
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
