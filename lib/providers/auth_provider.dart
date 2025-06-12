import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final userCredential = await _authService.signInWithGoogle();
    if (userCredential == null || userCredential.user == null) {
      // User cancelled sign-in, do not throw error, just return
      return;
    }
    final user = userCredential.user!;
    final email = user.email ?? '';
    final role = AppConstants.adminEmails.contains(email) ? 'admin' : 'user';
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.uid).set({
      'email': email,
      'role': role,
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    notifyListeners();
  }

  bool get isAdmin =>
      _user != null && (AppConstants.adminEmails.contains(_user!.email));
}
