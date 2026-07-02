import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../services/unity_ads_instances.dart';
import '../services/unity_interstitial_ad.dart';

/// Splash screen — replace animation at assets/animations/splash.json when ready.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      if (!unityAds.isInitialized) {
        await unityAds.initialize();
      }
      if (unityAds.isInitialized) {
        unawaited(splashInterstitial.loadAd());
        unawaited(actionRewarded.preload());
      }

      await Future<void>.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      if (unityAds.isInitialized) {
        await splashInterstitial.loadAd();
        if (mounted && splashInterstitial.isReady) {
          await AdLoadingOverlay.run(
            context: context,
            task: () => splashInterstitial.showAndWait(onClosed: () {}),
          );
        }
      }
    } catch (e) {
      debugPrint('[Ads] Splash ad flow error: $e');
    }

    if (mounted) widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: _buildAnimation(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Subly',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track every subscription',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    return Lottie.asset(
      AssetPaths.splash,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.subscriptions_rounded,
        size: 96,
        color: AppColors.primaryPurple,
      ),
    );
  }
}
