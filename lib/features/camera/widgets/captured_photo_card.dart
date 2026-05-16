import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CapturedPhotoCard extends StatelessWidget {
  const CapturedPhotoCard({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: path == null
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.accent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        size: 46,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Belum ada foto',
                        style: TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Image.file(File(path!), fit: BoxFit.cover),
      ),
    );
  }
}
