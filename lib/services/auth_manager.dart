import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A singleton responsible for interactions with the authentication service
/// and modifying user data
class AuthManager {
  static AuthManager _instance = AuthManager._();
  static AuthManager get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _authStateStream = null;

  // a private constructor
  AuthManager._();

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sets up a live listener on the auth state
  void setupAuthStateListener(void Function(bool isSignedIn) onUpdate) {
    _authStateStream = _auth.authStateChanges().listen((User? user) {
      final bool isSignedIn = user != null;
      onUpdate(isSignedIn);
    });
  }

  Future<void> cancelAuthStateListener() async {
    await _authStateStream?.cancel();
  }

  bool get isUserSignedIn => _auth.currentUser != null;

  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  Future<void> setUserDisplayName(String newDisplayName) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await user.updateDisplayName(newDisplayName);
  }

  String? getUserEmail() {
    return _auth.currentUser?.email;
  }
}
