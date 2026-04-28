import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum AuthSessionStatus { unknown, authenticated, unauthenticated, loading, error }

/// Manages authenticated user session and auth actions.
class AuthSessionController extends ChangeNotifier {
  AuthSessionController() {
    _user = _auth.currentUser;
    _status =
        _user == null
            ? AuthSessionStatus.unauthenticated
            : AuthSessionStatus.authenticated;

    _authStateSubscription = _auth.authStateChanges().listen((user) {
      _user = user;
      _status =
          user == null
              ? AuthSessionStatus.unauthenticated
              : AuthSessionStatus.authenticated;
      _lastError = null;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;
  User? _user;
  AuthSessionStatus _status = AuthSessionStatus.unknown;
  String? _lastError;

  User? get currentUser => _user ?? _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  AuthSessionStatus get status => _status;
  String? get lastError => _lastError;
  bool get isBusy => _status == AuthSessionStatus.loading;
  bool get hasError => _status == AuthSessionStatus.error;

  String? get userEmail => currentUser?.email;
  String? get userName => currentUser?.displayName;
  String? get userId => currentUser?.uid;

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) => _performAuthAction(
    action: () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  Future<String?> registerWithEmail({
    required String username,
    required String email,
    required String password,
  }) => _performAuthAction(
    action: () async {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credentials.user?.updateDisplayName(username.trim());
      await credentials.user?.reload();
      _user = _auth.currentUser;
    },
  );

  Future<String?> sendPasswordResetEmail(String email) => _performAuthAction(
    action: () => _auth.sendPasswordResetEmail(email: email.trim()),
    useLoadingState: false,
  );

  Future<String?> updateUserName(String username) => _performAuthAction(
    action: () async {
      final trimmed = username.trim();
      await currentUser?.updateDisplayName(trimmed);
      await currentUser?.reload();
      _user = _auth.currentUser;
    },
    useLoadingState: false,
  );

  Future<void> signOut() async {
    try {
      _status = AuthSessionStatus.loading;
      _lastError = null;
      notifyListeners();

      await _auth.signOut();

      _user = null;
      _status = AuthSessionStatus.unauthenticated;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _status = AuthSessionStatus.error;
      _lastError = _mapAuthError(e);
      notifyListeners();
      rethrow;
    } catch (_) {
      _status = AuthSessionStatus.error;
      _lastError = 'authUnknown';
      notifyListeners();
      rethrow;
    }
  }

  Future<String?> _performAuthAction({
    required Future<void> Function() action,
    bool useLoadingState = true,
  }) async {
    try {
      if (useLoadingState) {
        _status = AuthSessionStatus.loading;
        _lastError = null;
        notifyListeners();
      }

      await action();
      _lastError = null;
      return null;
    } on FirebaseAuthException catch (e) {
      final mappedError = _mapAuthError(e);
      _lastError = mappedError;
      _status = AuthSessionStatus.error;
      notifyListeners();
      return mappedError;
    } catch (_) {
      _lastError = 'authUnknown';
      _status = AuthSessionStatus.error;
      notifyListeners();
      return _lastError;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'invalidEmail';
      case 'user-disabled':
        return 'userDisabled';
      case 'user-not-found':
        return 'userNotFound';
      case 'wrong-password':
      case 'invalid-credential':
        return 'wrongPassword';
      case 'email-already-in-use':
        return 'emailInUse';
      case 'weak-password':
        return 'weakPasswordAuth';
      case 'too-many-requests':
        return 'tooManyRequests';
      case 'network-request-failed':
        return 'networkFailed';
      default:
        return e.message ?? 'authUnknown';
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
