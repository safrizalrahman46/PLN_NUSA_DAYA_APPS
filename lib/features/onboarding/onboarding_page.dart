import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../profile/settings_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _sheetCtrl;
  late final AnimationController _floatingCtrl;
  late final Animation<Offset> _sheetSlide;
  late final Animation<double> _sheetOpacity;
  late final Animation<double> _floatingAnim;

  int _currentPage = 0;

  final _slides = const [
    (
      imagePath: null,
      title: 'PLN Logsheet',
      subtitle: 'Pantau operasional mesin PLTD dengan mudah dan real-time',
      icon: Icons.description_outlined,
      color: Color(0xFF0A6FD8),
    ),
    (
      imagePath: 'assets/images/onboarding_1.png',
      title: 'Validasi GPS',
      subtitle: 'Lacak lokasi operator dan dokumentasi foto langsung dari lapangan.',
      icon: Icons.location_on_outlined,
      color: Color(0xFF23B7FF),
    ),
    (
      imagePath: 'assets/images/onboarding_2.png',
      title: 'Offline First',
      subtitle: 'Input laporan tanpa internet, data tersinkron otomatis saat online.',
      icon: Icons.cloud_off_outlined,
      color: Color(0xFF00D4FF),
    ),
    (
      imagePath: 'assets/images/onboarding_3.png',
      title: 'Koordinasi Tim',
      subtitle: 'Operator & supervisor bekerja sama dalam satu platform efisien.',
      icon: Icons.people_outline_rounded,
      color: Color(0xFF1CB3FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();

    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));
    _sheetOpacity = CurvedAnimation(
      parent: _sheetCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _floatingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _floatingCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _sheetCtrl.dispose();
    _floatingCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await ref.read(appSettingsProvider.notifier).setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _skip() => _finish();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen PageView with image background ──
          PageView.builder(
            controller: _pageCtrl,
            physics: const PageScrollPhysics(),
            scrollDirection: Axis.horizontal,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _sheetCtrl.reset();
              _sheetCtrl.forward();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) => _ImageSlideWidget(
              slide: _slides[index],
              floatingAnim: _floatingAnim,
            ),
          ),

          // ── Dark overlay gradient ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.65,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.25, 0.60, 1.0],
                ),
              ),
            ),
          ),

          // ── Top bar: Logo + Skip ──
          SafeArea(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.15),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _sheetCtrl,
                  curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
                ),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _sheetCtrl,
                    curve: const Interval(0, 0.4, curve: Curves.easeOut),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const AppBrandLogo.mark(width: 28),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            'Lewati',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Sheet with Content ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _sheetSlide,
              child: FadeTransition(
                opacity: _sheetOpacity,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Page indicator dots - Animated bars with stagger
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              _slides.length,
                              (i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: AnimatedBuilder(
                                  animation: _sheetOpacity,
                                  builder: (context, child) =>
                                      AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: i == _currentPage
                                        ? Curves.elasticOut
                                        : Curves.easeOutCubic,
                                    width: i == _currentPage ? 32 : 10,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: i == _currentPage
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.25),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                      boxShadow: i == _currentPage
                                          ? [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withValues(alpha: 0.40),
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Title with smooth entrance animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.20),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(parent: _sheetCtrl, 
                              curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic)),
                          ),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: 0,
                              end: 1,
                            ).animate(
                              CurvedAnimation(parent: _sheetCtrl,
                                curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, anim) =>
                                  SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.20, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: FadeTransition(
                                  opacity: anim,
                                  child: child,
                                ),
                              ),
                              child: Text(
                                _slides[_currentPage].title,
                                key: ValueKey(_currentPage),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                      letterSpacing: -0.8,
                                      fontSize: 36,
                                    ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Subtitle with smooth entrance animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.20),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(parent: _sheetCtrl,
                              curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic)),
                          ),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: 0,
                              end: 1,
                            ).animate(
                              CurvedAnimation(parent: _sheetCtrl,
                                curve: const Interval(0.15, 0.7, curve: Curves.easeOut)),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, anim) =>
                                  SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.20, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: FadeTransition(
                                  opacity: anim,
                                  child: child,
                                ),
                              ),
                              child: Text(
                                _slides[_currentPage].subtitle,
                                key: ValueKey('sub_$_currentPage'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.78),
                                      height: 1.7,
                                      fontSize: 16,
                                      letterSpacing: 0.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Get Started Button - Animated with floating & glow effect
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AnimatedBuilder(
                            animation: _floatingAnim,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(0, _floatingAnim.value * 0.5),
                              child: child,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _next,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.accent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.40),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: AppColors.accent
                                            .withValues(alpha: 0.20),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _currentPage == _slides.length - 1
                                          ? 'Selesai'
                                          : 'Get Started',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
// Image Slide Widget with Parallax
// ─────────────────────────────────────────────────────────────────────────────

class _ImageSlideWidget extends StatefulWidget {
  const _ImageSlideWidget({
    required this.slide,
    required this.floatingAnim,
  });

  final ({
    String? imagePath,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  }) slide;

  final Animation<double> floatingAnim;

  @override
  State<_ImageSlideWidget> createState() => _ImageSlideWidgetState();
}

class _ImageSlideWidgetState extends State<_ImageSlideWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.slide.imagePath == null)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(widget.slide.color, Colors.black, 0.3)!,
                  Color.lerp(widget.slide.color, Colors.black, 0.1)!,
                ],
              ),
            ),
            child: Stack(
              children: [
                _FloatingParticles(color: widget.slide.color),
                Center(
                  child: AnimatedBuilder(
                    animation: widget.floatingAnim,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, -widget.floatingAnim.value),
                      child: child,
                    ),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.18),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.slide.color.withValues(alpha: 0.25),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.slide.icon,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _ImageAssetWidget(
            imagePath: widget.slide.imagePath!,
            fallbackColor: widget.slide.color,
          ),

        // Subtle shine effect
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Particles Background
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles({required this.color});
  final Color color;

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _ParticleOrb(
          animation: _ctrl1,
          size: 280,
          left: -80,
          top: -60,
          color: widget.color,
        ),
        _ParticleOrb(
          animation: _ctrl2,
          size: 220,
          right: -50,
          top: 80,
          color: widget.color.withValues(alpha: 0.8),
        ),
        _ParticleOrb(
          animation: _ctrl3,
          size: 200,
          left: -30,
          bottom: 100,
          color: widget.color.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}

class _ParticleOrb extends StatelessWidget {
  const _ParticleOrb({
    required this.animation,
    required this.size,
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.color,
  });

  final AnimationController animation;
  final double size;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.scale(
          scale: 0.7 + (animation.value * 0.35),
          child: Opacity(
            opacity: 0.15 + (0.1 * (1 - (animation.value - 0.5).abs() * 2)),
            child: child,
          ),
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.30),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image Asset Widget with Better Error Handling
// ─────────────────────────────────────────────────────────────────────────────

class _ImageAssetWidget extends StatelessWidget {
  const _ImageAssetWidget({
    required this.imagePath,
    required this.fallbackColor,
  });

  final String imagePath;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Image failed to load: $imagePath');
        debugPrint('Error: $error');
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                fallbackColor.withValues(alpha: 0.6),
                fallbackColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white.withValues(alpha: 0.30),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gambar tidak ditemukan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

