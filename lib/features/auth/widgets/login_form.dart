import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class LoginForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Welcome Back" heading inside the form card (like Jobsly)
          Text(
            'Selamat Datang',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Masukkan detail akun Anda di bawah ini',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoft,
                ),
          ),
          const SizedBox(height: 28),

          // Username field
          _FieldLabel(label: 'Username / NIK'),
          const SizedBox(height: 6),
          AppTextField(
            controller: usernameController,
            label: 'Username / NIK',
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Username wajib diisi'
                : null,
          ),
          const SizedBox(height: 18),

          // Password field
          _FieldLabel(label: 'Password'),
          const SizedBox(height: 6),
          AppTextField(
            controller: passwordController,
            label: 'Password',
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textSoft,
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

          // Remember me + forgot password row
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: rememberMe,
                  onChanged: (value) => onRememberChanged(value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ingat saya',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lupa password?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Login button — full width gradient like Jobsly
          AppButton(label: 'Masuk', onPressed: onSubmit, isLoading: isLoading),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSoft,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
    );
  }
}