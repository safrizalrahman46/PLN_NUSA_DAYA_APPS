import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/widgets/app_button.dart';

class PhotoPreviewPage extends StatelessWidget {
  const PhotoPreviewPage({
    super.key,
    required this.imagePath,
    required this.photoType,
    required this.operatorName,
    required this.unitName,
    required this.locationLabel,
  });

  final String imagePath;
  final String photoType;
  final String operatorName;
  final String unitName;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Foto')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(imagePath), fit: BoxFit.cover),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photoType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          operatorName,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          unitName,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          locationLabel,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          DateTime.now().toString(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Ambil Ulang',
                      onPressed: () => Navigator.pop(context),
                      type: AppButtonType.outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Gunakan Foto',
                      onPressed: () => Navigator.pop(context, imagePath),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
