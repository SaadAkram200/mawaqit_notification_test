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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEvfrKuIyCV6gTzh8wxFj3YkHOdZGesmU',
    appId: '1:256755378008:android:be7f6158ea2fb4fe61e72d',
    messagingSenderId: '256755378008',
    projectId: 'test-7269c',
    storageBucket: 'test-7269c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAk3kRGECh_q8X71LbETQCvNMsUs1mzUuo',
    appId: '1:256755378008:ios:4e2d8ff56faba94661e72d',
    messagingSenderId: '256755378008',
    projectId: 'test-7269c',
    storageBucket: 'test-7269c.appspot.com',
    androidClientId: '256755378008-fn3r8dl4ce7d7a93r8hd42ldvico36s9.apps.googleusercontent.com',
    iosClientId: '256755378008-3i9trim8v9uec6q5c05679s8ftpr37f1.apps.googleusercontent.com',
    iosBundleId: 'com.example.mawaqitNotificationTest',
  );
}
