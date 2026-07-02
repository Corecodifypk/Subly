import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Initializes Firebase for Android and iOS using the bundled config files.
class FirebaseBootstrap {
  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        debugPrint('Firebase: already initialized');
        return true;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      debugPrint(
        'Firebase: initialized (${defaultTargetPlatform.name}, project: subly-778b1)',
      );
      return true;
    } catch (e, st) {
      debugPrint('Firebase init failed: $e\n$st');
      return false;
    }
  }
}
