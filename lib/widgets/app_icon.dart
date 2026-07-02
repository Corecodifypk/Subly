import 'package:flutter/material.dart';

/// Loads an icon from assets; falls back to a Material icon if the file is missing.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.assetPath,
    required this.fallback,
    this.size = 24,
    this.color,
    this.active = false,
    this.activeAssetPath,
    this.applyColorTint = false,
  });

  final String assetPath;
  final String? activeAssetPath;
  final IconData fallback;
  final double size;
  final Color? color;
  final bool active;
  /// When false, PNG/SVG assets render in their original colors (recommended for custom icons).
  final bool applyColorTint;

  @override
  Widget build(BuildContext context) {
    final path =
        active && activeAssetPath != null ? activeAssetPath! : assetPath;

    return Image.asset(
      path,
      width: size,
      height: size,
      gaplessPlayback: true,
      color: applyColorTint ? color : null,
      colorBlendMode: applyColorTint ? BlendMode.srcIn : null,
      errorBuilder: (_, error, stack) => Icon(
        fallback,
        size: size,
        color: color,
      ),
    );
  }
}
