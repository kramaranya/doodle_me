// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDWVPxA_ZXfzQg_t5jYjLUGvC6xf7AC318',
    appId: '1:124697821162:web:3c7053c71d646412cc3c93',
    messagingSenderId: '124697821162',
    projectId: 'doodle-me-eeb6e',
    authDomain: 'doodle-me-eeb6e.firebaseapp.com',
    storageBucket: 'doodle-me-eeb6e.appspot.com',
    measurementId: 'G-KMBB2SCWXS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAA4cIHn1n-U8Dshy8h645dNGR4u63dMUs',
    appId: '1:124697821162:android:0399d0b685e0a45ecc3c93',
    messagingSenderId: '124697821162',
    projectId: 'doodle-me-eeb6e',
    storageBucket: 'doodle-me-eeb6e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQ1PD1sI_NQGgxe1Zm6KxKL8T_mK3Pqlk',
    appId: '1:124697821162:ios:40fc71e2baf48d61cc3c93',
    messagingSenderId: '124697821162',
    projectId: 'doodle-me-eeb6e',
    storageBucket: 'doodle-me-eeb6e.appspot.com',
    iosBundleId: 'com.example.doodleMe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQ1PD1sI_NQGgxe1Zm6KxKL8T_mK3Pqlk',
    appId: '1:124697821162:ios:9f4031313b83053acc3c93',
    messagingSenderId: '124697821162',
    projectId: 'doodle-me-eeb6e',
    storageBucket: 'doodle-me-eeb6e.appspot.com',
    iosBundleId: 'com.example.doodleMe.RunnerTests',
  );
}