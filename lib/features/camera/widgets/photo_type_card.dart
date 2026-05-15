import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class PhotoTypeCard extends StatelessWidget {
  const PhotoTypeCard({super.key, required this.photoType});

  final String photoType;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.camera_alt_rounded, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(photoType, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Foto ini akan disimpan bersama metadata operator, unit, waktu, dan lokasi.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
