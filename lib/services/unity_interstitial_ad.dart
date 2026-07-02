import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      try {
        action();
      } catch (e, st) {
        debugPrint('[Ads] Callback error: $e\n$st');
      }
    });
  }

  /// Show pre-loaded ad and wait until it fully closes.
  Future<void> showAndWait({required VoidCallback onClosed}) async {
    await _ensureInitialized();

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

/// Brief "Loading ad..." overlay — always visible at least [minDuration].
class AdLoadingOverlay {
  static Future<void> run({
    required BuildContext context,
    required Future<void> Function() task,
    Duration minDuration = const Duration(milliseconds: 1500),
    Duration maxWait = const Duration(seconds: 8),
  }) async {
    if (!context.mounted) {
      await task();
      return;
    }

    final started = DateTime.now();
    final navigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: _LoadingCard(),
          ),
        ),
      ),
    );

    try {
      await task().timeout(maxWait);
    } on TimeoutException {
      debugPrint('[Ads] Loading timed out after ${maxWait.inSeconds}s');
    } finally {
      final elapsed = DateTime.now().difference(started);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      if (context.mounted && navigator.canPop()) {
        navigator.pop();
      }
    }
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Loading ad...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
