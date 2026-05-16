import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_title.dart';

class PhotoRequirementCard extends StatelessWidget {
  const PhotoRequirementCard({
    super.key,
    required this.selfiePath,
    required this.machinePhotoPath,
    required this.onCaptureSelfie,
    required this.onCaptureMachine,
  });

  final String selfiePath;
  final String machinePhotoPath;
  final VoidCallback onCaptureSelfie;
  final VoidCallback onCaptureMachine;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 420;

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
                    colors: [AppColors.accent, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: SectionTitle(
                  title: 'Foto Bukti',
                  subtitle: 'Selfie operator dan foto mesin wajib diambil',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          narrow
              ? Column(
                  children: [
                    _PhotoBox(
                      title: 'Selfie Operator',
                      path: selfiePath,
                      onTap: onCaptureSelfie,
                    ),
                    const SizedBox(height: 12),
                    _PhotoBox(
                      title: 'Foto Mesin',
                      path: machinePhotoPath,
                      onTap: onCaptureMachine,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _PhotoBox(
                        title: 'Selfie Operator',
                        path: selfiePath,
                        onTap: onCaptureSelfie,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PhotoBox(
                        title: 'Foto Mesin',
                        path: machinePhotoPath,
                        onTap: onCaptureMachine,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.title,
    required this.path,
    required this.onTap,
  });

  final String title;
  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      sigmaX: 6,
      sigmaY: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: path.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.10),
                            AppColors.accent.withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 38,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada foto',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: path.isEmpty ? 'Ambil Foto' : 'Retake Foto',
            onPressed: onTap,
            type: path.isEmpty ? AppButtonType.filled : AppButtonType.outlined,
          ),
        ],
      ),
    );
  }
}
