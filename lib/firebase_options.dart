import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your BankLite Firebase apps.
///
/// Configured for live project: banklite-f95a6
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBgIiaF8afMpVOKCIBQUzUmiByMYvnMgRw',
    appId: '1:884869626661:web:dae5807f29d9e984f0f8cc',
    messagingSenderId: '884869626661',
    projectId: 'banklite-f95a6',
    authDomain: 'banklite-f95a6.firebaseapp.com',
    storageBucket: 'banklite-f95a6.firebasestorage.app',
    measurementId: 'G-CY4T11JPH8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgIiaF8afMpVOKCIBQUzUmiByMYvnMgRw',
    appId: '1:884869626661:android:banklite1122334455',
    messagingSenderId: '884869626661',
    projectId: 'banklite-f95a6',
    storageBucket: 'banklite-f95a6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgIiaF8afMpVOKCIBQUzUmiByMYvnMgRw',
    appId: '1:884869626661:ios:banklite5544332211',
    messagingSenderId: '884869626661',
    projectId: 'banklite-f95a6',
    storageBucket: 'banklite-f95a6.firebasestorage.app',
    iosBundleId: 'com.banklite.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBgIiaF8afMpVOKCIBQUzUmiByMYvnMgRw',
    appId: '1:884869626661:ios:banklitemacos5544332211',
    messagingSenderId: '884869626661',
    projectId: 'banklite-f95a6',
    storageBucket: 'banklite-f95a6.firebasestorage.app',
    iosBundleId: 'com.banklite.macos',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBgIiaF8afMpVOKCIBQUzUmiByMYvnMgRw',
    appId: '1:884869626661:web:banklitewindows998877',
    messagingSenderId: '884869626661',
    projectId: 'banklite-f95a6',
    storageBucket: 'banklite-f95a6.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBgIiaF8afMpVOKCIBQUzUmiByMYvnMgRw',
    appId: '1:884869626661:web:banklitelinux998877',
    messagingSenderId: '884869626661',
    projectId: 'banklite-f95a6',
    storageBucket: 'banklite-f95a6.firebasestorage.app',
  );
}
