import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthProvider({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  User? get user => _auth.currentUser;

  bool get isSignedIn => user != null;

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error during Google sign-in: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error during sign-out: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      notifyListeners();
    } catch (e) {
      print('Error during anonymous sign-in: $e');
    }
  }

  Future<void> reloadUser() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.reload();
        notifyListeners();
      }
    } catch (e) {
      print('Error during user reload: $e');
    }
  }
}
