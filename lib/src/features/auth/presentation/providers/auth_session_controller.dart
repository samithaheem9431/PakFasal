import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../profile/data/cloudinary_upload_service.dart';
import '../../../profile/data/user_profile_repository.dart';

enum AuthSessionStatus { unknown, authenticated, unauthenticated, loading, error }

/// Manages authenticated user session and auth actions.
class AuthSessionController extends ChangeNotifier {
  AuthSessionController({
    UserProfileRepository? profileRepository,
    CloudinaryUploadService? cloudinaryUploadService,
  })  : _profileRepository = profileRepository ?? UserProfileRepository(),
        _cloudinaryUploadService =
            cloudinaryUploadService ?? CloudinaryUploadService() {
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
      if (user == null) {
        _photoUrl = null;
        notifyListeners();
      } else {
        unawaited(_loadPhotoUrl(user.uid));
      }
    });

    final existingUid = _user?.uid;
    if (existingUid != null) {
      unawaited(_loadPhotoUrl(existingUid));
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileRepository _profileRepository;
  final CloudinaryUploadService _cloudinaryUploadService;
  StreamSubscription<User?>? _authStateSubscription;
  User? _user;
  bool _isGuestUser = false;
  AuthSessionStatus _status = AuthSessionStatus.unknown;
  String? _lastError;
  String? _photoUrl;
  bool _isUploadingPhoto = false;

  User? get currentUser => _user ?? _auth.currentUser;
  bool get isSignedIn => currentUser != null || _isGuestUser;
  bool get isGuestUser => _isGuestUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  AuthSessionStatus get status => _status;
  String? get lastError => _lastError;
  bool get isBusy => _status == AuthSessionStatus.loading;
  bool get hasError => _status == AuthSessionStatus.error;
  bool get isUploadingPhoto => _isUploadingPhoto;

  String? get userEmail => currentUser?.email;
  String? get userName => currentUser?.displayName;
  String? get userId => currentUser?.uid;

  /// Cloudinary URL from Firestore, falling back to Firebase Auth photoURL.
  String? get userPhotoUrl {
    final fromFirestore = _photoUrl?.trim();
    if (fromFirestore != null && fromFirestore.isNotEmpty) return fromFirestore;
    final fromAuth = currentUser?.photoURL?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
    return null;
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) => _performAuthAction(
    action: () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
    onSuccess: () {
      _isGuestUser = false;
    },
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
    onSuccess: () {
      _isGuestUser = false;
    },
  );

  void continueAsGuest() {
    _user = null;
    _isGuestUser = true;
    _photoUrl = null;
    _lastError = null;
    _status = AuthSessionStatus.authenticated;
    notifyListeners();
  }

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

  /// Picks up an image file, uploads it to Cloudinary, and stores the URL on
  /// `users/{uid}` in Firestore (plus Auth photoURL for convenience).
  Future<String?> updateProfilePhoto(File imageFile) async {
    final user = currentUser;
    if (user == null) return 'registrationRequiredTitle';

    _isUploadingPhoto = true;
    _lastError = null;
    notifyListeners();

    try {
      final url = await _cloudinaryUploadService.uploadProfileImage(
        imageFile: imageFile,
        userId: user.uid,
      );

      // Persist URL even if one of the secondary stores fails.
      Object? firestoreError;
      try {
        await _profileRepository.savePhotoUrl(
          uid: user.uid,
          photoUrl: url,
          email: user.email,
          displayName: user.displayName,
        );
      } catch (e, st) {
        firestoreError = e;
        debugPrint('Firestore profile photo save failed: $e\n$st');
      }

      try {
        await user.updatePhotoURL(url);
        await user.reload();
        _user = _auth.currentUser;
      } catch (e, st) {
        debugPrint('Auth photoURL update failed: $e\n$st');
      }

      _photoUrl = url;
      _isUploadingPhoto = false;
      notifyListeners();

      if (firestoreError != null) {
        return 'profilePhotoSaveFailed';
      }
      return null;
    } on StateError catch (e) {
      _isUploadingPhoto = false;
      _lastError = e.message;
      notifyListeners();
      return e.message;
    } on FirebaseAuthException catch (e) {
      _isUploadingPhoto = false;
      final mapped = _mapAuthError(e);
      _lastError = mapped;
      notifyListeners();
      return mapped;
    } catch (e, st) {
      debugPrint('Profile photo upload failed: $e\n$st');
      _isUploadingPhoto = false;
      _lastError = 'profilePhotoUploadFailed';
      notifyListeners();
      return _lastError;
    }
  }

  /// Removes the profile photo from Firestore + Auth (Cloudinary file kept).
  Future<String?> removeProfilePhoto() async {
    final user = currentUser;
    if (user == null) return 'registrationRequiredTitle';
    if (userPhotoUrl == null) return null;

    _isUploadingPhoto = true;
    _lastError = null;
    notifyListeners();

    try {
      Object? firestoreError;
      try {
        await _profileRepository.clearPhotoUrl(user.uid);
      } catch (e, st) {
        firestoreError = e;
        debugPrint('Firestore profile photo clear failed: $e\n$st');
      }

      try {
        await user.updatePhotoURL(null);
        await user.reload();
        _user = _auth.currentUser;
      } catch (e, st) {
        debugPrint('Auth photoURL clear failed: $e\n$st');
      }

      _photoUrl = null;
      _isUploadingPhoto = false;
      notifyListeners();

      if (firestoreError != null) {
        return 'profilePhotoRemoveFailed';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _isUploadingPhoto = false;
      final mapped = _mapAuthError(e);
      _lastError = mapped;
      notifyListeners();
      return mapped;
    } catch (e, st) {
      debugPrint('Profile photo remove failed: $e\n$st');
      _isUploadingPhoto = false;
      _lastError = 'profilePhotoRemoveFailed';
      notifyListeners();
      return _lastError;
    }
  }

  Future<void> _loadPhotoUrl(String uid) async {
    try {
      final url = await _profileRepository.getPhotoUrl(uid);
      if (_user?.uid != uid) return;
      _photoUrl = url ?? _user?.photoURL;
      notifyListeners();
    } catch (_) {
      if (_user?.uid != uid) return;
      _photoUrl = _user?.photoURL;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _status = AuthSessionStatus.loading;
      _lastError = null;
      notifyListeners();

      await _auth.signOut();

      _user = null;
      _isGuestUser = false;
      _photoUrl = null;
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
    VoidCallback? onSuccess,
  }) async {
    try {
      if (useLoadingState) {
        _status = AuthSessionStatus.loading;
        _lastError = null;
        notifyListeners();
      }

      await action();
      onSuccess?.call();
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
