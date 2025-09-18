import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthViewModel extends ChangeNotifier {
  final Logger _logger = Logger();
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: <String>[drive.DriveApi.driveScope]);

  bool _isLoading = false;
  GoogleSignInAccount? _currentUser;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  GoogleSignInAccount? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _currentUser != null;

  AuthViewModel() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _setLoading(true);
      _googleSignIn.onCurrentUserChanged.listen((acc) async {
        _currentUser = acc;
        notifyListeners();
      });
      _googleSignIn.signInSilently();
    } catch (e) {
      _logger.e('Error initializing auth: $e');
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      _currentUser = await _googleSignIn.signIn();
      _logger.i('current user fetched, ${_currentUser?.toString()}');
      _logger.i('current user fetched, ${currentUser?.toString()}');
      notifyListeners();
      return currentUser;
    } catch (e) {
      _logger.e('Sign-in error: $e');
      _setError('Sign-in failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _googleSignIn.disconnect();
      _logger.i('Sign-out successful');
    } finally {
      _setLoading(false);
    }
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
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
