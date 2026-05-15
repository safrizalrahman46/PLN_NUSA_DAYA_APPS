import 'package:flutter/material.dart';

import 'app_button.dart';
import 'app_empty_state.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'Terjadi kendala',
      message: message,
      icon: Icons.error_outline_rounded,
      action: onRetry == null
          ? null
          : AppButton(label: 'Coba Lagi', onPressed: onRetry, fullWidth: false),
    );
  }
}
