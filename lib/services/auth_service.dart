import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();

  Future<User?> signInWithGoogle() async {
    try {
      User? user = await _authRepository.signInWithGoogle();
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {}
  }
}
