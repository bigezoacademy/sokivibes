import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../config/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _authService.userChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmail(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _authService.signUpWithEmail(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> signInAnonymously() async {
    await _authService.signInAnonymously();
  }

  Future<void> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    if (user == null) {
      // User cancelled sign-in or not found in Firestore, do not throw error, just return
      return;
    }
    // No need to create/update Firestore user here, already handled in AuthService
    notifyListeners();
  }

  bool get isAdmin =>
      _user != null && (AppConstants.adminEmails.contains(_user!.email));
}
