import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/app_notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../auth/auth_controller.dart';
import 'notification_navigation.dart';
import 'widgets/notification_card.dart';

final notificationsProvider = FutureProvider<List<AppNotificationModel>>((ref) {
  final user = ref.watch(authControllerProvider).user;
  return ref.read(notificationRepositoryProvider).getNotifications(user);
});

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  String _priority = 'Semua';
  bool _unreadOnly = false;

  Future<void> _refresh() async {
    ref.invalidate(notificationsProvider);
    await ref.read(notificationsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: notifications.maybeWhen(
          data: (items) {
            final unread = items.where((item) => !item.read).length;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Notifikasi'),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
          orElse: () => const Text('Notifikasi'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: notifications.when(
          data: (items) {
            final filtered = items.where((item) {
              final matchPriority =
                  _priority == 'Semua' || item.priority.label == _priority;
              final matchRead = !_unreadOnly || !item.read;
              return matchPriority && matchRead;
            }).toList();

            return ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 108,
              ),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Filter Notifikasi',
                        subtitle: 'Filter berdasarkan prioritas dan status baca',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: ['Semua', 'Tinggi', 'Sedang', 'Rendah']
                            .map(
                              (item) => ChoiceChip(
                                label: Text(item),
                                selected: _priority == item,
                                backgroundColor: Colors.white,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.14),
                                side: BorderSide(
                                  color: _priority == item
                                      ? AppColors.primary.withValues(alpha: 0.42)
                                      : AppColors.border,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _priority = item;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tampilkan unread saja'),
                        value: _unreadOnly,
                        onChanged: (value) {
                          setState(() {
                            _unreadOnly = value;
                          });
                        },
                      ),
                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(notificationRepositoryProvider)
                                    .markAllAsRead();
                                ref.invalidate(notificationsProvider);
                              },
                              icon: const Icon(Icons.done_all_rounded, size: 16),
                              label: const Text('Tandai Semua Dibaca'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const AppEmptyState(
                    title: 'Notifikasi kosong',
                    message:
                        'Belum ada notifikasi yang sesuai dengan filter aktif.',
                    icon: Icons.notifications_off_rounded,
                  )
                else
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NotificationCard(
                        item: item,
                        onTap: () async {
                          await ref
                              .read(notificationRepositoryProvider)
                              .markAsRead(item.id);
                          if (!context.mounted) return;
                          ref.invalidate(notificationsProvider);
                          await openNotificationTarget(context, ref, item);
                        },
                        onMarkRead: item.read
                            ? null
                            : () async {
                                await ref
                                    .read(notificationRepositoryProvider)
                                    .markAsRead(item.id);
                                ref.invalidate(notificationsProvider);
                              },
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const AppLoading(),
          error: (error, _) => AppErrorState(
            message: ApiException.fromObject(error).message,
            onRetry: _refresh,
          ),
        ),
      ),
    );
  }
}
