import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../services/unity_ads_instances.dart';
import '../services/unity_interstitial_ad.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
  });

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

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      if (unityAds.isInitialized) {
        await splashInterstitial.loadAd();

        if (mounted && splashInterstitial.isReady) {
          await AdLoadingOverlay.run(
            context: context,
            task: () => splashInterstitial.showAndWait(
              onClosed: () {},
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Splash Error : $e");
    }

    if (mounted) {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            //================ Background =================//

            Positioned(
              top: -120,
              left: -120,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(.08),
                    width: 18,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 120,
              right: -70,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPurple.withOpacity(.04),
                ),
              ),
            ),

            Positioned(
              bottom: -170,
              left: -40,
              right: -40,
              child: Container(
                height: 340,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(300),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryPurple.withOpacity(.08),
                      AppColors.primaryPurple.withOpacity(.28),
                    ],
                  ),
                ),
              ),
            ),

            //================ Main Content =================//

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 35,
                            spreadRadius: 2,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          AssetPaths.splashLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.primaryPurple,
                              size: 90,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          const TextSpan(
                            text: "Sub",
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: "Track",
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Bill & Subscription Tracker",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .4,
                      ),
                    ),

                    const SizedBox(height: 70),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text:
                            "Track your subscriptions.\nStay organized. ",
                          ),
                          TextSpan(
                            text: "Save more.",
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 45),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(false),
                        const SizedBox(width: 10),
                        _dot(true),
                        const SizedBox(width: 10),
                        _dot(false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 14 : 10,
      height: active ? 14 : 10,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryPurple
            : AppColors.primaryPurple.withOpacity(.25),
        shape: BoxShape.circle,
      ),
    );
  }
}