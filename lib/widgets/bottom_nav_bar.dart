import 'package:flutter/material.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import 'app_icon.dart';
import 'glass_surface.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeLabel,
    this.onFabTap,
    this.showAddSubsFab = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? activeLabel;
  final VoidCallback? onFabTap;
  final bool showAddSubsFab;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = isTablet ? 72.0 : 64.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: GlassSurface(
              borderRadius: 36,
              blur: 32,
              opacity: 0.72,
              tint: const Color(0xFFF5F5F7),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: SizedBox(
                height: barHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        assetPath: AssetPaths.bottomNavHome,
                        fallback: Icons.home_outlined,
                        label: 'Home',
                        isActive: currentIndex == 0,
                        activeLabel: activeLabel,
                        onTap: () => onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        assetPath: AssetPaths.bottomNavCalendar,
                        fallback: Icons.calendar_today_outlined,
                        label: 'Calendar',
                        isActive: currentIndex == 1,
                        activeLabel: activeLabel,
                        onTap: () => onTap(1),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        assetPath: AssetPaths.bottomNavReports,
                        fallback: Icons.bar_chart_outlined,
                        label: 'Reports',
                        isActive: currentIndex == 2,
                        activeLabel: activeLabel,
                        onTap: () => onTap(2),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        assetPath: AssetPaths.bottomNavSettings,
                        fallback: Icons.settings_outlined,
                        label: 'Settings',
                        isActive: currentIndex == 3,
                        activeLabel: activeLabel,
                        onTap: () => onTap(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (showAddSubsFab)
            _AddSubsButton(onTap: onFabTap)
          else
            _GlassFabButton(onTap: onFabTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.assetPath,
    required this.fallback,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeLabel,
  });

  final String assetPath;
  final IconData fallback;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? activeLabel;

  @override
  Widget build(BuildContext context) {
    final displayLabel = isActive ? (activeLabel ?? label) : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 10 : 6,
            vertical: isActive ? 3 : 6,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryPurpleLight.withValues(alpha: 0.85)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  assetPath: assetPath,
                  fallback: fallback,
                  size: 22,
                  active: isActive,
                ),
                if (displayLabel != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPurpleDark,
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassFabButton extends StatelessWidget {
  const _GlassFabButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        shape: BoxShape.circle,
        blur: 28,
        opacity: 0.78,
        tint: Colors.white,
        width: 56,
        height: 56,
        child: Center(
          child: AppIcon(
            assetPath: AssetPaths.bottomNavAdd,
            fallback: Icons.add,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _AddSubsButton extends StatelessWidget {
  const _AddSubsButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        borderRadius: 32,
        blur: 24,
        opacity: 0.85,
        tint: Colors.white,
        width: 68,
        height: 64,
        child: const Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  assetPath: AssetPaths.bottomNavAdd,
                  fallback: Icons.add,
                  size: 20,
                ),
                SizedBox(height: 1),
                Text(
                  'Add Subs',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurpleDark,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
