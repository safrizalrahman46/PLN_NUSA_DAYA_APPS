import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.onInput,
    required this.onHistory,
    required this.onPending,
    required this.onProfile,
  });

  final VoidCallback onInput;
  final VoidCallback onHistory;
  final VoidCallback onPending;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      (
        'Input Logsheet',
        Icons.edit_note_rounded,
        onInput,
        const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppColors.primary,
      ),
      (
        'Riwayat',
        Icons.history_rounded,
        onHistory,
        LinearGradient(
          colors: [AppColors.success, const Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppColors.success,
      ),
      (
        'Pending Upload',
        Icons.cloud_upload_rounded,
        onPending,
        LinearGradient(
          colors: [AppColors.warning, const Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppColors.warning,
      ),
      (
        'Profil',
        Icons.person_rounded,
        onProfile,
        LinearGradient(
          colors: [AppColors.auroraViolet, const Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppColors.auroraViolet,
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Aksi Cepat',
            subtitle: 'Akses fitur utama operator',
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).size.width >= 700 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (_, index) {
              final item = items[index];
              final accentColor = item.$5;
              return GlassCard(
                padding: const EdgeInsets.all(14),
                borderRadius: 20,
                sigmaX: 8,
                sigmaY: 8,
                onTap: item.$3,
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: isDark ? 0.22 : 0.10),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: item.$4,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.32),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(item.$2, color: Colors.white, size: 20),
                    ),
                    Text(
                      item.$1,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.text,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
