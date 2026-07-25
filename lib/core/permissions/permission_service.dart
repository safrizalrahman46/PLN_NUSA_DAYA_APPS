import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);

class PermissionService {
  Future<bool> ensureCameraPermission(BuildContext context) async {
    // Web: browser handles camera permission via MediaDevices API
    if (kIsWeb) return true;
    return _ensurePermission(
      context,
      permission: Permission.camera,
      title: 'Izin kamera diperlukan',
      message: 'Kamera diperlukan untuk mengambil bukti dokumentasi lapangan.',
    );
  }

  Future<bool> ensureLocationPermission(BuildContext context) async {
    // Web: browser handles location permission via Geolocation API
    if (kIsWeb) return true;
    return _ensurePermission(
      context,
      permission: Permission.location,
      title: 'Izin lokasi diperlukan',
      message:
          'Lokasi diperlukan untuk memvalidasi posisi operator saat submit logsheet.',
    );
  }

  Future<bool> _ensurePermission(
    BuildContext context, {
    required Permission permission,
    required String title,
    required String message,
  }) async {
    var status = await permission.status;
    if (status.isGranted) return true;

    status = await permission.request();
    if (status.isGranted) return true;
    if (!context.mounted) return false;

    final action = await showDialog<_PermissionAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _PermissionAction.cancel),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _PermissionAction.retry),
            child: const Text('Coba lagi'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _PermissionAction.settings),
            child: const Text('Buka pengaturan'),
          ),
        ],
      ),
    );

    if (action == _PermissionAction.settings) {
      await openAppSettings();
      status = await permission.status;
      return status.isGranted;
    }

    if (action == _PermissionAction.retry) {
      status = await permission.request();
      return status.isGranted;
    }

    return false;
  }
}

enum _PermissionAction { settings, retry, cancel }
