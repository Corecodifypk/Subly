import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../services/ad_loading_overlay.dart';
import '../services/tracking_transparency_service.dart';
import '../services/unity_ads_instances.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _logoSize = 120.0;

  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..forward();
    unawaited(_boot());
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      // iOS ATT system dialog — required before any ad / tracking SDK work.
      await TrackingTransparencyService.instance.ensureRequested();

      if (!mounted) return;

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
          await AdLoadingOverlay.runBeforeShow(
            context: context,
            showAd: () => splashInterstitial.showAndWait(onClosed: () {}),
          );
        }
      }
    } catch (e) {
      debugPrint('Splash error: $e');
    }

    if (!mounted) return;

    if (_progressController.value < 1) {
      await _progressController.forward(from: _progressController.value);
    }

    if (mounted) widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const _SplashBackground(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SplashLogo(),
                    const SizedBox(height: 32),
                    const _SplashTitle(),
                    const SizedBox(height: 8),
                    Text(
                      'Bill & Subscription Tracker',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 56),
                    const _SplashTagline(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 36,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => _SplashProgressBar(
                  progress: _progressController.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  static const _size = _SplashScreenState._logoSize;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetPaths.appLogo,
      width: _size,
      height: _size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          height: 1.05,
        ),
        children: [
          TextSpan(
            text: 'Sub',
            style: TextStyle(color: Color(0xFF1A1A1A)),
          ),
          TextSpan(
            text: 'Track',
            style: TextStyle(color: AppColors.primaryPurple),
          ),
        ],
      ),
    );
  }
}

class _SplashTagline extends StatelessWidget {
  const _SplashTagline();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 18,
          height: 1.45,
        ),
        children: [
          TextSpan(text: 'Track your subscriptions.\nStay organized. '),
          TextSpan(
            text: 'Save more.',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashProgressBar extends StatelessWidget {
  const _SplashProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: AppColors.primaryPurple.withValues(alpha: 0.14)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPurple,
                          AppColors.primaryPurpleDark,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Loading${'.' * ((progress * 3).floor() % 3 + 1)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -110,
          left: -110,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.08),
                width: 16,
              ),
            ),
          ),
        ),
        Positioned(
          top: 110,
          right: -60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPurple.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -30,
          right: -30,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(280),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.06),
                  AppColors.primaryPurple.withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
