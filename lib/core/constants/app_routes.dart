import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../features/admin/admin_shell_page.dart';
import '../../screens/dashboard_screen.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/dashboard/operator_shell_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/profile/settings_page.dart';
import '../../features/reports/report_export_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/supervisor/supervisor_shell_page.dart';
import '../../data/models/user_model.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const operatorShell = '/operator';
  static const supervisorShell = '/supervisor';
  static const adminShell = '/admin';
  static const settings = '/settings';
  static const reportExport = '/report-export';

  static UserModel? getLoggedInUser() {
    try {
      final box = Hive.box<dynamic>('settings_box');
      final raw = box.get('current_user');
      if (raw is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return null;
  }

  static bool isOnboardingSeen() {
    try {
      final box = Hive.box<dynamic>('settings_box');
      return box.get('onboarding_seen', defaultValue: false) == true;
    } catch (_) {}
    return false;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // 1. Cek Onboarding
    if (!isOnboardingSeen()) {
      if (settings.name != onboarding) {
        return _buildRoute(const OnboardingPage(), settings);
      }
      return _buildRoute(const OnboardingPage(), settings);
    }

    // 2. Cek Sesi Login (Auth Guard)
    final user = getLoggedInUser();
    if (user == null) {
      // Jika belum login, paksa pengguna ke halaman Login (kecuali lupa password)
      if (settings.name != login && settings.name != forgotPassword) {
        return _buildRoute(const LoginPage(), settings);
      }
    } else {
      // Jika sudah login, cegah akses ke halaman login / splash / forgot-password
      if (settings.name == login || settings.name == forgotPassword || settings.name == splash) {
        return _buildRoute(_getShellForUser(user), settings);
      }
      
      // Proteksi rute berbasis Role (Mencegah Operator buka Dashboard Admin dll)
      if (settings.name == operatorShell && !user.isOperator) {
        return _buildRoute(_getShellForUser(user), settings);
      }
      if (settings.name == supervisorShell && !user.isSupervisor) {
        return _buildRoute(_getShellForUser(user), settings);
      }
      if (settings.name == adminShell && !user.isAdmin && !user.isSuperadmin) {
        return _buildRoute(_getShellForUser(user), settings);
      }
    }

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
      case adminShell:
        return _buildRoute(const AdminShellPage(), settings);
      case AppRoutes.settings:
        return _buildRoute(const SettingsPage(), settings);
      case AppRoutes.reportExport:
        return _buildRoute(const ReportExportPage(), settings);
      case '/dashboard':
      case 'dashboard':
        return _buildRoute(const DashboardScreen(), settings);
      case splash:
      default:
        // Fallback jika sudah login tapi rute tidak dikenal
        if (user != null) {
          return _buildRoute(_getShellForUser(user), settings);
        }
        return _buildRoute(const SplashPage(), settings);
    }
  }

  static Widget _getShellForUser(UserModel user) {
    if (user.isOperator) {
      return const OperatorShellPage();
    } else if (user.isSupervisor) {
      return const SupervisorShellPage();
    } else {
      return const AdminShellPage();
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
