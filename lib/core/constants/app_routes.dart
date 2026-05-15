import 'package:flutter/material.dart';

import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/dashboard/operator_shell_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/profile/settings_page.dart';
import '../../features/reports/report_export_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/supervisor/supervisor_shell_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const operatorShell = '/operator';
  static const supervisorShell = '/supervisor';
  static const settings = '/settings';
  static const reportExport = '/report-export';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return _buildRoute(const OnboardingPage(), settings);
      case login:
        return _buildRoute(const LoginPage(), settings);
      case forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);
      case operatorShell:
        return _buildRoute(const OperatorShellPage(), settings);
      case supervisorShell:
        return _buildRoute(const SupervisorShellPage(), settings);
      case AppRoutes.settings:
        return _buildRoute(const SettingsPage(), settings);
      case AppRoutes.reportExport:
        return _buildRoute(const ReportExportPage(), settings);
      case splash:
      default:
        return _buildRoute(const SplashPage(), settings);
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offset =
            Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }
}
