import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/user_model.dart';
import 'auth_controller.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';
import '../../data/local/hive_service.dart';

final demoStatusProvider = FutureProvider<bool>((ref) async {
  try {
    final hive = ref.read(hiveServiceProvider);
    final box = hive.usersBox;
    
    final defaultUsernames = [
      'operator', 'operator.krayan', 'operator.tanahmerah', 'operator.longpeso', 
      'operator.longlayu', 'operator.site07', 'supervisor', 'admin', 'superadmin', 'kal3'
    ];
    
    int customCount = 0;
    for (final key in box.keys) {
      if (!defaultUsernames.contains(key.toString())) {
        customCount++;
      }
    }
    
    return customCount == 0;
  } catch (_) {
    return true;
  }
});

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  // Animation controllers
  late final AnimationController _entranceController;
  late final AnimationController _orbController;

  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _sheetFade;
  late final Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _sheetFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _orbController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .login(_usernameController.text, _passwordController.text);
    if (!mounted || !success) return;
    final user = ref.read(authControllerProvider).user;
    final shell = user?.isOperator == true
        ? AppRoutes.operatorShell
        : user?.isSupervisor == true
        ? AppRoutes.supervisorShell
        : AppRoutes.adminShell;

    debugPrint('API Role: ${user?.role.name}');
    debugPrint('Mapped Role: ${user?.role}');
    debugPrint('Redirect To: $shell');

    Navigator.pushReplacementNamed(
      context,
      shell,
    );
  }

  Future<void> _quickLogin(UserModel user) async {
    _usernameController.text = user.username;
    _passwordController.text = '123';
    setState(() {});
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final showDemo = ref.watch(demoStatusProvider).valueOrNull ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final demoUsers = DummyData.users
        .where(
          (u) => ['operator', 'supervisor', 'admin', 'superadmin']
              .contains(u.username),
        )
        .toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : AppColors.heroGradient,
        ),
        child: Stack(
          children: [
            // Animated aurora orbs
            _AnimatedOrb(
              controller: _orbController,
              left: -80,
              top: -20,
              size: 260,
              color: AppColors.auroraBlue,
              alpha: 0.35,
              phase: 0,
            ),
            _AnimatedOrb(
              controller: _orbController,
              right: -50,
              top: 80,
              size: 200,
              color: AppColors.auroraCyan,
              alpha: 0.22,
              phase: 0.5,
            ),
            _AnimatedOrb(
              controller: _orbController,
              left: -20,
              bottom: 100,
              size: 180,
              color: AppColors.auroraViolet,
              alpha: 0.18,
              phase: 1.0,
            ),

            // Subtle grid noise overlay for premium feel
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: isDark ? 0.05 : 0.03,
                  child: const _DotGridOverlay(),
                ),
              ),
            ),

            // Main layout
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Hero section — floats on gradient
                      SizedBox(
                        height: constraints.maxHeight * 0.36,
                        child: Center(
                          child: FadeTransition(
                            opacity: _heroFade,
                            child: SlideTransition(
                              position: _heroSlide,
                              child: const LoginHeader(),
                            ),
                          ),
                        ),
                      ),
                      // Form bottom sheet
                      FadeTransition(
                        opacity: _sheetFade,
                        child: SlideTransition(
                          position: _sheetSlide,
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight * 0.64,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(36),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, -6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Drag handle indicator
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.textSoft
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                // Form header row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ShaderMask(
                                            shaderCallback: (bounds) =>
                                                AppColors.sunsetGlow
                                                    .createShader(bounds),
                                            child: Text(
                                              'Masuk ke Sistem',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                    height: 1.1,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Gunakan kredensial akun PLN Nusa Daya Anda',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textSoft,
                                                  height: 1.4,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Animated brand badge
                                    _PulseBadge(
                                      controller: _orbController,
                                      child: Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.sunsetGlow,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.highlight
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 14,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(9),
                                        child:
                                            const AppBrandLogo.mark(width: 28),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                // Animated error banner
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 260),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        axisAlignment: -1,
                                        child: child,
                                      ),
                                    ),
                                    child: authState.errorMessage != null
                                        ? Padding(
                                            key: ValueKey(
                                              authState.errorMessage,
                                            ),
                                            padding: const EdgeInsets.only(
                                              bottom: 14,
                                            ),
                                            child:
                                                _ErrorBanner(
                                                  message:
                                                      authState.errorMessage!,
                                                ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                                // Login form
                                LoginForm(
                                  formKey: _formKey,
                                  usernameController: _usernameController,
                                  passwordController: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  onTogglePassword: () => setState(
                                    () =>
                                        _obscurePassword = !_obscurePassword,
                                  ),
                                  rememberMe: authState.rememberMe,
                                  onRememberChanged: (value) => ref
                                      .read(authControllerProvider.notifier)
                                      .toggleRememberMe(value),
                                  isLoading: authState.isLoading,
                                  onSubmit: _submit,
                                  onForgotPassword: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  ),
                                ),
                                if (showDemo) ...[
                                  const SizedBox(height: 26),
                                  // Divider with label
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context)
                                                    .dividerColor
                                                    .withValues(alpha: 0),
                                                Theme.of(context).dividerColor,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Text(
                                          'Login cepat akun demo',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSoft,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context).dividerColor,
                                                Theme.of(context)
                                                    .dividerColor
                                                    .withValues(alpha: 0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // 2×2 role grid with staggered entrance
                                  GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 2.7,
                                    children: List.generate(
                                      demoUsers.length,
                                      (index) {
                                        final user = demoUsers[index];
                                        return _StaggeredFadeIn(
                                          delay: Duration(
                                            milliseconds: 600 + (index * 90),
                                          ),
                                          child: _RoleTile(
                                            user: user,
                                            onTap: () => _quickLogin(user),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 22),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.textSoft
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      AppStrings.appVersion,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSoft,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Helper Widgets ─────────────────────────

/// Pulsing aurora orb that gently drifts in size/opacity.
class _AnimatedOrb extends StatelessWidget {
  const _AnimatedOrb({
    required this.controller,
    required this.size,
    required this.color,
    required this.alpha,
    required this.phase,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  final AnimationController controller;
  final double size;
  final Color color;
  final double alpha;
  final double phase;
  final double? left, right, top, bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = (controller.value + phase) % 1.0;
          final wave = math.sin(t * math.pi * 2) * 0.5 + 0.5; // 0..1
          final scale = 0.85 + (wave * 0.30);
          final opacity = alpha * (0.75 + wave * 0.35);
          return Transform.scale(
            scale: scale,
            child: Container(
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
            ),
          );
        },
      ),
    );
  }
}

/// Soft pulsing ring around the brand badge.
class _PulseBadge extends StatelessWidget {
  const _PulseBadge({required this.controller, required this.child});

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final wave = math.sin(controller.value * math.pi * 2) * 0.5 + 0.5;
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.highlight.withValues(alpha: 0.10 + wave * 0.18),
              width: 1.2,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Decorative dot grid used as a subtle texture in the gradient.
class _DotGridOverlay extends StatelessWidget {
  const _DotGridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 22.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated error banner with shake-friendly entrance.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plays a one-shot fade + slide-up after [delay].
class _StaggeredFadeIn extends StatefulWidget {
  const _StaggeredFadeIn({required this.child, required this.delay});
  final Widget child;
  final Duration delay;

  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
}

/// Interactive role tile with press scale + glow on hover.
class _RoleTile extends StatefulWidget {
  const _RoleTile({required this.user, required this.onTap});

  final UserModel user;
  final VoidCallback onTap;

  @override
  State<_RoleTile> createState() => _RoleTileState();
}

class _RoleTileState extends State<_RoleTile> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.user.role) {
      UserRole.operator => AppColors.success,
      UserRole.supervisor => AppColors.primary,
      UserRole.admin => AppColors.highlight,
      UserRole.superadmin => AppColors.danger,
    };

    final icon = switch (widget.user.role) {
      UserRole.operator => Icons.engineering_rounded,
      UserRole.supervisor => Icons.supervisor_account_rounded,
      UserRole.admin => Icons.admin_panel_settings_rounded,
      UserRole.superadmin => Icons.shield_rounded,
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(
                  alpha: _hovered ? 0.45 : 0.22,
                ),
                width: _hovered ? 1.4 : 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: _hovered ? 0.14 : 0.06),
                  color.withValues(alpha: _hovered ? 0.06 : 0.02),
                ],
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: _hovered ? 0.30 : 0.16),
                        color.withValues(alpha: _hovered ? 0.18 : 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.role.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.user.username,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(_hovered ? 2 : 0, 0, 0),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}