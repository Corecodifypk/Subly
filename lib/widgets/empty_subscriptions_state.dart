import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';

/// Empty state using your Lottie file from assets/animations/notfound.json
class EmptySubscriptionsState extends StatelessWidget {
  const EmptySubscriptionsState({
    super.key,
    this.title = 'No subscriptions yet',
    this.subtitle = 'Tap + to add your first subscription',
    this.height = 200,
  });

  final String title;
  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              AssetPaths.notFound,
              width: 140,
              height: 110,
            fit: BoxFit.contain,
            repeat: true,
            errorBuilder: (_, error, stack) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurpleLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.subscriptions_outlined,
                  size: 48,
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
