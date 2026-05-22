import 'package:flutter/material.dart';

import 'app_button.dart';
import 'app_empty_state.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.title = 'Terjadi kendala',
    this.helperText,
    this.onRetry,
    this.retryLabel = 'Coba Lagi',
    this.icon = Icons.error_outline_rounded,
  });

  final String message;
  final String title;
  final String? helperText;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: helperText == null || helperText!.trim().isEmpty
          ? message
          : '$message\n\n${helperText!.trim()}',
      icon: icon,
      action: onRetry == null
          ? null
          : AppButton(
              label: retryLabel,
              onPressed: onRetry,
              fullWidth: false,
            ),
    );
  }
}
