import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../data/models/logsheet_model.dart';
import '../../../data/repositories/logsheet_repository.dart';
import '../../logsheet/input_logsheet_page.dart';

final todayTimeSlotsProvider = FutureProvider<Map<int, LogsheetModel?>>((ref) async {
  final history = await ref.read(logsheetRepositoryProvider).getHistory();
  final today = DateTime.now();

  final slotMap = <int, LogsheetModel?>{for (int i = 0; i < 24; i++) i: null};

  for (final item in history) {
    if (item.submittedAt.year == today.year &&
        item.submittedAt.month == today.month &&
        item.submittedAt.day == today.day) {
      slotMap[item.submittedAt.hour] = item;
    }
  }

  return slotMap;
});

class TimeSlotMatrixCard extends ConsumerWidget {
  const TimeSlotMatrixCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(todayTimeSlotsProvider);
    final currentHour = DateTime.now().hour;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: SectionTitle(
                  title: 'Matriks Slot Jam Laporan',
                  subtitle: 'Hijau: Sudah • Merah: Belum • Tap slot untuk isi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          slotsAsync.when(
            data: (slotMap) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemCount: 24,
                itemBuilder: (context, hour) {
                  final item = slotMap[hour];
                  final isDone = item != null;
                  final isCurrent = hour == currentHour;
                  final color = isDone
                      ? AppColors.success
                      : hour <= currentHour
                          ? AppColors.danger
                          : Colors.grey.shade400;

                  final label = '${hour.toString().padLeft(2, '0')}:00';

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const InputLogsheetPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDone ? 0.2 : 0.1),
                          border: Border.all(
                            color: isCurrent ? AppColors.primary : color,
                            width: isCurrent ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : hour <= currentHour
                                      ? Icons.cancel_rounded
                                      : Icons.schedule_rounded,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Gagal memuat matriks slot jam.'),
          ),
        ],
      ),
    );
  }
}
