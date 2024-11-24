// lib/services/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Method to get the Firebase ID token
  Future<String?> getFirebaseIdToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? idToken = await user.getIdToken();
        return idToken;
      } else {
        print('No user is signed in.');
        return null;
      }
    } catch (e) {
      print('Error getting Firebase ID token: $e');
      return null;
    }
  }
}
