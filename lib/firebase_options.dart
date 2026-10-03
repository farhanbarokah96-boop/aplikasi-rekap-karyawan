// File generated for project farhangsa119a with real Firebase API Key
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Project ID: farhangsa119a
/// Project Number: 423929150413
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyArMHC8IMbf11XSD4jvolZ29a97H-erDC0',
    appId: '1:423929150413:web:farhangsa119a',
    messagingSenderId: '423929150413',
    projectId: 'farhangsa119a',
    authDomain: 'farhangsa119a.firebaseapp.com',
    storageBucket: 'farhangsa119a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyArMHC8IMbf11XSD4jvolZ29a97H-erDC0',
    appId: '1:423929150413:android:farhangsa119a',
    messagingSenderId: '423929150413',
    projectId: 'farhangsa119a',
    storageBucket: 'farhangsa119a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArMHC8IMbf11XSD4jvolZ29a97H-erDC0',
    appId: '1:423929150413:ios:farhangsa119a',
    messagingSenderId: '423929150413',
    projectId: 'farhangsa119a',
    storageBucket: 'farhangsa119a.appspot.com',
    iosBundleId: 'com.example.aplikasirekap',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyArMHC8IMbf11XSD4jvolZ29a97H-erDC0',
    appId: '1:423929150413:ios:farhangsa119a',
    messagingSenderId: '423929150413',
    projectId: 'farhangsa119a',
    storageBucket: 'farhangsa119a.appspot.com',
    iosBundleId: 'com.example.aplikasirekap',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyArMHC8IMbf11XSD4jvolZ29a97H-erDC0',
    appId: '1:423929150413:web:farhangsa119a',
    messagingSenderId: '423929150413',
    projectId: 'farhangsa119a',
    authDomain: 'farhangsa119a.firebaseapp.com',
    storageBucket: 'farhangsa119a.appspot.com',
  );
}
