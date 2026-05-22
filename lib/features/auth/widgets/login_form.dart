import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.rememberMe,
    required this.onRememberChanged,
    required this.isLoading,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final bool rememberMe;
  final ValueChanged<bool> onRememberChanged;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          _AnimatedFieldWrapper(
            focused: _usernameFocus.hasFocus,
            child: AppTextField(
              controller: widget.usernameController,
              focusNode: _usernameFocus,
              label: 'Username / NIK',
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: _usernameFocus.hasFocus
                      ? AppColors.primary
                      : AppColors.textSoft,
                  size: 20,
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Username wajib diisi'
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          _AnimatedFieldWrapper(
            focused: _passwordFocus.hasFocus,
            child: AppTextField(
              controller: widget.passwordController,
              focusNode: _passwordFocus,
              label: 'Password',
              obscureText: widget.obscurePassword,
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: _passwordFocus.hasFocus
                      ? AppColors.primary
                      : AppColors.textSoft,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: widget.onTogglePassword,
                splashRadius: 20,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    widget.obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    key: ValueKey(widget.obscurePassword),
                    color: _passwordFocus.hasFocus
                        ? AppColors.primary
                        : AppColors.textSoft,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password wajib diisi';
                }
                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 6),
          // Remember + Forgot password row
          Row(
            children: [
              // Custom animated checkbox
              _CustomCheckbox(
                value: widget.rememberMe,
                onChanged: widget.onRememberChanged,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => widget.onRememberChanged(!widget.rememberMe),
                child: Text(
                  'Ingat saya',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onForgotPassword,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lupa password?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated login button with subtle press shadow
          _AnimatedSubmitButton(
            label: 'Login',
            onPressed: widget.onSubmit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}

/// Glow ring that fades in when its child field has focus.
class _AnimatedFieldWrapper extends StatelessWidget {
  const _AnimatedFieldWrapper({
    required this.child,
    required this.focused,
  });

  final Widget child;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}

/// Custom animated checkbox with a check-mark draw-in feel.
class _CustomCheckbox extends StatelessWidget {
  const _CustomCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: value
                ? AppColors.primary
                : AppColors.textSoft.withValues(alpha: 0.45),
            width: 1.6,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: value
              ? const Icon(
                  Icons.check_rounded,
                  key: ValueKey(true),
                  color: Colors.white,
                  size: 16,
                )
              : const SizedBox.shrink(key: ValueKey(false)),
        ),
      ),
    );
  }
}

/// Wraps [AppButton] with a press-scale animation. Falls back transparently
/// if your [AppButton] already handles loading state.
class _AnimatedSubmitButton extends StatefulWidget {
  const _AnimatedSubmitButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<_AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<_AnimatedSubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: AppButton(
            label: widget.label,
            onPressed: widget.onPressed,
            isLoading: widget.isLoading,
          ),
        ),
      ),
    );
  }
}