import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'glass_card.dart';

class AppLoading extends StatefulWidget {
  const AppLoading({super.key, this.label = 'Memuat data...'});

  final String label;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnim,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    AppColors.heroGradient.createShader(bounds),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(widget.label,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
      ),
    );
  }
}
