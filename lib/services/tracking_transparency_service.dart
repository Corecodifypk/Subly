import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

/// Requests the iOS App Tracking Transparency prompt before ads / tracking.
class TrackingTransparencyService {
  TrackingTransparencyService._();

  static final TrackingTransparencyService instance =
      TrackingTransparencyService._();

  bool _requested = false;

  /// Shows the system ATT dialog once (iOS 14+), before any ad SDK work.
  Future<void> ensureRequested() async {
    if (!Platform.isIOS || _requested) return;
    _requested = true;

    try {
      // Apple recommends a short delay so the prompt appears over visible UI.
      await Future<void>.delayed(const Duration(milliseconds: 500));

      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('[ATT] Current status: $status');

      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('[ATT] User response: $status');
      }
    } catch (e, st) {
      debugPrint('[ATT] Request failed: $e\n$st');
    }
  }
}
