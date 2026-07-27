import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_task_tracker/models/user_model.dart';
import 'package:intern_task_tracker/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _firebaseUser;
  UserModel? _currentUserModel;
  bool _isLoading = false;
  bool _isProfileLoaded = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _userModelSubscription;

  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  bool get isProfileLoaded => _isProfileLoaded;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isAdmin => _currentUserModel?.isAdmin ?? false;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _authRepository.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _userModelSubscription?.cancel();
        _userModelSubscription = _authRepository.streamUserProfile(user.uid).listen(
          (UserModel? model) {
            _currentUserModel = model;
            _isProfileLoaded = true;
            notifyListeners();
          },
          onError: (err) {
            debugPrint('Error streaming user profile: $err');
            _isProfileLoaded = true;
            notifyListeners();
          },
        );
      } else {
        _currentUserModel = null;
        _isProfileLoaded = true;
        notifyListeners();
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUserModel = await _authRepository.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getReadableAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String department,
    required String university,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUserModel = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        department: department,
        university: university,
        role: role,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getReadableAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send reset link. Please check your email.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _userModelSubscription?.cancel();
    await _authRepository.signOut();
    _currentUserModel = null;
    _firebaseUser = null;
    _isProfileLoaded = true;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _getReadableAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No registered account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address format.';
      default:
        return 'Authentication failed. Please check your network connection.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userModelSubscription?.cancel();
    super.dispose();
  }
}
