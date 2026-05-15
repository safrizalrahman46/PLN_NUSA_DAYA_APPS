import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../dummy/dummy_data.dart';

final hiveServiceProvider = Provider<HiveService>(
  (ref) => HiveService.instance,
);

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();
  static const currentSeedVersion = 2;

  static const settingsBoxName = 'settings_box';
  static const cacheBoxName = 'cache_box';
  static const logsheetBoxName = 'logsheet_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(settingsBoxName);
    await Hive.openBox<dynamic>(cacheBoxName);
    await Hive.openBox<dynamic>(logsheetBoxName);
    await _seedIfNeeded();
  }

  Box<dynamic> get settingsBox => Hive.box<dynamic>(settingsBoxName);
  Box<dynamic> get cacheBox => Hive.box<dynamic>(cacheBoxName);
  Box<dynamic> get logsheetBox => Hive.box<dynamic>(logsheetBoxName);

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
        await settingsBox.put('onboarding_seen', false);
        await settingsBox.put('theme_mode', 'light');
        await settingsBox.put('auto_sync', true);
        await settingsBox.put('gps_high_accuracy', true);
        await settingsBox.put('notifications_enabled', true);
        await settingsBox.put('language', 'Indonesia');
      }
    }
  }

  Future<void> clearCache() async {
    await cacheBox.clear();
  }
}
