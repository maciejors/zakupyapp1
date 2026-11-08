import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A singleton responsible for interactions with the authentication service
/// and modifying user data
class AuthManager {
  static final AuthManager _instance = AuthManager._();
  static AuthManager get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _emailToUidCollection =
  FirebaseFirestore.instance.collection('emailToUid');

  StreamSubscription? _authStateStream;

  bool get isUserSignedIn => _auth.currentUser != null;

  // a private constructor
  AuthManager._();

  Future<void> initialise() async {
    await GoogleSignIn.instance.initialize();
  }

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

  /// Add an entry to an email-to-uid map in the database for the current user
  Future<void> _bindUserUidToEmail() async {
    if (!isUserSignedIn) {
      return;
    }
    await _emailToUidCollection
        .doc(getUserEmail()!)
        .set({'uid': _auth.currentUser!.uid});
  }

  /// Read an entry from email-to-uid map (null if it does not exist)
  Future<String?> getUidFromEmail(String email) async {
    final doc = await _emailToUidCollection.doc(email).get();
    if (!doc.exists) {
      return null;
    }
    return doc.get('uid') as String;
  }

  Future<void> signInWithGoogle() async {
    // trigger the v7 authentication flow (CredentialManager sheet on Android)
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

    if (googleUser == null) {
      return; // User cancelled
    }

    // obtain authentication details synchronously from the user object
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // create Firebase credential (only idToken is needed for identity authentication)
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);

    // upon a successful login, update an entry in the email-to-uid map
    if (userCredential.user != null) {
      await _bindUserUidToEmail();
    }
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
}