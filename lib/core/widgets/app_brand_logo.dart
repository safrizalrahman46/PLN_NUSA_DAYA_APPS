import 'package:flutter/material.dart';

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo.full({
    super.key,
    this.width = 120,
    this.height,
    this.withContainer = false,
  }) : _assetPath = 'assets/images/logo_pln_text.png';

  const AppBrandLogo.mark({
    super.key,
    this.width = 56,
    this.height,
    this.withContainer = false,
  }) : _assetPath = 'assets/images/logo_pln_notext.png';

  final double width;
  final double? height;
  final bool withContainer;
  final String _assetPath;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      _assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!withContainer) {
      return logo;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: logo,
    );
  }
}
