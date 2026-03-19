// firebase_options.dart
// This file is used to configure Firebase for your Flutter app.
// Replace the values below with your actual Firebase project settings.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
        return FirebaseOptions(
          apiKey: "AIzaSyCg0xehNDutEpU25TUm71D3F_sA2Gaf4P4",
          authDomain: "exam-31df9.firebaseapp.com",
          projectId: "exam-31df9",
          storageBucket: "exam-31df9.firebasestorage.app",
          messagingSenderId: "914202085716",
          appId: "1:914202085716:web:4ca2e48a17e17ccb4e60c1"
        );
    }
    throw UnsupportedError('DefaultFirebaseOptions not configured for this platform.');
    
  }
}
