import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // PLN logo
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/logo_pln_notext.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),

        // App name
        Text(
          'PLN Nusa Daya',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          AppStrings.subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.4,
              ),
        ),
      ],
    );
  }
}