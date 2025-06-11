import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("SignIn Error: $e");
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("SignUp Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (kIsWeb) {
      await GoogleSignIn().signOut(); // penting untuk web logout
    }
  }

  Future<String?> getCurrentUser() async {
    return _auth.currentUser?.uid;
  }

  // ✅ Tambahkan metode ini
  Future<UserCredential?> signInWithGoogleWeb() async {
    try {
      if (!kIsWeb) throw Exception("signInWithGoogleWeb hanya untuk Web");
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Tambahkan scope untuk akses Google Calendar
      googleProvider.addScope('https://www.googleapis.com/auth/calendar.readonly');

      // Opsi tambahan (opsional): minta refresh token
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      return await _auth.signInWithPopup(googleProvider);
    } catch (e) {
      print("Google Sign-In Web Error: $e");
      return null;
    }
  }
}
