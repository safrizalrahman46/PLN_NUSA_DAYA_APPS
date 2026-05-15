import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_shimmer.dart';
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

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'operator');
  final _passwordController = TextEditingController(text: '123');
  var _obscurePassword = true;
  var _loadingHero = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loadingHero = false);
    });
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            Positioned(
              left: -80,
              top: -10,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.highlight.withValues(alpha: 0.26),
                ),
              ),
            ),
            Positioned(
              right: -70,
              top: 120,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _loadingHero
                      ? AppShimmer(child: const SizedBox(height: 220))
                      : const LoginHeader(),
                  const SizedBox(height: 22),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Masuk ke sistem',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gunakan akun demo operator/supervisor/admin/superadmin, password: 123.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.sunsetGlow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const AppBrandLogo.mark(width: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (authState.errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Text(
                              authState.errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.danger),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        LoginForm(
                          formKey: _formKey,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
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
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: AppColors.softSurfaceGradient,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.security_rounded,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Login aman untuk operator & supervisor PLTD.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Text(
                          'Login cepat akun demo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        ...DummyData.users
                            .where(
                              (user) =>
                                  user.username == 'operator' ||
                                  user.username == 'supervisor' ||
                                  user.username == 'admin' ||
                                  user.username == 'superadmin',
                            )
                            .map(
                              (user) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DemoAccountTile(
                                  user: user,
                                  onUseAccount: () => _quickLogin(user),
                                  onFillOnly: () {
                                    _usernameController.text = user.username;
                                    _passwordController.text = '123';
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.appVersion,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  const _DemoAccountTile({
    required this.user,
    required this.onUseAccount,
    required this.onFillOnly,
  });

  final UserModel user;
  final VoidCallback onUseAccount;
  final VoidCallback onFillOnly;

  @override
  Widget build(BuildContext context) {
    final color = switch (user.role.name) {
      'operator' => Colors.green,
      'supervisor' => Colors.blue,
      'admin' => Colors.orange,
      'superadmin' => Colors.red,
      _ => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(Icons.person_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${user.role.label} • ${user.username}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Text(
                  user.role.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OverflowBar(
            spacing: 10,
            overflowSpacing: 10,
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width < 380
                    ? double.infinity
                    : (MediaQuery.of(context).size.width - 86) / 2,
                child: AppButton(
                  label: 'Isi Akun',
                  onPressed: onFillOnly,
                  type: AppButtonType.outlined,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width < 380
                    ? double.infinity
                    : (MediaQuery.of(context).size.width - 86) / 2,
                child: AppButton(
                  label: 'Login Sekarang',
                  onPressed: onUseAccount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
