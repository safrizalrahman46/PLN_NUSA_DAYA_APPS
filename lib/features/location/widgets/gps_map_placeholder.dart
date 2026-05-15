import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class GpsMapPlaceholder extends StatelessWidget {
  const GpsMapPlaceholder({super.key, required this.unitName});

  final String unitName;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                Colors.blue.withValues(alpha: 0.14),
                Colors.cyan.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.08),
                ),
              ),
              const Icon(Icons.location_searching_rounded, size: 42),
              Positioned(bottom: 16, child: Text('Radius area $unitName')),
            ],
          ),
        ),
      ),
    );
  }
}
