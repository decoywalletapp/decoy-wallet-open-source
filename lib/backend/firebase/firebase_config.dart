import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

const _firebaseConfigured = bool.fromEnvironment(
  'DECOY_FIREBASE_CONFIGURED',
  defaultValue: false,
);
const _firebaseWebApiKey = String.fromEnvironment('DECOY_FIREBASE_WEB_API_KEY');
const _firebaseWebAuthDomain = String.fromEnvironment(
  'DECOY_FIREBASE_WEB_AUTH_DOMAIN',
);
const _firebaseProjectId = String.fromEnvironment('DECOY_FIREBASE_PROJECT_ID');
const _firebaseStorageBucket = String.fromEnvironment(
  'DECOY_FIREBASE_STORAGE_BUCKET',
);
const _firebaseMessagingSenderId = String.fromEnvironment(
  'DECOY_FIREBASE_MESSAGING_SENDER_ID',
);
const _firebaseWebAppId = String.fromEnvironment('DECOY_FIREBASE_WEB_APP_ID');

Future initFirebase() async {
  if (!_firebaseConfigured) {
    debugPrint(
      'Firebase is not configured. Add platform Firebase files and set '
      'DECOY_FIREBASE_CONFIGURED=true for a connected build.',
    );
    return;
  }

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: _firebaseWebApiKey,
        authDomain: _firebaseWebAuthDomain,
        projectId: _firebaseProjectId,
        storageBucket: _firebaseStorageBucket,
        messagingSenderId: _firebaseMessagingSenderId,
        appId: _firebaseWebAppId,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
}
