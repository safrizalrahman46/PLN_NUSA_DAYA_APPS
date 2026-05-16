import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';

class WarningParameterCard extends StatelessWidget {
  const WarningParameterCard({super.key, required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        colors: [
          AppColors.warning.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: warnings.isEmpty
          ? null
          : AppColors.warning.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Warning Parameter',
            subtitle: 'Terdeteksi otomatis dari nilai input',
          ),
          const SizedBox(height: 14),
          if (warnings.isEmpty)
            const Text('Belum ada warning. Parameter masih dalam batas aman.')
          else
            ...warnings.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
