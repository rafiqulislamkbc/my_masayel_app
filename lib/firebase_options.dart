import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXZ8_nZhDgbxQaReyUEIA7gtxONBsf7-M',
    appId: '1:148059630703:android:3cfbbdf79c197fa023f19a',
    messagingSenderId: '148059630703',
    projectId: 'pushnotification-90f97',
    storageBucket: 'pushnotification-90f97.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDnWuvN9csiB2JVvWlq7pUUqUO1ZSX9jto',
    appId: '1:148059630703:web:79c461eae9c6f21b23f19a',
    messagingSenderId: '148059630703',
    projectId: 'pushnotification-90f97',
    authDomain: 'pushnotification-90f97.firebaseapp.com',
    storageBucket: 'pushnotification-90f97.firebasestorage.app',
  );
}
