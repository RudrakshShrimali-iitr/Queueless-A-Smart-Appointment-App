import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios – '
          're-run FlutterFire CLI to add them.',
        );
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this desktop platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAgTopvx0YZ7YLL628MFKCjlXP1H9G0f0',
    authDomain: 'queueless-22e40.firebaseapp.com',
    projectId: 'queueless-22e40',
    storageBucket: 'queueless-22e40.firebasestorage.app',
    messagingSenderId: '341515049668',
    appId: '1:341515049668:web:e03a5875c9257f49e20791',
    measurementId: 'G-0B4V08JS3Q',

    // ← Add your RTDB URL here:
    databaseURL: 'https://queueless-22e40-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPznDTS3wRifXqnrYeT3UyX0DuDDhtV-g',
    projectId: 'queueless-22e40',
    storageBucket: 'queueless-22e40.firebasestorage.app',
    messagingSenderId: '341515049668',
    appId: '1:341515049668:android:f7b28f42c7c0a553e20791',

    // ← And here too:
    databaseURL: 'https://queueless-22e40-default-rtdb.firebaseio.com',
  );
}
