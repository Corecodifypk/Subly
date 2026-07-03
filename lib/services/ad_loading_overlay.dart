import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Root navigator for ad disclosure overlays when no [BuildContext] is passed.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Brief loading disclosure shown before full-screen ads (App Store / Play policy).
class AdLoadingOverlay {
  /// Minimum visible time before an ad may start.
  static const disclosureDuration = Duration(seconds: 1);

  static BuildContext? _resolveContext(BuildContext? context) {
    if (context != null && context.mounted) return context;
    return rootNavigatorKey.currentContext;
  }

  /// Shows a small loading indicator for at least [minVisible], then [showAd].
  static Future<void> runBeforeShow({
    BuildContext? context,
    required Future<void> Function() showAd,
    Duration minVisible = disclosureDuration,
  }) async {
    final ctx = _resolveContext(context);

    if (ctx == null) {
      await Future.delayed(minVisible);
      await showAd();
      return;
    }

    final navigator = Navigator.of(ctx, rootNavigator: true);

    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black26,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: _AdLoadingCard(),
          ),
        ),
      ),
    );

    await Future.delayed(minVisible);

    if (navigator.canPop()) {
      navigator.pop();
    }

    // Let the overlay dismiss before the full-screen ad takes over.
    await Future<void>.delayed(const Duration(milliseconds: 80));

    await showAd();
  }
}

class _AdLoadingCard extends StatelessWidget {
  const _AdLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading ad...',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
