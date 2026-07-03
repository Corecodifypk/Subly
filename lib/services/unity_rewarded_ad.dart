import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'ad_loading_overlay.dart';
import 'unity_ads_service.dart';

class UnityRewardedAd {
  final UnityAdsService _adsService = UnityAdsService();
  final String placementId;

  bool _isLoaded = false;
  bool _isLoading = false;

  UnityRewardedAd({required this.placementId});

  bool get isReady => _isLoaded;

  Future<void> ensureInitialized() async {
    if (!_adsService.isInitialized) {
      await _adsService.initialize();
    }
  }

  /// Pre-load rewarded ad so it is ready instantly when needed.
  Future<bool> preload() async {
    if (_isLoaded) return true;
    if (_isLoading) return false;

    await ensureInitialized();
    if (!_adsService.isInitialized) return false;

    _isLoading = true;
    final completer = Completer<bool>();
    var completed = false;

    try {
      debugPrint('Pre-loading rewarded ad: $placementId');
      await UnityAds.load(
        placementId: placementId,
        onComplete: (pid) {
          if (!completed) {
            completed = true;
            _isLoaded = true;
            _isLoading = false;
            debugPrint('Rewarded ad pre-loaded: $pid');
            completer.complete(true);
          }
        },
        onFailed: (pid, error, message) {
          if (!completed) {
            completed = true;
            _isLoaded = false;
            _isLoading = false;
            debugPrint('Rewarded ad preload failed: $pid — $message');
            completer.complete(false);
          }
        },
      );

      return await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (!completed) {
            completed = true;
            _isLoading = false;
            _isLoaded = false;
          }
          return false;
        },
      );
    } catch (e) {
      _isLoading = false;
      _isLoaded = false;
      debugPrint('Rewarded preload error: $e');
      return false;
    }
  }

  Future<bool> showAd({
    Function(String)? onReward,
    Function()? onAdClosed,
    Function(String)? onAdFailed,
  }) async {
    await ensureInitialized();
    if (!_adsService.isInitialized) {
      onAdFailed?.call('Ads not initialized');
      onAdClosed?.call();
      return false;
    }

    if (!_isLoaded) {
      final loaded = await preload();
      if (!loaded) {
        onAdFailed?.call('Ad not loaded');
        onAdClosed?.call();
        return false;
      }
    }

    try {
      debugPrint('Showing rewarded ad: $placementId');
      await UnityAds.showVideoAd(
        placementId: placementId,
        onStart: (pid) => debugPrint('Rewarded started: $pid'),
        onClick: (pid) => debugPrint('Rewarded clicked: $pid'),
        onSkipped: (pid) {
          debugPrint('Rewarded skipped: $pid');
          _isLoaded = false;
          preload();
          onAdClosed?.call();
        },
        onComplete: (pid) {
          debugPrint('Rewarded completed: $pid');
          _isLoaded = false;
          onReward?.call(pid);
          preload();
          onAdClosed?.call();
        },
        onFailed: (pid, error, message) {
          debugPrint('Rewarded show failed: $pid — $message');
          _isLoaded = false;
          preload();
          onAdFailed?.call(message);
          onAdClosed?.call();
        },
      );
      return true;
    } catch (e) {
      debugPrint('Rewarded show error: $e');
      _isLoaded = false;
      preload();
      onAdClosed?.call();
      return false;
    }
  }

  /// Shows rewarded ad. Pre-loaded ads play after the policy disclosure delay.
  /// If ad fails to load/show, [onRewardCallback] still fires after [fallbackDelay].
  Future<void> showRewardedAd({
    BuildContext? context,
    required Function() onRewardCallback,
    Function()? onAdClosed,
    Duration fallbackDelay = const Duration(seconds: 5),
  }) async {
    var rewarded = false;
    var closed = false;

    void finish() {
      if (closed) return;
      closed = true;
      if (!rewarded) {
        onRewardCallback();
      }
      onAdClosed?.call();
    }

    await ensureInitialized();

    if (!_isLoaded) {
      await preload().timeout(
        const Duration(seconds: 6),
        onTimeout: () => false,
      );
    }

    if (_isLoaded) {
      await AdLoadingOverlay.runBeforeShow(
        showAd: () => showAd(
          onReward: (_) {
            rewarded = true;
            onRewardCallback();
          },
          onAdClosed: finish,
          onAdFailed: (_) => finish(),
        ),
      );
      return;
    }

    debugPrint(
      'Rewarded ad unavailable — granting fallback after ${fallbackDelay.inSeconds}s',
    );
    await Future.delayed(fallbackDelay);
    if (!rewarded) {
      onRewardCallback();
      rewarded = true;
    }
    preload();
    finish();
  }
}
