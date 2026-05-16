import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/settings_controller.dart';
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
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.darkGradient
                : const LinearGradient(
                    colors: [
                      Color(0xFFEAF2FF),
                      Color(0xFFF2F6FC),
                      Color(0xFFE7F0FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
