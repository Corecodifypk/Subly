import 'package:flutter/material.dart';

import '../services/brand_icon_service.dart';

class BrandIcon extends StatelessWidget {
  const BrandIcon({
    super.key,
    required this.name,
    this.size = 48,
    this.borderRadius = 12,
  });

  final String name;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final brand = BrandIconService.getBrand(name);

    if (name.toLowerCase().contains('netflix')) {
      return _netflixIcon();
    }
    if (name.toLowerCase().contains('spotify')) {
      return _spotifyIcon();
    }
    if (name.toLowerCase().contains('icloud')) {
      return _icloudIcon();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: brand.color,
        borderRadius: BorderRadius.circular(
          brand.isCircular ? size / 2 : borderRadius,
        ),
        gradient: name.toLowerCase().contains('icloud')
            ? const LinearGradient(
                colors: [Color(0xFF5AC8FA), Color(0xFFFF9500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Center(
        child: brand.icon != null
            ? Icon(brand.icon, color: brand.secondaryColor, size: size * 0.5)
            : Text(
                brand.label ?? name[0].toUpperCase(),
                style: TextStyle(
                  color: brand.secondaryColor,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _netflixIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          'N',
          style: TextStyle(
            color: const Color(0xFFE50914),
            fontSize: size * 0.55,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _spotifyIcon() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1DB954),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.graphic_eq, color: Colors.black, size: size * 0.55),
    );
  }

  Widget _icloudIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          colors: [Color(0xFF5AC8FA), Color(0xFFFF9500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.cloud, color: Colors.white, size: size * 0.55),
    );
  }
}
