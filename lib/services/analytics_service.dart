import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics for iOS and Android.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _enabled = false;

  void setEnabled(bool value) {
    _enabled = value;
    if (value) {
      _analytics = FirebaseAnalytics.instance;
    }
  }

  FirebaseAnalyticsObserver? get navigatorObserver {
    if (!_enabled || _analytics == null) return null;
    return FirebaseAnalyticsObserver(analytics: _analytics!);
  }

  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    if (!_enabled || _analytics == null) {
      debugPrint('Analytics: $name $params');
      return;
    }
    await _analytics!.logEvent(name: name, parameters: params);
  }

  Future<void> logScreen(String screenName) async {
    if (!_enabled || _analytics == null) {
      debugPrint('Analytics screen: $screenName');
      return;
    }
    await _analytics!.logScreenView(screenName: screenName);
  }

  Future<void> logSubscriptionAdded(String name) async {
    await logEvent('subscription_added', params: {'name': name});
  }

  Future<void> logSubscriptionRenewed(String name) async {
    await logEvent('subscription_renewed', params: {'name': name});
  }

  Future<void> logSubscriptionDeleted(String name) async {
    await logEvent('subscription_deleted', params: {'name': name});
  }
}
