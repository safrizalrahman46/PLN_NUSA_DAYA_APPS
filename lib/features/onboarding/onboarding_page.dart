import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../profile/settings_controller.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────
class _OnboardingData {
  const _OnboardingData({
    required this.tag,
    required this.headline,
    required this.description,
    required this.icon,
    required this.imageAsset,
    required this.orbColor1,
    required this.orbColor2,
  });
  final String tag;
  final String headline;
  final String description;
  final IconData icon;
  final String imageAsset;
  final Color orbColor1;
  final Color orbColor2;
}

// ─── Main Page ────────────────────────────────────────────────────────────────
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _contentAnim;
  late final AnimationController _splashLogoAnim;
  late final AnimationController _orbAnim;

  int _currentIndex = 0;
  bool _isAnimating = false;

  static const _photoSlides = [
    _OnboardingData(
      tag: 'LAPORAN DIGITAL',
      headline: 'Laporan operasional, secepat satu sentuhan jari.',
      description:
          'Input data mesin terstruktur dan rapi — langsung dari lapangan.',
      icon: Icons.description_outlined,
      imageAsset: 'assets/images/onboarding_laporan.jpg',
      orbColor1: Color(0xFF22C55E),
      orbColor2: Color(0xFF10B981),
    ),
    _OnboardingData(
      tag: 'GPS & FOTO BUKTI',
      headline: 'Lokasi terverifikasi, dokumentasi terjamin.',
      description:
          'Validasi titik operator dan dokumentasi mesin dengan akurasi tinggi.',
      icon: Icons.location_on_outlined,
      imageAsset: 'assets/images/onboarding_gps.jpg',
      orbColor1: Color(0xFF14B8A6),
      orbColor2: Color(0xFF06B6D4),
    ),
    _OnboardingData(
      tag: 'OFFLINE FIRST',
      headline: 'Tetap produktif, meski sinyal hilang.',
      description:
          'Data tersimpan aman dan tersinkron otomatis ketika online kembali.',
      icon: Icons.cloud_off_outlined,
      imageAsset: 'assets/images/onboarding_offline.jpg',
      orbColor1: Color(0xFF84CC16),
      orbColor2: Color(0xFF22C55E),
    ),
  ];

  // total pages = splash + photo slides
  int get _totalPages => _photoSlides.length + 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _contentAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    _splashLogoAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _orbAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentAnim.dispose();
    _splashLogoAnim.dispose();
    _orbAnim.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appSettingsProvider.notifier).setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _goTo(int index) {
    if (_isAnimating || index == _currentIndex) return;
    _isAnimating = true;
    _contentAnim.reset();
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        )
        .then((_) => _isAnimating = false);
    _contentAnim.forward();
  }

  void _goNext() {
    if (_currentIndex < _totalPages - 1) _goTo(_currentIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentIndex == 0
          ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          itemCount: _totalPages,
          onPageChanged: (i) {
            setState(() => _currentIndex = i);
            _contentAnim.reset();
            _contentAnim.forward();
          },
          itemBuilder: (_, i) {
            if (i == 0) return _SplashSlide(splashAnim: _splashLogoAnim, onNext: _goNext, onSkip: _finish);
            final data = _photoSlides[i - 1];
            return _PhotoSlide(
              data: data,
              slideIndex: i,
              currentIndex: _currentIndex,
              totalPhotoSlides: _photoSlides.length,
              contentAnim: _contentAnim,
              orbAnim: _orbAnim,
              isLast: i == _totalPages - 1,
              onNext: _goNext,
              onFinish: _finish,
              onSkip: _finish,
            );
          },
        ),
      ),
    );
  }
}

// ─── Splash Slide ─────────────────────────────────────────────────────────────
class _SplashSlide extends StatelessWidget {
  const _SplashSlide({
    required this.splashAnim,
    required this.onNext,
    required this.onSkip,
  });

  final AnimationController splashAnim;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative background blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                 color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                 color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 8),
                    child: TextButton(
                      onPressed: onSkip,
                      child: Text(
                        'Lewati',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Floating animated logo
                AnimatedBuilder(
                  animation: splashAnim,
                  builder: (_, child) {
                    final t = CurvedAnimation(
                      parent: splashAnim,
                      curve: Curves.easeInOut,
                    ).value;
                    return Transform.translate(
                      offset: Offset(0, -10 * t),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                               color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.bolt, color: Colors.white, size: 56),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Digital Logsheet\nPLTD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF14532D),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Solusi pencatatan operasional mesin\nyang cepat, akurat, dan modern',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF166534),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Feature pills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(icon: Icons.flash_on, label: 'Cepat'),
                      const SizedBox(width: 12),
                      _FeaturePill(icon: Icons.my_location, label: 'Akurat'),
                      const SizedBox(width: 12),
                      _FeaturePill(icon: Icons.sync, label: 'Sinkron'),
                    ],
                  ),
                ),

                const Spacer(),

                // CTA button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _GreenButton(
                    label: 'Mulai Perjalanan →',
                    onTap: onNext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Photo Slide ──────────────────────────────────────────────────────────────
class _PhotoSlide extends StatelessWidget {
  const _PhotoSlide({
    required this.data,
    required this.slideIndex,
    required this.currentIndex,
    required this.totalPhotoSlides,
    required this.contentAnim,
    required this.orbAnim,
    required this.isLast,
    required this.onNext,
    required this.onFinish,
    required this.onSkip,
  });

  final _OnboardingData data;
  final int slideIndex;
  final int currentIndex;
  final int totalPhotoSlides;
  final AnimationController contentAnim;
  final AnimationController orbAnim;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.network(
          data.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1F2937),
            ),
          ),

        // Animated orbs
        AnimatedBuilder(
          animation: orbAnim,
          builder: (_, __) {
            final t = CurvedAnimation(parent: orbAnim, curve: Curves.easeInOut).value;
            return Stack(
              children: [
                Positioned(
                  top: -40 + (t * 20),
                  right: -40 + (t * 10),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                           data.orbColor1.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 180 + (t * 15),
                  left: -50 + (t * 8),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                           data.orbColor2.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Dark gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: [
                 Colors.black.withValues(alpha: 0.05),
                 Colors.black.withValues(alpha: 0.3),
                 Colors.black.withValues(alpha: 0.90),
              ],
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProgressBar(
                  currentIndex: slideIndex,
                  total: totalPhotoSlides + 1, // +1 for splash
                ),
              ),

              const SizedBox(height: 8),

              // Skip button
              if (!isLast)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: onSkip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                           color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                             color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'Lewati',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              // Bottom content
              _AnimatedSlideContent(
                animation: contentAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Swipe hint
                      Row(
                        children: [
                          Icon(
                            Icons.swipe,
                            size: 14,
                             color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Geser untuk lanjut',
                            style: TextStyle(
                               color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Icon + dots row
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                               color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                 color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(data.icon,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 16),
                          _PhotoDots(
                            total: totalPhotoSlides,
                            current: slideIndex - 1,
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Tag label
                      Text(
                        data.tag.toUpperCase(),
                        style: TextStyle(
                           color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        data.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Action button
                      _GreenButton(
                        label: isLast ? 'Mulai Sekarang 🚀' : 'Get Started',
                        onTap: isLast ? onFinish : onNext,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Progress bar (thin top bar) ─────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.currentIndex, required this.total});
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: currentIndex / (total - 1),
        minHeight: 3,
         backgroundColor: Colors.white.withValues(alpha: 0.18),
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

// ─── Photo slide dots ─────────────────────────────────────────────────────────
class _PhotoDots extends StatelessWidget {
  const _PhotoDots({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 6),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
             color: active ? Colors.white : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
            boxShadow: active
                ? [
                    BoxShadow(
                       color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ─── Animated content wrapper ─────────────────────────────────────────────────
class _AnimatedSlideContent extends StatelessWidget {
  const _AnimatedSlideContent({
    required this.animation,
    required this.child,
  });
  final AnimationController animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic).value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

// ─── Green CTA button with ripple ────────────────────────────────────────────
class _GreenButton extends StatefulWidget {
  const _GreenButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_GreenButton> createState() => _GreenButtonState();
}

class _GreenButtonState extends State<_GreenButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pressAnim,
      child: GestureDetector(
        onTapDown: (_) => _pressAnim.reverse(),
        onTapUp: (_) {
          _pressAnim.forward();
          widget.onTap();
        },
        onTapCancel: () => _pressAnim.forward(),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                 color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                 color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
