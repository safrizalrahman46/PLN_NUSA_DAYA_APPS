import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../auth/auth_controller.dart';
import '../profile/settings_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH PAGE  (Rocky-style: solid gradient, logo center, subtle animations)
// ─────────────────────────────────────────────────────────────────────────────

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  // Entry animation
  late final AnimationController _entryCtrl;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _loaderOpacity;

  // Ambient pulse
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ── Entry (2.2 s) ──────────────────────────────────────────────────────
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _logoOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.38, 0.72, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.38, 0.74, curve: Curves.easeOutCubic),
    ));
    _subtitleOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );
    _loaderOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );

    // ── Ambient pulse (3 s loop) ───────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    Future.microtask(_bootstrap);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Solid gradient background (Rocky-style) ──────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppColors.splashGradient),
            ),
          ),

          // ── Dot-grid texture ─────────────────────────────────────────────
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: CustomPaint(painter: _DotGridPainter()),
            ),
          ),

          // ── Ambient glow orbs ─────────────────────────────────────────────
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Stack(
              children: [
                // Top-left orb
                Positioned(
                  left: -80,
                  top: -60,
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: _GlowOrb(
                      size: 280,
                      color: AppColors.auroraBlue,
                      opacity: 0.30,
                    ),
                  ),
                ),
                // Top-right orb
                Positioned(
                  right: -70,
                  top: 60,
                  child: Transform.scale(
                    scale: 1.15 - _pulse.value * 0.15,
                    child: _GlowOrb(
                      size: 220,
                      color: AppColors.auroraCyan,
                      opacity: 0.22,
                    ),
                  ),
                ),
                // Bottom-left orb
                Positioned(
                  left: -50,
                  bottom: 80,
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: _GlowOrb(
                      size: 200,
                      color: AppColors.auroraViolet,
                      opacity: 0.18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Decorative ring (Rocky large circle in background) ────────────
          Positioned(
            right: -size.width * 0.30,
            top: size.height * 0.12,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Opacity(
                opacity: 0.06 + _pulse.value * 0.04,
                child: Container(
                  width: size.width * 0.90,
                  height: size.width * 0.90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -size.width * 0.44,
            top: size.height * 0.06,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Opacity(
                opacity: 0.04 + _pulse.value * 0.03,
                child: Container(
                  width: size.width * 1.18,
                  height: size.width * 1.18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo container (Rocky: large, centered, prominent)
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.40),
                                blurRadius: 48,
                                spreadRadius: 0,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/images/logo_pln_notext.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // App name — Rocky style: bold, large, white
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Text(
                          'PLN Nusa Daya',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Text(
                        AppStrings.subtitle,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  height: 1.5,
                                ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Bottom loader area
                    FadeTransition(
                      opacity: _loaderOpacity,
                      child: Column(
                        children: [
                          // Thin progress bar (Rocky-style)
                          _AnimatedProgressBar(controller: _pulseCtrl),
                          const SizedBox(height: 20),
                          Text(
                            'Menyiapkan sistem PLTD…',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                      letterSpacing: 0.4,
                                    ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version
                    FadeTransition(
                      opacity: _loaderOpacity,
                      child: Text(
                        AppStrings.appVersion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.35),
                              letterSpacing: 0.8,
                              fontSize: 11,
                            ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated progress bar  (thin shimmer bar, Rocky-style)
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Container(
          width: 160,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.30 + controller.value * 0.55,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Colors.white],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.55),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glow orb helper
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot-grid background painter
// ─────────────────────────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;
    const gap = 28.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}