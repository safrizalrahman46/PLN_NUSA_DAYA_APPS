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
  // ===== Animation controllers =====
  late final AnimationController _entranceController;
  late final AnimationController _auroraController;
  late final AnimationController _pulseController;
  late final AnimationController _particleController;
  late final AnimationController _ringController;

  // ===== Entrance animations =====
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _badgeOpacity;
  late final Animation<double> _footerOpacity;

  // ===== Continuous animations =====
  late final Animation<double> _pulse;

  // ===== Particles =====
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.10, 0.55, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.10, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.10, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.40, 0.78, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.40, 0.82, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
    );
    _badgeOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.30, 0.7, curve: Curves.easeOut),
    );
    _footerOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    _pulse = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Generate stable particle field
    final rand = math.Random(7);
    _particles = List.generate(24, (_) {
      return _Particle(
        seed: rand.nextDouble(),
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        size: 1.2 + rand.nextDouble() * 2.4,
        speed: 0.25 + rand.nextDouble() * 0.85,
        opacity: 0.20 + rand.nextDouble() * 0.6,
      );
    });

    _entranceController.forward();
    Future.microtask(_bootstrap);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _auroraController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _ringController.dispose();
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
      user.isOperator
          ? AppRoutes.operatorShell
          : user.isSupervisor
          ? AppRoutes.supervisorShell
          : AppRoutes.adminShell,
    );
  }

  @override
  Widget build(BuildContext context) {
    final network = ref.watch(networkStatusProvider).valueOrNull ?? true;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final logoSize = isTablet ? 188.0 : 136.0;
    final horizontalPad = isTablet ? 48.0 : 24.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // ===== BACKGROUND LAYERS =====

            // Animated radial drift
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _auroraController,
                builder: (context, _) {
                  final t = _auroraController.value;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          -0.68 + math.sin(t * math.pi * 2) * 0.12,
                          -0.84 + math.cos(t * math.pi * 2) * 0.08,
                        ),
                        radius: 1.4,
                        colors: [
                          AppColors.highlight.withValues(alpha: 0.24),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Aurora orbs (drifting)
            _auroraOrb(
              left: -90,
              top: 40,
              diameter: 290,
              color: AppColors.auroraBlue,
              alpha: 0.38,
              phase: 0,
            ),
            _auroraOrb(
              right: -70,
              top: 180,
              diameter: 230,
              color: AppColors.auroraCyan,
              alpha: 0.30,
              phase: 0.33,
            ),
            _auroraOrb(
              left: -50,
              bottom: 80,
              diameter: 250,
              color: AppColors.auroraViolet,
              alpha: 0.26,
              phase: 0.66,
            ),

            // Dot grid
            Positioned.fill(
              child: RepaintBoundary(
                child: Opacity(
                  opacity: 0.13,
                  child: CustomPaint(painter: _GridPainter()),
                ),
              ),
            ),

            // Floating particles
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ParticlesPainter(
                        progress: _particleController.value,
                        particles: _particles,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom vignette for footer readability
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.22),
                      ],
                      stops: const [0.62, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // ===== FOREGROUND CONTENT =====
            SafeArea(
              child: Column(
                children: [
                  // Top bar: online/offline badge
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      14,
                      horizontalPad,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FadeTransition(
                          opacity: _badgeOpacity,
                          child: _OnlineBadge(online: network),
                        ),
                      ],
                    ),
                  ),

                  // Center: logo + title + subtitle
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPad,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hero logo with breathing glow
                            SlideTransition(
                              position: _logoSlide,
                              child: FadeTransition(
                                opacity: _logoOpacity,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: _HeroLogo(
                                    pulse: _pulse,
                                    logoSize: logoSize,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Brand name with gradient shader
                            SlideTransition(
                              position: _titleSlide,
                              child: FadeTransition(
                                opacity: _titleOpacity,
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        AppColors.auroraCyan,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    AppStrings.brandName,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      fontSize: isTablet ? 40 : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Subtitle pill
                            FadeTransition(
                              opacity: _subtitleOpacity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.shortAppName,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelLarge?.copyWith(
                                    color: Colors.white.withValues(
                                      alpha: 0.88,
                                    ),
                                    letterSpacing: 2.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom: loading section + footer
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      0,
                      horizontalPad,
                      18,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _footerOpacity,
                          child: _LoadingSection(
                            ringController: _ringController,
                            online: network,
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: _footerOpacity,
                          child: const _FooterBlock(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _auroraOrb({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double diameter,
    required Color color,
    required double alpha,
    required double phase,
  }) {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, _) {
        final t = (_auroraController.value + phase) % 1.0;
        final dx = math.cos(t * math.pi * 2) * 18;
        final dy = math.sin(t * math.pi * 2) * 22;
        return Positioned(
          left: left != null ? left + dx : null,
          right: right != null ? right - dx : null,
          top: top != null ? top + dy : null,
          bottom: bottom != null ? bottom - dy : null,
          child: IgnorePointer(
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: alpha),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// Hero logo with multi-layer breathing glow (halo overflows)
// ============================================================
class _HeroLogo extends StatelessWidget {
  const _HeroLogo({required this.pulse, required this.logoSize});

  final Animation<double> pulse;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Outer breathing halo (Positioned -> doesn't size Stack; OverflowBox lets it exceed)
        Positioned.fill(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final s = logoSize * 1.95 * pulse.value;
                return IgnorePointer(
                  child: Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.auroraCyan.withValues(alpha: 0.22),
                          AppColors.auroraBlue.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Inner soft glow
        Positioned.fill(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final s = logoSize * 1.35 * pulse.value;
                return IgnorePointer(
                  child: Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // The GlassCard sizes the Stack
        GlassCard(
          padding: const EdgeInsets.all(28),
          borderRadius: 36,
          sigmaX: 18,
          sigmaY: 18,
          borderColor: Colors.white.withValues(alpha: 0.4),
          child: AppBrandLogo.full(width: logoSize),
        ),
      ],
    );
  }
}

// ============================================================
// Loading section: progress ring + shimmer + animated status
// ============================================================
class _LoadingSection extends StatelessWidget {
  const _LoadingSection({required this.ringController, required this.online});

  final AnimationController ringController;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      borderRadius: 28,
      sigmaX: 12,
      sigmaY: 12,
      borderColor: Colors.white.withValues(alpha: 0.28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom progress ring (sweep gradient + leading dot)
          SizedBox(
            width: 54,
            height: 54,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: ringController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ProgressRingPainter(
                      progress: ringController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Shimmer bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppShimmer.block(width: 200, height: 8),
          ),
          const SizedBox(height: 14),

          // Animated status text (own state -> small rebuild scope)
          _AnimatedStatusText(online: online),
        ],
      ),
    );
  }
}

// ============================================================
// Animated cycling status text — isolated state to avoid
// triggering full SplashPage rebuilds.
// ============================================================
class _AnimatedStatusText extends StatefulWidget {
  const _AnimatedStatusText({required this.online});

  final bool online;

  @override
  State<_AnimatedStatusText> createState() => _AnimatedStatusTextState();
}

class _AnimatedStatusTextState extends State<_AnimatedStatusText> {
  Timer? _timer;
  int _index = 0;

  static const List<String> _messages = [
    'Memuat konfigurasi...',
    'Mengecek koneksi...',
    'Memverifikasi sesi pengguna...',
    'Menyiapkan dashboard...',
    'Hampir selesai...',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _messages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.online ? _messages[_index] : 'Mode offline aktif';
    final key = widget.online ? 'online-$_index' : 'offline';
    return SizedBox(
      height: 22,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          text,
          key: ValueKey(key),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Online/Offline badge with pulsing dot + colored glow
// ============================================================
class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final color = online ? const Color(0xFF22D3A8) : const Color(0xFFFF6B6B);
    final label = online ? 'Online Mode' : 'Offline Mode';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 + 0.4 * v),
                blurRadius: 4 + 6 * v,
                spreadRadius: 0.5 + 1.2 * v,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// Footer block — “PLN Nusa Daya Monitoring System”
// ============================================================
class _FooterBlock extends StatelessWidget {
  const _FooterBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PLN Nusa Daya Monitoring System',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterTag(label: 'Secure', color: AppColors.auroraCyan),
            const _FooterDivider(),
            _FooterTag(label: 'Reliable', color: AppColors.auroraBlue),
            const _FooterDivider(),
            _FooterTag(label: 'Realtime', color: AppColors.auroraViolet),
          ],
        ),
      ],
    );
  }
}

class _FooterTag extends StatelessWidget {
  const _FooterTag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 11,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FooterDivider extends StatelessWidget {
  const _FooterDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ============================================================
// Background dot grid
// ============================================================
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

// ============================================================
// Floating particles
// ============================================================
class _Particle {
  final double seed;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  const _Particle({
    required this.seed,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.progress, required this.particles});

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Vertical drift (upward)
      final yOffset = (progress * p.speed) % 1.0;
      final yNorm = (p.y - yOffset) % 1.0;
      final y = yNorm * size.height;

      // Horizontal swing
      final swing =
          math.sin((progress * 2 * math.pi * p.speed) + p.seed * 6) * 14;
      final x = (p.x * size.width) + swing;

      // Soft glow
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: p.opacity * 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), p.size * 1.4, glowPaint);

      // Bright core
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(x, y), p.size * 0.55, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter old) =>
      old.progress != progress;
}

// ============================================================
// Custom progress ring — sweep gradient + leading bright dot
// ============================================================
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background ring
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bg);

    // Sweeping arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    const sweep = math.pi * 1.25;
    final start = progress * math.pi * 2 - math.pi / 2;

    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          AppColors.auroraCyan.withValues(alpha: 0.45),
          AppColors.auroraCyan,
          Colors.white,
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
        transform: GradientRotation(start),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, arc);

    // Leading glowing dot
    final dotAngle = start + sweep;
    final dotPos = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    canvas.drawCircle(
      dotPos,
      4.5,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(dotPos, 2.4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress;
}