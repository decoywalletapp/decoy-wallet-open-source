import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyASHHEibFD98txAKpA4t6Yh07AQXNFAEKA",
            authDomain: "decoywallet-a283b.firebaseapp.com",
            projectId: "decoywallet-a283b",
            storageBucket: "decoywallet-a283b.firebasestorage.app",
            messagingSenderId: "866378207353",
            appId: "1:866378207353:web:332e728d7a8371cd14c4a8"));
  } else {
    await Firebase.initializeApp();
  }
}
