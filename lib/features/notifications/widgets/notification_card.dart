import 'package:flutter/material.dart';

import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/app_card.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final priority = item['priority'].toString();
    final type = item['type'].toString();
    final isRead = item['read'] == true;
    final rawTime = item['time'];
    final parsedTime = rawTime is DateTime
        ? rawTime
        : DateTime.tryParse(rawTime?.toString() ?? '') ?? DateTime.now();
    final color = switch (priority) {
      'tinggi' => Colors.red,
      'sedang' => Colors.orange,
      _ => Colors.blue,
    };
    final icon = switch (type) {
      'missing' => Icons.schedule_send_rounded,
      'abnormal' => Icons.warning_amber_rounded,
      'sync' => Icons.sync_problem_rounded,
      'gps' => Icons.location_off_rounded,
      _ => Icons.notifications_active_rounded,
    };

    return AppCard(
      borderColor: isRead ? null : color.withValues(alpha: 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color),
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
                        item['title'].toString(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
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
                        priority.toUpperCase(),
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
                  item['description'].toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  DateHelper.formatDateTime(parsedTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
