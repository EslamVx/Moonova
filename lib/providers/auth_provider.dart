import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _controller = AuthController();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _controller.currentUser;

    _controller.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _errorMessage = null;

      final result = await _controller.signUp(
        name: name,
        email: email,
        password: password,
      );

      _user = result.user;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e);

      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);

    try {
      _errorMessage = null;

      final result = await _controller.signIn(email: email, password: password);

      _user = result.user;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e);

      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);

    try {
      _errorMessage = null;

      final result = await _controller.signInWithGoogle();

      _user = result.user;

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e);

      return false;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      _errorMessage = null;

      await _controller.signOut();

      _user = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
