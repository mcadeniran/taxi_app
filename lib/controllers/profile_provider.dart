import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Profile? _profile;
  Profile? get profile => _profile;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Listen to auth changes and load profile
  void initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToProfile(user.uid);
      } else {
        _profile = null;
        notifyListeners();
      }
    });
  }

  // Stream and update profile in real-time
  void _listenToProfile(String uid) {
    _isLoading = true;
    notifyListeners();

    _authService.streamProfile(uid).listen((profile) {
      _profile = profile;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Sign up
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _authService.signUp(
      email: email,
      password: password,
      username: username,
      role: role,
    );
    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    await _authService.login(email: email, password: password);
    _isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }
}
