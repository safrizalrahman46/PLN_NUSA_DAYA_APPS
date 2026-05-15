import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Foto Bukti',
            subtitle: 'Selfie operator dan foto mesin wajib diambil',
          ),
          const SizedBox(height: 16),
          Row(
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
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
                      color: Colors.black12,
                      child: const Icon(Icons.camera_alt_rounded, size: 38),
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
