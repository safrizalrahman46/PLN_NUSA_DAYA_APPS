import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/network/network_info.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../core/widgets/app_shimmer.dart';
import '../auth/auth_controller.dart';
import '../profile/settings_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _logoOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.64, curve: Curves.easeOutBack),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0.34, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.64, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.45, 0.82, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.08, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.45, 0.84, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.58, 0.92, curve: Curves.easeOut),
    );
    _footerOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.72, 1, curve: Curves.easeOut),
    );
    _animationController.forward();
    Future.microtask(_bootstrap);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await ref.read(appSettingsProvider.notifier).load();
    await ref.read(authControllerProvider.notifier).initialize();
    await Future.delayed(AppConfig.splashDelay);
    if (!mounted) return;

    final settings = ref.read(appSettingsProvider);
    final user = ref.read(authControllerProvider).user;

    if (!settings.onboardingSeen) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      user.isOperator ? AppRoutes.operatorShell : AppRoutes.supervisorShell,
    );
  }

  @override
  Widget build(BuildContext context) {
    final network = ref.watch(networkStatusProvider).valueOrNull ?? true;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  final drift = math.sin(_animationController.value * math.pi);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.68 + (drift * 0.1), -0.84),
                        radius: 1.35,
                        colors: [
                          AppColors.highlight.withValues(alpha: 0.28),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: -64,
              top: 90,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(-_animationController.value * 26, 0),
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.highlight.withValues(alpha: 0.2),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: -70,
              bottom: 80,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(_animationController.value * 22, 0),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.16,
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _logoSlide,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: const AppBrandLogo.full(
                            width: 184,
                            withContainer: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: Text(
                          'PLN Nusa Daya',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Text(
                        AppStrings.shortAppName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _footerOpacity,
                      child: Column(
                        children: [
                          AppShimmer.block(width: 196, height: 12),
                          const SizedBox(height: 22),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding: const EdgeInsets.all(9),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.8,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            network
                                ? 'Menyiapkan sistem monitoring PLTD...'
                                : 'Mode offline aktif',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    const gap = 28.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
