import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsService {
  static final UnityAdsService _instance = UnityAdsService._internal();
  factory UnityAdsService() => _instance;
  UnityAdsService._internal();

   static const androidGameId = '5742561';
  static const iosGameId = '5742560';

  bool _isInitialized = false;
  bool _isInitializing = false;
  Completer<void>? _initCompleter;

  String get _gameId {
    if (Platform.isAndroid) return androidGameId;
    if (Platform.isIOS) return iosGameId;
    return androidGameId;
  }

  static const bool _testMode = true;

  String get rewardedAdId =>
      Platform.isAndroid ? 'Rewarded_Android' : 'Rewarded_iOS';
  String get interstitialAdId =>
      Platform.isAndroid ? 'Interstitial_Android' : 'Interstitial_iOS';
  String get bannerAdId => Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS';

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_isInitializing && _initCompleter != null) {
      return _initCompleter!.future;
    }

    _isInitializing = true;
    _initCompleter = Completer<void>();

    try {
      final gameId = _gameId;
      debugPrint(
        'Unity Ads init — platform: ${Platform.isIOS ? "iOS" : "Android"}, gameId: $gameId',
      );

      await UnityAds.init(
        gameId: gameId,
        testMode: _testMode,
        onComplete: () async {
          _isInitialized = true;
          _isInitializing = false;
          final nativeReady = await UnityAds.isInitialized();
          debugPrint('Unity Ads initialized (native ready: $nativeReady)');
          if (!(_initCompleter?.isCompleted ?? true)) {
            _initCompleter!.complete();
          }
        },
        onFailed: (error, message) {
          _isInitialized = false;
          _isInitializing = false;
          debugPrint('Unity Ads init failed: $error — $message');
          if (!(_initCompleter?.isCompleted ?? true)) {
            _initCompleter!.complete();
          }
        },
      );

      await _initCompleter!.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          _isInitializing = false;
          debugPrint('Unity Ads init timeout — continuing without ads');
        },
      );
    } catch (e) {
      _isInitialized = false;
      _isInitializing = false;
      debugPrint('Unity Ads init exception: $e');
      if (!(_initCompleter?.isCompleted ?? true)) {
        _initCompleter!.complete();
      }
    }
  }

  bool get isInitialized => _isInitialized;
}
