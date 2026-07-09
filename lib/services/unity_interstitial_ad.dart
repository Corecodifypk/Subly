import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'unity_ads_service.dart';

/// Unity interstitial with reliable pre-load and show.
class UnityInterstitialAd {
  final String placementId;

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isShowing = false;
  Completer<bool>? _loadCompleter;

  UnityInterstitialAd({required this.placementId});

  bool get isReady => _isLoaded;
  bool get isShowing => _isShowing;

  Future<void> _ensureInitialized() async {
    if (!UnityAdsService().isInitialized) {
      await UnityAdsService().initialize();
    }
  }

  /// Pre-load interstitial. Skipped while an ad is on screen.
  Future<bool> loadAd() async {
    if (_isShowing) return false;
    if (_isLoaded) return true;

    if (_isLoading && _loadCompleter != null) {
      try {
        return await _loadCompleter!.future.timeout(
          const Duration(seconds: 12),
          onTimeout: () => false,
        );
      } catch (_) {
        return false;
      }
    }

    await _ensureInitialized();
    if (!UnityAdsService().isInitialized) return false;

    _isLoading = true;
    _loadCompleter = Completer<bool>();
    var finished = false;

    void complete(bool ok) {
      if (finished) return;
      finished = true;
      _isLoading = false;
      _isLoaded = ok;
      if (!(_loadCompleter?.isCompleted ?? true)) {
        _loadCompleter!.complete(ok);
      }
    }

    try {
      debugPrint('[Ads] Loading interstitial: $placementId');
      await UnityAds.load(
        placementId: placementId,
        onComplete: (pid) {
          debugPrint('[Ads] Interstitial ready: $pid');
          complete(true);
        },
        onFailed: (pid, error, message) {
          debugPrint('[Ads] Interstitial load failed: $message');
          complete(false);
        },
      );

      return await _loadCompleter!.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          complete(false);
          return false;
        },
      );
    } catch (e) {
      debugPrint('[Ads] Interstitial load error: $e');
      complete(false);
      return false;
    }
  }

  void preloadNext() {
    if (_isShowing) return;
    _isLoaded = false;
    if (!_isLoading) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!_isShowing) unawaited(loadAd());
      });
    }
  }

  static void _runOnUi(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        action();
      } catch (e, st) {
        debugPrint('[Ads] Callback error: $e\n$st');
      }
    });
  }

  Future<void> showAndWait({required VoidCallback onClosed}) async {
    await _ensureInitialized();

    if (!_isLoaded) {
      await loadAd().timeout(
        const Duration(seconds: 6),
        onTimeout: () => false,
      );
    }

    if (!_isLoaded) {
      _runOnUi(onClosed);
      preloadNext();
      return;
    }

    final done = Completer<void>();
    var handled = false;

    void finish() {
      if (handled) return;
      handled = true;
      _isShowing = false;
      _isLoaded = false;

      _runOnUi(onClosed);

      if (!done.isCompleted) done.complete();
      preloadNext();
    }

    _isShowing = true;
    _isLoaded = false;

    try {
      debugPrint('[Ads] Showing interstitial: $placementId');
      await UnityAds.showVideoAd(
        placementId: placementId,
        onStart: (pid) => debugPrint('[Ads] Interstitial started: $pid'),
        onClick: (pid) => debugPrint('[Ads] Interstitial clicked: $pid'),
        onSkipped: (pid) {
          debugPrint('[Ads] Interstitial skipped: $pid');
          finish();
        },
        onComplete: (pid) {
          debugPrint('[Ads] Interstitial completed: $pid');
          finish();
        },
        onFailed: (pid, error, message) {
          debugPrint('[Ads] Interstitial show failed: $message');
          finish();
        },
      );

      await done.future.timeout(
        const Duration(seconds: 120),
        onTimeout: finish,
      );
    } catch (e) {
      debugPrint('[Ads] Interstitial show error: $e');
      finish();
    }
  }
}
