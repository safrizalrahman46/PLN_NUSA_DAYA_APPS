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
        children: [
          AppTextField(
            controller: usernameController,
            label: 'Username / NIK',
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Username wajib diisi'
                : null,
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (value) {
                  onRememberChanged(value ?? false);
                },
              ),
              Text(
                'Ingat saya',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onForgotPassword,
                child: const Text('Lupa password'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(label: 'Login', onPressed: onSubmit, isLoading: isLoading),
        ],
      ),
    );
  }
}
