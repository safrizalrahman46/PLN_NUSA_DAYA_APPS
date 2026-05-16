import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/user_model.dart';
import 'auth_controller.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'operator');
  final _passwordController = TextEditingController(text: '123');
  var _obscurePassword = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
    Navigator.pushReplacementNamed(
      context,
      user?.isOperator == true
          ? AppRoutes.operatorShell
          : AppRoutes.supervisorShell,
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Top gradient header (≈42% screen height) ──────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.splashGradient,
              ),
              child: Stack(
                children: [
                  // Aurora orbs (subtle, top area only)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => Stack(
                      children: [
                        Positioned(
                          left: -80,
                          top: -60,
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.auroraCyan.withValues(alpha: 0.22),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -60,
                          top: 30,
                          child: Transform.scale(
                            scale: 1.1 - (_pulseAnimation.value * 0.1),
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.auroraViolet.withValues(alpha: 0.20),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── White bottom sheet (overlaps header, rounded top) ──────────
          Positioned(
            top: size.height * 0.34,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header / branding inside the blue area
                SizedBox(
                  height: size.height * 0.34,
                  child: const Center(child: LoginHeader()),
                ),

                // White card area starts here
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Error banner
                      if (authState.errorMessage != null) ...[
                        _ErrorBanner(message: authState.errorMessage!),
                        const SizedBox(height: 16),
                      ],

                      // Login form
                      LoginForm(
                        formKey: _formKey,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        rememberMe: authState.rememberMe,
                        onRememberChanged: (v) => ref.read(authControllerProvider.notifier).toggleRememberMe(v),
                        isLoading: authState.isLoading,
                        onSubmit: _submit,
                        onForgotPassword: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Divider "or"
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Atau gunakan akun demo',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSoft,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Demo accounts section
                      _DemoAccountsSection(
                        onUse: _quickLogin,
                        onFill: (user) {
                          _usernameController.text = user.username;
                          _passwordController.text = '123';
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      Text(
                        AppStrings.appVersion,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSoft,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 24),
                    ],
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

// ─────────────────────────────────────────────
// Error banner
// ─────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Demo accounts section
// ─────────────────────────────────────────────
class _DemoAccountsSection extends StatelessWidget {
  const _DemoAccountsSection({
    required this.onUse,
    required this.onFill,
  });

  final void Function(UserModel) onUse;
  final void Function(UserModel) onFill;

  @override
  Widget build(BuildContext context) {
    final demoUsers = DummyData.users.where(
      (u) => ['operator', 'supervisor', 'admin', 'superadmin']
          .contains(u.username),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akun Demo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Password semua akun: 123',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.border,
          ),

          const SizedBox(height: 14),

          // Accounts list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: demoUsers.map((user) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DemoAccountTile(
                    user: user,
                    onUseAccount: () => onUse(user),
                    onFillOnly: () => onFill(user),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Demo account tile (redesigned)
// ─────────────────────────────────────────────
class _DemoAccountTile extends StatefulWidget {
  const _DemoAccountTile({
    required this.user,
    required this.onUseAccount,
    required this.onFillOnly,
  });

  final UserModel user;
  final VoidCallback onUseAccount;
  final VoidCallback onFillOnly;

  @override
  State<_DemoAccountTile> createState() => _DemoAccountTileState();
}

class _DemoAccountTileState extends State<_DemoAccountTile> {
  bool _hovered = false;

  static const _roleConfig = {
    'operator': (
      color: Color(0xFF10B981),
      icon: Icons.engineering_rounded,
      label: 'Operator',
      gradientEnd: Color(0xFFD1FAE5),
    ),
    'supervisor': (
      color: Color(0xFF3B82F6),
      icon: Icons.supervisor_account_rounded,
      label: 'Supervisor',
      gradientEnd: Color(0xFFDBEAFE),
    ),
    'admin': (
      color: Color(0xFFF59E0B),
      icon: Icons.admin_panel_settings_rounded,
      label: 'Admin',
      gradientEnd: Color(0xFFFEF3C7),
    ),
    'superadmin': (
      color: Color(0xFFEF4444),
      icon: Icons.security_rounded,
      label: 'Super Admin',
      gradientEnd: Color(0xFFFEE2E2),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _roleConfig[widget.user.role.name] ??
        (
          color: AppColors.primary,
          icon: Icons.person_rounded,
          label: widget.user.role.label,
          gradientEnd: Colors.white,
        );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              cfg.color.withValues(alpha: _hovered ? 0.12 : 0.07),
              cfg.gradientEnd.withValues(alpha: _hovered ? 0.9 : 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: cfg.color.withValues(alpha: _hovered ? 0.35 : 0.18),
            width: _hovered ? 1.5 : 1.0,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: cfg.color.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cfg.color.withValues(alpha: 0.25),
                            cfg.color.withValues(alpha: 0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cfg.color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(cfg.icon, color: cfg.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${widget.user.username}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: cfg.color.withValues(alpha: 0.13),
                        border: Border.all(
                          color: cfg.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        cfg.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cfg.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _TileButton(
                        label: 'Isi Form',
                        icon: Icons.edit_rounded,
                        color: cfg.color,
                        outlined: true,
                        onPressed: widget.onFillOnly,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TileButton(
                        label: 'Login',
                        icon: Icons.login_rounded,
                        color: cfg.color,
                        outlined: false,
                        onPressed: widget.onUseAccount,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tile action button
// ─────────────────────────────────────────────
class _TileButton extends StatefulWidget {
  const _TileButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.outlined,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onPressed;

  @override
  State<_TileButton> createState() => _TileButtonState();
}

class _TileButtonState extends State<_TileButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.outlined
                ? Colors.white.withValues(alpha: 0.6)
                : widget.color,
            border: Border.all(
              color: widget.outlined
                  ? widget.color.withValues(alpha: 0.35)
                  : widget.color,
              width: 1.5,
            ),
            boxShadow: widget.outlined
                ? null
                : [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.outlined ? widget.color : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.outlined ? widget.color : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}