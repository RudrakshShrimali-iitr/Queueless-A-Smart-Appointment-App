
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
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAgTopvx0YZ7YLL628MFKCjlXP1H9G0f0',
    appId: '1:341515049668:web:e03a5875c9257f49e20791',
    messagingSenderId: '341515049668',
    projectId: 'queueless-22e40',
    authDomain: 'queueless-22e40.firebaseapp.com',
    storageBucket: 'queueless-22e40.firebasestorage.app',
    measurementId: 'G-0B4V08JS3Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPznDTS3wRifXqnrYeT3UyX0DuDDhtV-g',
    appId: '1:341515049668:android:f7b28f42c7c0a553e20791',
    messagingSenderId: '341515049668',
    projectId: 'queueless-22e40',
    storageBucket: 'queueless-22e40.firebasestorage.app',
  );

}