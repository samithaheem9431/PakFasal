import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

/// App-level biometric lock for registered (non-guest) sessions.
///
/// Preference is stored **per Firebase uid** so it survives sign-out and is
/// restored on the next login for that same account.
class BiometricLockController extends ChangeNotifier
    with WidgetsBindingObserver {
  BiometricLockController({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(_bootstrap());
  }

  static const String _boxName = 'app_preferences';
  static const String _legacyPrefKey = 'biometric_app_lock_enabled';

  final LocalAuthentication _localAuth;

  bool _enabled = false;
  bool _locked = false;
  bool _deviceSupported = false;
  bool _busy = false;
  bool _hasRegisteredSession = false;
  /// Keeps unlock UI off until splash finishes so branding shows first.
  bool _suppressUntilSplashEnds = true;
  String? _userId;
  String? _lastError;

  bool get isEnabled => _enabled;
  bool get isLocked =>
      _enabled &&
      _locked &&
      _hasRegisteredSession &&
      !_suppressUntilSplashEnds;
  bool get isDeviceSupported => _deviceSupported;
  bool get isBusy => _busy;
  String? get lastError => _lastError;

  /// Call when splash is about to navigate away (cold start only).
  void releaseSplashGate() {
    if (!_suppressUntilSplashEnds) return;
    _suppressUntilSplashEnds = false;
    // Defer rebuild — may run from SplashScreen.dispose while the tree is locked.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  String _prefKeyFor(String uid) => 'biometric_app_lock_enabled_$uid';

  /// Call whenever auth session changes.
  void onSessionChanged({
    required bool hasRegisteredUser,
    String? userId,
  }) {
    final nextUid =
        hasRegisteredUser && userId != null && userId.isNotEmpty ? userId : null;
    final sessionSame =
        _hasRegisteredSession == hasRegisteredUser && _userId == nextUid;
    if (sessionSame) return;

    _hasRegisteredSession = hasRegisteredUser;
    _userId = nextUid;

    if (!hasRegisteredUser || nextUid == null) {
      // Keep Hive preference — only clear the in-memory lock gate.
      _locked = false;
      // Keep `_enabled` as the last known value for UI consistency until
      // the next registered session reloads from disk.
      notifyListeners();
      return;
    }

    _loadPreferenceForUser(nextUid);
    if (_enabled) {
      _locked = true;
    } else {
      _locked = false;
    }
    notifyListeners();
  }

  Future<void> _bootstrap() async {
    try {
      _deviceSupported = await _localAuth.isDeviceSupported();
    } catch (_) {
      _deviceSupported = false;
    }
    // Preference is loaded when a registered session appears.
    notifyListeners();
  }

  void _loadPreferenceForUser(String uid) {
    final box = Hive.box(_boxName);
    final scoped = box.get(_prefKeyFor(uid));
    if (scoped is bool) {
      _enabled = scoped;
      return;
    }
    // Migrate one-time from the old device-global key.
    final legacy = box.get(_legacyPrefKey, defaultValue: false) as bool;
    _enabled = legacy;
    if (legacy) {
      box.put(_prefKeyFor(uid), true);
      box.delete(_legacyPrefKey);
    }
  }

  /// Enables/disables lock. Enabling always prompts biometrics first.
  Future<bool> setEnabled(bool value, {required String reason}) async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      _lastError = 'registrationRequiredTitle';
      notifyListeners();
      return false;
    }

    if (value) {
      if (!_deviceSupported) {
        _lastError = 'biometricNotAvailable';
        notifyListeners();
        return false;
      }
      final ok = await authenticate(reason: reason);
      if (!ok) return false;
      _enabled = true;
      _locked = false;
      await Hive.box(_boxName).put(_prefKeyFor(uid), true);
      _lastError = null;
      notifyListeners();
      return true;
    }

    _enabled = false;
    _locked = false;
    await Hive.box(_boxName).put(_prefKeyFor(uid), false);
    _lastError = null;
    notifyListeners();
    return true;
  }

  Future<bool> authenticate({required String reason}) async {
    if (_busy) return false;
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      final canCheck = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (!canCheck) {
        _lastError = 'biometricNotAvailable';
        return false;
      }
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (ok) {
        _locked = false;
      } else {
        _lastError = 'biometricFailed';
      }
      return ok;
    } catch (e, st) {
      debugPrint('Biometric authenticate failed: $e\n$st');
      _lastError = 'biometricFailed';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> unlock({required String reason}) =>
      authenticate(reason: reason);

  void lockNow() {
    if (!_enabled || !_hasRegisteredSession) return;
    if (_locked) return;
    _locked = true;
    notifyListeners();
  }

  /// Clears the saved preference for [uid] (account deletion).
  Future<void> clearPreferenceForUser(String uid) async {
    final box = Hive.box(_boxName);
    await box.delete(_prefKeyFor(uid));
    if (_userId == uid) {
      _enabled = false;
      _locked = false;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      lockNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
