import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Shared glassmorphism surface used across the app to match the design mockups.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 28,
    this.opacity = 0.62,
    this.tint = AppColors.glassTint,
    this.borderColor = AppColors.glassBorder,
    this.padding,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.shadows = AppDecorations.glassShadow,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color tint;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxShape shape;
  final List<BoxShadow> shadows;

  BorderRadius get _radius {
    if (shape == BoxShape.circle) {
      final size = width ?? height ?? 48;
      return BorderRadius.circular(size / 2);
    }
    return BorderRadius.circular(borderRadius);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              shape: shape,
              borderRadius: shape == BoxShape.rectangle ? _radius : null,
              color: tint.withValues(alpha: opacity),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Solid white card with the soft diffused shadow from the design.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.color = AppColors.cardWhite,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppDecorations.softCardShadow,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class AppDecorations {
  AppDecorations._();

  static const softCardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const glassShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}
