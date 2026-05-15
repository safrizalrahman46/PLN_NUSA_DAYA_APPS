import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF142239) : const Color(0xFFE4EBF3),
      highlightColor: isDark
          ? const Color(0xFF223553)
          : const Color(0xFFF6F9FC),
      child: child,
    );
  }

  static Widget block({double? width, double height = 16, double radius = 12}) {
    return Builder(
      builder: (context) => AppShimmer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
