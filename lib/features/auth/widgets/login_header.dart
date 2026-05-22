import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_brand_logo.dart';

class LoginHeader extends StatefulWidget {
  const LoginHeader({super.key});

  @override
  State<LoginHeader> createState() => _LoginHeaderState();
}

class _LoginHeaderState extends State<LoginHeader>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Floating logo with concentric pulse rings
        AnimatedBuilder(
          animation: Listenable.merge([_floatController, _ringController]),
          builder: (context, _) {
            final floatY =
                math.sin(_floatController.value * math.pi * 2) * 4.0;
            return Transform.translate(
              offset: Offset(0, floatY),
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing rings (radar effect)
                    _PulseRing(progress: _ringController.value),
                    _PulseRing(
                      progress: (_ringController.value + 0.5) % 1.0,
                    ),
                    // Soft outer glow halo
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    // SOLID white logo orb so the PLN mark gets full contrast
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                          width: 2.5,
                        ),
                        boxShadow: [
                          // Cyan aurora glow
                          BoxShadow(
                            color:
                                AppColors.auroraCyan.withValues(alpha: 0.55),
                            blurRadius: 42,
                            spreadRadius: 6,
                          ),
                          // Warm highlight glow
                          BoxShadow(
                            color:
                                AppColors.highlight.withValues(alpha: 0.30),
                            blurRadius: 24,
                            spreadRadius: 3,
                          ),
                          // Crisp inner lift
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const AppBrandLogo.mark(width: 68),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        // Brand name with subtle shimmer
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.85),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            AppStrings.brandName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Animated status pill
        AnimatedBuilder(
          animation: _ringController,
          builder: (context, _) {
            final pulse =
                (math.sin(_ringController.value * math.pi * 2) * 0.5 + 0.5);
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.highlight
                        .withValues(alpha: 0.10 + pulse * 0.18),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Live indicator dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.highlight,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.highlight
                              .withValues(alpha: 0.4 + pulse * 0.4),
                          blurRadius: 6 + pulse * 4,
                          spreadRadius: pulse * 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    Icons.electric_bolt_rounded,
                    color: AppColors.highlight,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'PLTD Monitoring System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Expanding ring used as the logo's pulsing aura.
class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress});
  final double progress; // 0..1

  @override
  Widget build(BuildContext context) {
    final size = 92.0 + progress * 46.0;
    final opacity = (1.0 - progress) * 0.50;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: opacity),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}