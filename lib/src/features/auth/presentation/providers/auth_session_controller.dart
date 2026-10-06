import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

import '../../../../core/config/app_config.dart';
import '../../../crop_calendar/data/repositories/crop_planting_repository.dart';
import '../../../profile/data/cloudinary_upload_service.dart';
import '../../../profile/data/user_profile_repository.dart';
import '../../../sensor/data/repositories/sensor_repository.dart';

enum AuthSessionStatus { unknown, authenticated, unauthenticated, loading, error }

/// Manages authenticated user session and auth actions.
class AuthSessionController extends ChangeNotifier {
  AuthSessionController({
    UserProfileRepository? profileRepository,
    CloudinaryUploadService? cloudinaryUploadService,
    SensorRepository? sensorRepository,
    CropPlantingRepository? cropPlantingRepository,
    GoogleSignIn? googleSignIn,
    FlutterSecureStorage? secureStorage,
  })  : _profileRepository = profileRepository ?? UserProfileRepository(),
        _cloudinaryUploadService =
            cloudinaryUploadService ?? CloudinaryUploadService(),
        _sensorRepository = sensorRepository ?? SensorRepository(),
        _cropPlantingRepository =
            cropPlantingRepository ?? CropPlantingRepository(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              serverClientId: AppConfig.hasGoogleWebClientId
                  ? AppConfig.googleWebClientId
                  : null,
            ),
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
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
  final SensorRepository _sensorRepository;
  final CropPlantingRepository _cropPlantingRepository;
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _secureStorage;
  StreamSubscription<User?>? _authStateSubscription;
  User? _user;
  bool _isGuestUser = false;
  AuthSessionStatus _status = AuthSessionStatus.unknown;
  String? _lastError;
  String? _photoUrl;
  bool _isUploadingPhoto = false;
  bool _isDeletingAccount = false;

  User? get currentUser => _user ?? _auth.currentUser;
  bool get isSignedIn => currentUser != null || _isGuestUser;
  bool get isGuestUser => _isGuestUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  AuthSessionStatus get status => _status;
  String? get lastError => _lastError;
  bool get isBusy =>
      _status == AuthSessionStatus.loading || _isDeletingAccount;
  bool get hasError => _status == AuthSessionStatus.error;
  bool get isUploadingPhoto => _isUploadingPhoto;
  bool get isDeletingAccount => _isDeletingAccount;

  String? get userEmail => currentUser?.email;
  String? get userName => currentUser?.displayName;
  String? get userId => currentUser?.uid;

  /// True when the current user signed in with Google (possibly among others).
  bool get isGoogleUser {
    final user = currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  /// True when the current user has an email/password provider.
  bool get isPasswordUser {
    final user = currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

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
  }) =>
      _performAuthAction(
        action: () => _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ),
        onSuccess: () {
          _isGuestUser = false;
        },
      );

  /// Google Sign-In → Firebase credential. Returns null on success.
  ///
  /// Returns `'googleSignInCancelled'` when the user closes the picker
  /// (callers should treat that as a silent cancel, not an error snackbar).
  Future<String?> signInWithGoogle() => _performAuthAction(
        action: () async {
          final account = await _googleSignIn.signIn();
          if (account == null) {
            throw const _AuthCancelledException();
          }

          final googleAuth = await account.authentication;
          if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
            throw FirebaseAuthException(
              code: 'google-missing-id-token',
              message:
                  'Google did not return an ID token. Add SHA-1 in Firebase '
                  'and set GOOGLE_WEB_CLIENT_ID.',
            );
          }

          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await _auth.signInWithCredential(credential);
          _user = _auth.currentUser;
        },
        onSuccess: () {
          _isGuestUser = false;
        },
      );

  Future<String?> registerWithEmail({
    required String username,
    required String email,
    required String password,
  }) =>
      _performAuthAction(
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

      try {
        await _googleSignIn.signOut();
      } catch (e, st) {
        debugPrint('Google signOut failed: $e\n$st');
      }
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

  /// Permanently deletes the Firebase Auth user and associated cloud data.
  ///
  /// [password] is required when the account has an email/password provider
  /// (Firebase requires recent authentication). Google-only accounts are
  /// re-authenticated via the Google picker.
  Future<String?> deleteAccount({String? password}) async {
    final user = currentUser;
    if (user == null) return 'registrationRequiredTitle';

    _isDeletingAccount = true;
    _lastError = null;
    notifyListeners();

    try {
      // 1) Re-authenticate (required by Firebase for destructive ops).
      final reauthError = await _reauthenticateForDeletion(
        user: user,
        password: password,
      );
      if (reauthError != null) {
        _isDeletingAccount = false;
        _lastError = reauthError;
        notifyListeners();
        return reauthError;
      }

      final uid = user.uid;

      // 2) Best-effort cloud data wipe while still authenticated.
      try {
        await _sensorRepository.clearAllReadings();
      } catch (e, st) {
        debugPrint('Sensor readings delete failed: $e\n$st');
      }
      try {
        await _sensorRepository.clearDeviceBinding();
      } catch (e, st) {
        debugPrint('Sensor device binding delete failed: $e\n$st');
      }
      try {
        await _cropPlantingRepository.clearAllPlantingsForCurrentUser();
      } catch (e, st) {
        debugPrint('Crop plantings delete failed: $e\n$st');
      }
      try {
        await _profileRepository.deleteProfile(uid);
      } catch (e, st) {
        debugPrint('Profile document delete failed: $e\n$st');
      }

      // 3) Delete Auth user.
      await user.delete();

      // 4) Local cleanup.
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
      await _clearLocalAuthArtifacts(uid);

      _user = null;
      _isGuestUser = false;
      _photoUrl = null;
      _isDeletingAccount = false;
      _status = AuthSessionStatus.unauthenticated;
      notifyListeners();
      return null;
    } on _AuthCancelledException {
      _isDeletingAccount = false;
      notifyListeners();
      return 'googleSignInCancelled';
    } on FirebaseAuthException catch (e) {
      _isDeletingAccount = false;
      final mapped = _mapAuthError(e);
      _lastError = mapped;
      notifyListeners();
      return mapped;
    } catch (e, st) {
      debugPrint('Account delete failed: $e\n$st');
      _isDeletingAccount = false;
      _lastError = 'accountDeleteFailed';
      notifyListeners();
      return _lastError;
    }
  }

  Future<String?> _reauthenticateForDeletion({
    required User user,
    String? password,
  }) async {
    try {
      if (isGoogleUser) {
        final account = await _googleSignIn.signIn();
        if (account == null) {
          throw const _AuthCancelledException();
        }
        final googleAuth = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        return null;
      }

      if (isPasswordUser) {
        final email = user.email?.trim() ?? '';
        final pwd = password ?? '';
        if (email.isEmpty || pwd.isEmpty) {
          return 'accountDeletePasswordRequired';
        }
        final credential = EmailAuthProvider.credential(
          email: email,
          password: pwd,
        );
        await user.reauthenticateWithCredential(credential);
        return null;
      }

      // Unknown provider — try a silent reload; delete may still fail with
      // requires-recent-login which maps to a clear message.
      return null;
    } on _AuthCancelledException {
      return 'googleSignInCancelled';
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    }
  }

  Future<void> _clearLocalAuthArtifacts(String uid) async {
    try {
      final box = Hive.box('app_preferences');
      await box.put('auth_remember_me', false);
      await box.put('auth_biometric_autofill', false);
      // Clear only this user's app-lock preference (sign-out keeps it).
      await box.delete('biometric_app_lock_enabled_$uid');
      await box.delete('biometric_app_lock_enabled');
    } catch (_) {}
    try {
      await _secureStorage.delete(key: 'secure_auth_remembered_email');
      await _secureStorage.delete(key: 'secure_auth_remembered_password');
    } catch (_) {}
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
    } on _AuthCancelledException {
      // Restore prior status without treating cancel as a hard error.
      _status = currentUser != null || _isGuestUser
          ? AuthSessionStatus.authenticated
          : AuthSessionStatus.unauthenticated;
      notifyListeners();
      return 'googleSignInCancelled';
    } on FirebaseAuthException catch (e) {
      final mappedError = _mapAuthError(e);
      _lastError = mappedError;
      _status = AuthSessionStatus.error;
      notifyListeners();
      return mappedError;
    } on PlatformException catch (e, st) {
      debugPrint('Auth PlatformException: code=${e.code} message=${e.message}\n$st');
      final mapped = _mapPlatformAuthError(e);
      _lastError = mapped;
      _status = AuthSessionStatus.error;
      notifyListeners();
      return mapped;
    } catch (e, st) {
      debugPrint('Auth unknown error: $e\n$st');
      _lastError = 'authUnknown';
      _status = AuthSessionStatus.error;
      notifyListeners();
      return _lastError;
    }
  }

  /// Maps Google Sign-In / Play Services platform failures to l10n keys.
  String _mapPlatformAuthError(PlatformException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();
    final details = '${e.details ?? ''}'.toLowerCase();
    final blob = '$code $message $details';

    // Common Android Google Sign-In developer misconfig (wrong SHA-1 / package).
    if (blob.contains('10') ||
        blob.contains('developer_error') ||
        blob.contains('api_exception: 10') ||
        blob.contains('apiexception: 10')) {
      return 'googleSignInMisconfigured';
    }
    if (code == 'sign_in_canceled' ||
        code == 'sign_in_cancelled' ||
        blob.contains('canceled') ||
        blob.contains('cancelled')) {
      return 'googleSignInCancelled';
    }
    if (code == 'network_error' || blob.contains('network')) {
      return 'networkFailed';
    }
    if (code == 'sign_in_failed' || code == 'sign_in_required') {
      return 'googleSignInFailed';
    }
    return 'googleSignInFailed';
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
      case 'requires-recent-login':
        return 'accountDeleteRequiresRecentLogin';
      case 'google-missing-id-token':
        return 'googleSignInMisconfigured';
      case 'sign_in_failed':
      case 'account-exists-with-different-credential':
        return 'googleSignInFailed';
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

/// Internal signal that the user dismissed Google Sign-In / reauth UI.
class _AuthCancelledException implements Exception {
  const _AuthCancelledException();
}
