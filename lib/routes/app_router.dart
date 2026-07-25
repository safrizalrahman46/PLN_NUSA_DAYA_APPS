import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/unit_list_screen.dart';
import '../screens/logsheet_form_screen.dart';
import '../screens/report_screen.dart';
import '../screens/detail_report_screen.dart';
import '../services/local_storage_service.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String units = '/units';
  static const String logsheetForm = '/logsheet-form';
  static const String reports = '/reports';
  static const String reportDetail = '/reports/detail';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: (BuildContext context, GoRouterState state) async {
      final storage = await LocalStorageService.getInstance();
      final isLoggedIn = storage.isLoggedIn();

      final isSplash = state.matchedLocation == splash;
      final isLogin = state.matchedLocation == login;

      // During splash screen checking, do not redirect
      if (isSplash) return null;

      if (!isLoggedIn && !isLogin) {
        return login;
      }

      if (isLoggedIn && isLogin) {
        return dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: units,
        builder: (context, state) => const UnitListScreen(),
      ),
      GoRoute(
        path: logsheetForm,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LogsheetFormScreen(
            kdArea: extra['kd_area'] as String? ?? '',
            namaArea: extra['nama_area'] as String? ?? '',
            kdUnit: extra['kd_unit'] as String? ?? '',
            namaUnit: extra['nama_unit'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: reports,
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '$reportDetail/:idBebanUld',
        builder: (context, state) {
          final idBebanUld = state.pathParameters['idBebanUld'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return DetailReportScreen(
            idBebanUld: idBebanUld,
            tanggal: extra['tanggal'] as String? ?? '',
            jam: extra['jam'] as String? ?? '',
          );
        },
      ),
    ],
  );
}

/// Simple SplashScreen implementation that manages Auto-Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait briefly for smooth visual transition
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final storage = await LocalStorageService.getInstance();
    if (!mounted) return;
    if (storage.isLoggedIn()) {
      context.go(AppRouter.dashboard);
    } else {
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ContainerGradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading/Branding Spinner
              Hero(
                tag: 'app_logo',
                child: Icon(
                  Icons.electric_bolt_rounded,
                  size: 80,
                  color: Color(0xFFFCE300), // PLN Yellow
                ),
              ),
              SizedBox(height: 24),
              Text(
                'PLN NUSA DAYA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'DIGIKIT Monitoring System',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic container with gradient background matching brand aesthetics
class ContainerGradientBackground extends StatelessWidget {
  final Widget child;
  const ContainerGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A3D8E), // Deep Blue
            Color(0xFF0A6FD8), // PLN Primary
            Color(0xFF23B7FF), // Accent Light Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
