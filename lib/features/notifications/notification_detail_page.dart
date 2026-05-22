import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/app_notification_model.dart';

class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({
    super.key,
    required this.notification,
    this.onOpenTarget,
  });

  final AppNotificationModel notification;
  final VoidCallback? onOpenTarget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Notifikasi')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    StatusBadge(
                      label: notification.priority.label,
                      color: switch (notification.priority) {
                        NotificationPriority.tinggi => AppColors.danger,
                        NotificationPriority.sedang => AppColors.warning,
                        NotificationPriority.rendah => AppColors.success,
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(notification.description),
                const SizedBox(height: 12),
                Text(
                  notification.time.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (notification.payload.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Payload',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SelectableText(notification.payload.toString()),
                  ),
                ],
                if (onOpenTarget != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onOpenTarget,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Buka Detail Terkait'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
