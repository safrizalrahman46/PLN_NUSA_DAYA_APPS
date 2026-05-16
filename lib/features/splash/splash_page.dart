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
import '../../core/widgets/glass_card.dart';
import '../auth/auth_controller.dart';
import '../profile/settings_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _auroraController;

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
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

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
    _auroraController.dispose();
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
            // Radial drift layer (original)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  final drift =
                      math.sin(_animationController.value * math.pi);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.68 + (drift * 0.1), -0.84),
                        radius: 1.35,
                        colors: [
                          AppColors.highlight.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Aurora orb 1 — top-left, blue
            AnimatedBuilder(
              animation: _auroraController,
              builder: (context, _) {
                final dy =
                    math.sin(_auroraController.value * math.pi * 2) * 18;
                return Positioned(
                  left: -80,
                  top: 40 + dy,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.auroraBlue.withValues(alpha: 0.38),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Aurora orb 2 — right, cyan
            AnimatedBuilder(
              animation: _auroraController,
              builder: (context, _) {
                final dx =
                    math.cos(_auroraController.value * math.pi * 2) * 14;
                return Positioned(
                  right: -60 + dx,
                  top: 180,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.auroraCyan.withValues(alpha: 0.30),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Aurora orb 3 — bottom-left, violet
            AnimatedBuilder(
              animation: _auroraController,
              builder: (context, _) {
                final dy =
                    math.cos((_auroraController.value + 0.33) * math.pi * 2) *
                        20;
                return Positioned(
                  left: -40,
                  bottom: 70 + dy,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.auroraViolet.withValues(alpha: 0.24),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Dot grid texture
            Positioned.fill(
              child: Opacity(
                opacity: 0.14,
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo wrapped in glass card
                    SlideTransition(
                      position: _logoSlide,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: GlassCard(
                            padding: const EdgeInsets.all(28),
                            borderRadius: 32,
                            sigmaX: 16,
                            sigmaY: 16,
                            borderColor:
                                Colors.white.withValues(alpha: 0.35),
                            child: const AppBrandLogo.full(width: 156),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: Text(
                          'PLN Nusa Daya',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
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
                            ?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading footer wrapped in glass card
                    FadeTransition(
                      opacity: _footerOpacity,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 20),
                        borderRadius: 40,
                        sigmaX: 10,
                        sigmaY: 10,
                        borderColor:
                            Colors.white.withValues(alpha: 0.28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppShimmer.block(width: 180, height: 10),
                            const SizedBox(height: 18),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [Colors.white, AppColors.auroraCyan],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              network
                                  ? 'Menyiapkan sistem monitoring PLTD...'
                                  : 'Mode offline aktif',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.80),
                                  ),
                            ),
                          ],
                        ),
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
