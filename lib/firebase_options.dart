// Generated from google-services.json and GoogleService-Info.plist.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBez4AR4f_K_HyK6hYvYdXIxSnP_PhXQD8',
    appId: '1:232911419116:android:7f2ca60b98ca274d0b17c9',
    messagingSenderId: '232911419116',
    projectId: 'subly-778b1',
    storageBucket: 'subly-778b1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvSjMYxYrqJrMg3JEKcpAAw2DkZdSrW1A',
    appId: '1:232911419116:ios:c96c29eee852cd360b17c9',
    messagingSenderId: '232911419116',
    projectId: 'subly-778b1',
    storageBucket: 'subly-778b1.firebasestorage.app',
    iosBundleId: 'com.subscriptionmanager.subly',
  );
}
