import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../dummy/dummy_data.dart';

final hiveServiceProvider = Provider<HiveService>(
  (ref) => HiveService.instance,
);

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();
  static const currentSeedVersion = 3;

  static const settingsBoxName = 'settings_box';
  static const cacheBoxName = 'cache_box';
  static const logsheetBoxName = 'logsheet_box';
  static const notificationBoxName = 'notification_box';
  static const errorLogBoxName = 'error_log_box';
  static const auditLogBoxName = 'audit_log_box';
  static const archiveBoxName = 'archive_box';
  static const retentionLogBoxName = 'retention_log_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(settingsBoxName);
    await Hive.openBox<dynamic>(cacheBoxName);
    await Hive.openBox<dynamic>(logsheetBoxName);
    await Hive.openBox<dynamic>(notificationBoxName);
    await Hive.openBox<dynamic>(errorLogBoxName);
    await Hive.openBox<dynamic>(auditLogBoxName);
    await Hive.openBox<dynamic>(archiveBoxName);
    await Hive.openBox<dynamic>(retentionLogBoxName);
    await _seedIfNeeded();
    await _ensureDefaultSettings();
  }

  Box<dynamic> get settingsBox => Hive.box<dynamic>(settingsBoxName);
  Box<dynamic> get cacheBox => Hive.box<dynamic>(cacheBoxName);
  Box<dynamic> get logsheetBox => Hive.box<dynamic>(logsheetBoxName);
  Box<dynamic> get notificationBox => Hive.box<dynamic>(notificationBoxName);
  Box<dynamic> get errorLogBox => Hive.box<dynamic>(errorLogBoxName);
  Box<dynamic> get auditLogBox => Hive.box<dynamic>(auditLogBoxName);
  Box<dynamic> get archiveBox => Hive.box<dynamic>(archiveBoxName);
  Box<dynamic> get retentionLogBox => Hive.box<dynamic>(retentionLogBoxName);

  Future<void> _seedIfNeeded() async {
    final seeded = settingsBox.get('seeded') == true;
    final seedVersion = settingsBox.get('seed_version', defaultValue: 0) as int;

    if (!seeded || seedVersion != currentSeedVersion) {
      await cacheBox.clear();
      await logsheetBox.clear();
      for (final item in DummyData.seedLogsheets()) {
        await logsheetBox.put(item.localId, item.toJson());
      }
      await settingsBox.put('seeded', true);
      await settingsBox.put('seed_version', currentSeedVersion);
      if (!seeded) {
        await _ensureDefaultSettings();
      }
    }
  }

  Future<void> _ensureDefaultSettings() async {
    final defaults = <String, dynamic>{
      'onboarding_seen': false,
      'theme_mode': 'light',
      'auto_sync': true,
      'gps_high_accuracy': true,
      'notifications_enabled': true,
      'language': 'Indonesia',
      'operator_field_label': 'Nama Petugas Operator',
      'retention_years': 5,
      'retention_auto_archive': true,
    };

    for (final entry in defaults.entries) {
      if (!settingsBox.containsKey(entry.key)) {
        await settingsBox.put(entry.key, entry.value);
      }
    }
  }

  Future<void> clearCache() async {
    await cacheBox.clear();
  }
}
