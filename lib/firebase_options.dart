import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isIOS) {
      return ios;
    }
    if (Platform.isAndroid) {
      return android;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 
    appId: '1:7217434153:web:a2b290bb2a79ba3c8f5638',
    messagingSenderId: '7217434153',
    projectId: 'nexus-lite-mvp',
    authDomain: 'nexus-lite-mvp.firebaseapp.com',
    storageBucket: 'nexus-lite-mvp.firebasestorage.app',
    measurementId: "G-3P97S5HT3W",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 
    appId: '1:7217434153:android:a2b290bb2a79ba3c8f5638',
    messagingSenderId: '7217434153',
    projectId: 'nexus-lite-mvp',
    authDomain: 'nexus-lite-mvp.firebaseapp.com',
    storageBucket: 'nexus-lite-mvp.firebasestorage.app',
    measurementId: "G-3P97S5HT3W",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 
    appId: '1:7217434153:ios:a2b290bb2a79ba3c8f5638',
    messagingSenderId: '7217434153',
    projectId: 'nexus-lite-mvp',
    authDomain: 'nexus-lite-mvp.firebaseapp.com',
    storageBucket: 'nexus-lite-mvp.firebasestorage.app',
    iosBundleId: 'com.example.nexusLiteMvp',
    measurementId: "G-3P97S5HT3W",
  );
}
