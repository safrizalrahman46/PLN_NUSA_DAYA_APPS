import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../data/repositories/supervisor_repository.dart';
import 'widgets/notification_card.dart';

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(supervisorRepositoryProvider).getNotifications();
});

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  String _priority = 'Semua';
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: notifications.when(
        data: (items) {
          final filtered = items.where((item) {
            final matchPriority =
                _priority == 'Semua' ||
                item['priority'].toString() == _priority.toLowerCase();
            final matchRead = !_unreadOnly || item['read'] == false;
            return matchPriority && matchRead;
          }).toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(context).padding.bottom + 108),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Notifikasi',
                      style: Theme.of(context).textTheme.titleLarge,
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
                              selectedColor: AppColors.primary.withValues(
                                alpha: 0.14,
                              ),
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
                    child: NotificationCard(item: item),
                  ),
                ),
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(message: error.toString()),
      ),
    );
  }
}
