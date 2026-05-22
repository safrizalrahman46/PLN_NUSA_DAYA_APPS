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
    this.operatorFieldLabel = 'Nama Petugas Operator',
    this.onboardingSeen = false,
    this.retentionYears = 5,
    this.retentionAutoArchive = true,
  });

  final ThemeMode themeMode;
  final bool autoSync;
  final bool gpsHighAccuracy;
  final bool notificationsEnabled;
  final String language;
  final String operatorFieldLabel;
  final bool onboardingSeen;
  final int retentionYears;
  final bool retentionAutoArchive;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? autoSync,
    bool? gpsHighAccuracy,
    bool? notificationsEnabled,
    String? language,
    String? operatorFieldLabel,
    bool? onboardingSeen,
    int? retentionYears,
    bool? retentionAutoArchive,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      autoSync: autoSync ?? this.autoSync,
      gpsHighAccuracy: gpsHighAccuracy ?? this.gpsHighAccuracy,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      operatorFieldLabel: operatorFieldLabel ?? this.operatorFieldLabel,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      retentionYears: retentionYears ?? this.retentionYears,
      retentionAutoArchive:
          retentionAutoArchive ?? this.retentionAutoArchive,
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
      operatorFieldLabel: box.get(
        'operator_field_label',
        defaultValue: 'Nama Petugas Operator',
      ) as String,
      onboardingSeen: box.get('onboarding_seen', defaultValue: false) as bool,
      retentionYears: box.get('retention_years', defaultValue: 5) as int,
      retentionAutoArchive:
          box.get('retention_auto_archive', defaultValue: true) as bool,
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

  Future<void> setLanguage(String value) async {
    state = state.copyWith(language: value);
    await _hiveService.settingsBox.put('language', value);
  }

  Future<void> setOperatorFieldLabel(String value) async {
    final trimmed = value.trim().isEmpty
        ? 'Nama Petugas Operator'
        : value.trim();
    state = state.copyWith(operatorFieldLabel: trimmed);
    await _hiveService.settingsBox.put('operator_field_label', trimmed);
  }

  Future<void> setRetentionYears(int years) async {
    state = state.copyWith(retentionYears: years);
    await _hiveService.settingsBox.put('retention_years', years);
  }

  Future<void> toggleRetentionAutoArchive(bool enabled) async {
    state = state.copyWith(retentionAutoArchive: enabled);
    await _hiveService.settingsBox.put('retention_auto_archive', enabled);
  }

  Future<void> clearCache() async {
    await _hiveService.clearCache();
  }
}
