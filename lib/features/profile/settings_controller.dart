import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/hive_service.dart';

class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.light,
    this.autoSync = true,
    this.gpsHighAccuracy = true,
    this.notificationsEnabled = true,
    this.language = 'Indonesia',
    this.onboardingSeen = false,
  });

  final ThemeMode themeMode;
  final bool autoSync;
  final bool gpsHighAccuracy;
  final bool notificationsEnabled;
  final String language;
  final bool onboardingSeen;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? autoSync,
    bool? gpsHighAccuracy,
    bool? notificationsEnabled,
    String? language,
    bool? onboardingSeen,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      autoSync: autoSync ?? this.autoSync,
      gpsHighAccuracy: gpsHighAccuracy ?? this.gpsHighAccuracy,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
    );
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsController, AppSettingsState>(
      (ref) => AppSettingsController(ref.read(hiveServiceProvider)),
    );

class AppSettingsController extends StateNotifier<AppSettingsState> {
  AppSettingsController(this._hiveService) : super(const AppSettingsState());

  final HiveService _hiveService;

  Future<void> load() async {
    final box = _hiveService.settingsBox;
    state = state.copyWith(
      themeMode: (box.get('theme_mode') == 'dark')
          ? ThemeMode.dark
          : ThemeMode.light,
      autoSync: box.get('auto_sync', defaultValue: true) as bool,
      gpsHighAccuracy: box.get('gps_high_accuracy', defaultValue: true) as bool,
      notificationsEnabled:
          box.get('notifications_enabled', defaultValue: true) as bool,
      language: box.get('language', defaultValue: 'Indonesia') as String,
      onboardingSeen: box.get('onboarding_seen', defaultValue: false) as bool,
    );
  }

  Future<void> toggleTheme(bool enabled) async {
    state = state.copyWith(
      themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
    );
    await _hiveService.settingsBox.put(
      'theme_mode',
      enabled ? 'dark' : 'light',
    );
  }

  Future<void> toggleAutoSync(bool enabled) async {
    state = state.copyWith(autoSync: enabled);
    await _hiveService.settingsBox.put('auto_sync', enabled);
  }

  Future<void> toggleGpsHighAccuracy(bool enabled) async {
    state = state.copyWith(gpsHighAccuracy: enabled);
    await _hiveService.settingsBox.put('gps_high_accuracy', enabled);
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _hiveService.settingsBox.put('notifications_enabled', enabled);
  }

  Future<void> setOnboardingSeen() async {
    state = state.copyWith(onboardingSeen: true);
    await _hiveService.settingsBox.put('onboarding_seen', true);
  }

  Future<void> clearCache() async {
    await _hiveService.clearCache();
  }
}
