import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../services/unity_ads_instances.dart';
import '../services/unity_interstitial_ad.dart';

/// Splash screen with branded logo while ads initialize.
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
    final logoWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Image.asset(
            AssetPaths.splashLogo,
            width: logoWidth,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.subscriptions_rounded,
              size: 96,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
      ),
    );
  }
}
