import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<User?> signInWithGoogle() async {
    try {
      User? user = await _authRepository.signInWithGoogle();
      return user;
    } catch (e) {
      print('Sign in failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      print('Sign out failed: $e');
    }
  }
}
