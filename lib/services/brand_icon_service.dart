import 'package:flutter/material.dart';

class BrandInfo {
  const BrandInfo({
    required this.color,
    required this.secondaryColor,
    this.label,
    this.icon,
    this.isCircular = false,
  });

  final Color color;
  final Color secondaryColor;
  final String? label;
  final IconData? icon;
  final bool isCircular;
}

class BrandIconService {
  BrandIconService._();

  static final Map<String, BrandInfo> _brands = {
    'netflix': const BrandInfo(
      color: Color(0xFFE50914),
      secondaryColor: Color(0xFF000000),
      label: 'N',
    ),
    'spotify': const BrandInfo(
      color: Color(0xFF1DB954),
      secondaryColor: Color(0xFF000000),
      icon: Icons.music_note,
      isCircular: true,
    ),
    'icloud': const BrandInfo(
      color: Color(0xFF5AC8FA),
      secondaryColor: Color(0xFFFF9500),
      icon: Icons.cloud,
    ),
    'icloud+': const BrandInfo(
      color: Color(0xFF5AC8FA),
      secondaryColor: Color(0xFFFF9500),
      icon: Icons.cloud,
    ),
    'amazon prime': const BrandInfo(
      color: Color(0xFF00A8E1),
      secondaryColor: Color(0xFFFF9900),
      label: 'a',
    ),
    'amazon': const BrandInfo(
      color: Color(0xFF00A8E1),
      secondaryColor: Color(0xFFFF9900),
      label: 'a',
    ),
    'youtube': const BrandInfo(
      color: Color(0xFFFF0000),
      secondaryColor: Color(0xFFFFFFFF),
      icon: Icons.play_arrow,
    ),
    'hulu': const BrandInfo(
      color: Color(0xFF1CE783),
      secondaryColor: Color(0xFF000000),
      label: 'h',
    ),
    'dropbox': const BrandInfo(
      color: Color(0xFF0061FF),
      secondaryColor: Color(0xFFFFFFFF),
      icon: Icons.folder,
    ),
    'microsoft 365': const BrandInfo(
      color: Color(0xFFD83B01),
      secondaryColor: Color(0xFF0078D4),
      label: 'M',
    ),
    'microsoft': const BrandInfo(
      color: Color(0xFFD83B01),
      secondaryColor: Color(0xFF0078D4),
      label: 'M',
    ),
    'disney': const BrandInfo(
      color: Color(0xFF113CCF),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'D',
    ),
    'disney+': const BrandInfo(
      color: Color(0xFF113CCF),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'D',
    ),
    'apple music': const BrandInfo(
      color: Color(0xFFFC3C44),
      secondaryColor: Color(0xFFFFFFFF),
      icon: Icons.music_note,
    ),
    'apple': const BrandInfo(
      color: Color(0xFF000000),
      secondaryColor: Color(0xFFFFFFFF),
      icon: Icons.apple,
    ),
    'hbo': const BrandInfo(
      color: Color(0xFF5822B4),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'H',
    ),
    'max': const BrandInfo(
      color: Color(0xFF002BE7),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'M',
    ),
    'adobe': const BrandInfo(
      color: Color(0xFFFF0000),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'A',
    ),
    'notion': const BrandInfo(
      color: Color(0xFF000000),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'N',
    ),
    'slack': const BrandInfo(
      color: Color(0xFF4A154B),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'S',
    ),
    'zoom': const BrandInfo(
      color: Color(0xFF2D8CFF),
      secondaryColor: Color(0xFFFFFFFF),
      icon: Icons.videocam,
    ),
    'github': const BrandInfo(
      color: Color(0xFF24292E),
      secondaryColor: Color(0xFFFFFFFF),
      icon: Icons.code,
    ),
    'figma': const BrandInfo(
      color: Color(0xFFF24E1E),
      secondaryColor: Color(0xFFFFFFFF),
      label: 'F',
    ),
  };

  static BrandInfo getBrand(String name) {
    final key = name.toLowerCase().trim();
    if (_brands.containsKey(key)) return _brands[key]!;

    for (final entry in _brands.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hue = (name.hashCode % 360).toDouble();
    return BrandInfo(
      color: HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor(),
      secondaryColor: Colors.white,
      label: initial,
    );
  }

  static List<String> get suggestions => [
        'Netflix',
        'YouTube',
        'Amazon Prime Video',
        'Spotify',
        'Disney+',
      ];
}
