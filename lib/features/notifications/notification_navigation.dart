import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/app_notification_model.dart';
import '../../data/repositories/logsheet_repository.dart';
import '../admin/retention_settings_page.dart';
import '../errors/error_log_detail_page.dart';
import '../history/logsheet_detail_page.dart';
import '../logsheet/input_logsheet_page.dart';
import '../reports/report_export_page.dart';
import '../reports/report_page.dart';
import '../sync/pending_upload_page.dart';
import '../units/unit_detail_page.dart';
import 'notification_detail_page.dart';

Future<void> openNotificationTarget(
  BuildContext context,
  WidgetRef ref,
  AppNotificationModel notification,
) async {
  switch (notification.targetType) {
    case NotificationTargetType.pendingList:
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const PendingUploadPage()),
      );
      return;
    case NotificationTargetType.logsheetDetail:
      final localId = notification.localId;
      if (localId != null && localId.isNotEmpty) {
        final logsheet = await ref.read(logsheetRepositoryProvider).getByLocalId(localId);
        if (!context.mounted) return;
        if (logsheet != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => LogsheetDetailPage(logsheet: logsheet)),
          );
          return;
        }
      }
      break;
    case NotificationTargetType.editLogsheet:
      final localId = notification.localId;
      if (localId != null && localId.isNotEmpty) {
        final logsheet = await ref.read(logsheetRepositoryProvider).getByLocalId(localId);
        if (!context.mounted) return;
        if (logsheet != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => InputLogsheetPage(initialLogsheet: logsheet)),
          );
          return;
        }
      }
      break;
    case NotificationTargetType.errorDetail:
      if ((notification.errorLogId ?? '').isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ErrorLogDetailPage(errorLogId: notification.errorLogId!),
          ),
        );
        return;
      }
      break;
    case NotificationTargetType.reportList:
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const ReportPage()),
      );
      return;
    case NotificationTargetType.reportExport:
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const ReportExportPage()),
      );
      return;
    case NotificationTargetType.unitDetail:
      final unitId = notification.unitId;
      if (unitId != null && unitId.isNotEmpty) {
        final matches = DummyData.units.where((item) => item.id == unitId);
        if (matches.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => UnitDetailPage(unit: matches.first)),
          );
          return;
        }
      }
      break;
    case NotificationTargetType.retention:
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const RetentionSettingsPage()),
      );
      return;
    case NotificationTargetType.notificationDetail:
      break;
  }

  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => NotificationDetailPage(notification: notification),
    ),
  );
}
