import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/permissions/permission_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import 'photo_preview_page.dart';
import 'widgets/captured_photo_card.dart';
import 'widgets/photo_type_card.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({
    super.key,
    required this.photoType,
    required this.operatorName,
    required this.unitName,
    required this.locationLabel,
  });

  final String photoType;
  final String operatorName;
  final String unitName;
  final String locationLabel;

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  String? _path;

  Future<void> _capture() async {
    final granted = await PermissionService().ensureCameraPermission(context);
    if (!granted || !mounted) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;

    setState(() => _path = file.path);
    final confirmed = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoPreviewPage(
          imagePath: file.path,
          photoType: widget.photoType,
          operatorName: widget.operatorName,
          unitName: widget.unitName,
          locationLabel: widget.locationLabel,
        ),
      ),
    );
    if (!mounted) return;
    if (confirmed != null) Navigator.pop(context, confirmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.photoType)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PhotoTypeCard(photoType: widget.photoType),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambil foto langsung dari kamera perangkat.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                CapturedPhotoCard(path: _path),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: _path == null ? 'Buka Kamera' : 'Ambil Ulang',
                        onPressed: _capture,
                      ),
                    ),
                    if (_path != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Preview',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhotoPreviewPage(
                                  imagePath: _path!,
                                  photoType: widget.photoType,
                                  operatorName: widget.operatorName,
                                  unitName: widget.unitName,
                                  locationLabel: widget.locationLabel,
                                ),
                              ),
                            );
                          },
                          type: AppButtonType.outlined,
                        ),
                      ),
                    ],
                  ],
                ),
                if (_path != null) ...[
                  const SizedBox(height: 12),
                  Text(File(_path!).path.split(Platform.pathSeparator).last),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
