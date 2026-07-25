import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/retention_repository.dart';
import 'features/profile/settings_controller.dart';
import 'features/splash/splash_page.dart';
import 'features/sync/sync_service.dart';

class PltdLogsheetApp extends ConsumerStatefulWidget {
  const PltdLogsheetApp({super.key});

  @override
  ConsumerState<PltdLogsheetApp> createState() => _PltdLogsheetAppState();
}

class _PltdLogsheetAppState extends ConsumerState<PltdLogsheetApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appSettingsProvider.notifier).load();
      ref.read(syncServiceProvider.notifier).start();
      ref.read(retentionRepositoryProvider).archiveExpired();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const SplashPage(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
