import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signIn(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
