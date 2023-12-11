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
    apiKey: 'AIzaSyAdpKDlDmWHqGnlY-WqafEe2hJte6xL-rI',
    appId: '1:410336121355:web:473b761ebcef2a26f52d0e',
    messagingSenderId: '410336121355',
    projectId: 'project-d48e8',
    authDomain: 'project-d48e8.firebaseapp.com',
    databaseURL: 'https://project-d48e8-default-rtdb.firebaseio.com',
    storageBucket: 'project-d48e8.appspot.com',
    measurementId: 'G-37KZLLKMJV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOZmDE6FxAliiEahW0LDvR8AeVQeS0POU',
    appId: '1:410336121355:android:a987e609fe89feb6f52d0e',
    messagingSenderId: '410336121355',
    projectId: 'project-d48e8',
    databaseURL: 'https://project-d48e8-default-rtdb.firebaseio.com',
    storageBucket: 'project-d48e8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMa9zYfQt6P0fSTS0jNY1oV2wNVUZ9Zvw',
    appId: '1:410336121355:ios:107b787e3932bbecf52d0e',
    messagingSenderId: '410336121355',
    projectId: 'project-d48e8',
    databaseURL: 'https://project-d48e8-default-rtdb.firebaseio.com',
    storageBucket: 'project-d48e8.appspot.com',
    iosBundleId: 'com.example.driver',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCMa9zYfQt6P0fSTS0jNY1oV2wNVUZ9Zvw',
    appId: '1:410336121355:ios:ad69e07a35637af9f52d0e',
    messagingSenderId: '410336121355',
    projectId: 'project-d48e8',
    databaseURL: 'https://project-d48e8-default-rtdb.firebaseio.com',
    storageBucket: 'project-d48e8.appspot.com',
    iosBundleId: 'com.example.driver.RunnerTests',
  );
}
