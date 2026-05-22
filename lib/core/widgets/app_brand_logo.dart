import 'package:flutter/material.dart';

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo.full({
    super.key,
    this.width = 148,
    this.height,
    this.withContainer = false,
  }) : _assetPath = 'assets/images/PLND.png',
        _showWordmark = true;

  const AppBrandLogo.mark({
    super.key,
    this.width = 56,
    this.height,
    this.withContainer = false,
  }) : _assetPath = 'assets/images/PLND.png',
        _showWordmark = false;

  final double width;
  final double? height;
  final bool withContainer;
  final String _assetPath;
  final bool _showWordmark;

  @override
  Widget build(BuildContext context) {
    final logo = _showWordmark ? _buildWordmark(context) : _buildMark();

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

  Widget _buildMark() {
    return Image.asset(
      _assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildWordmark(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
