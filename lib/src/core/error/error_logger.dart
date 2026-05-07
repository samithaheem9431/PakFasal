import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Thin facade over Firebase Crashlytics + a console fallback in debug.
///
/// Use [ErrorLogger.instance] from anywhere; `init()` is called once from
/// `main.dart` after `Firebase.initializeApp`. Repository / provider catches
/// should call [recordNonFatal] so that errors users see (e.g. failed weather
/// fetch) become visible in Crashlytics — without crashing the app.
///
/// Why a facade?
///   * Keeps Crashlytics out of every feature import — if we swap providers
///     (e.g. Sentry) only this file changes.
///   * Lets us turn Crashlytics off in debug mode automatically so local
///     development doesn't pollute the dashboard.
class ErrorLogger {
  ErrorLogger._();
  static final ErrorLogger instance = ErrorLogger._();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  /// Initialise Crashlytics. Disabled automatically in debug builds so dev
  /// noise never reaches the production dashboard. Always call this exactly
  /// once, from `main.dart`, after `Firebase.initializeApp`.
  Future<void> init() async {
    final enabled = !kDebugMode;
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    await _crashlytics.setCustomKey('app_env', AppConfig.environment);

    // Forward Flutter framework errors (build/layout/paint) to Crashlytics.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _crashlytics.recordFlutterFatalError(details);
    };

    // Forward async / platform errors not caught by FlutterError.
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Associate the current Crashlytics session with a user so we can correlate
  /// reports across screens. Pass `null` on sign-out.
  Future<void> setUserId(String? userId) async {
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Set a custom key/value pair attached to subsequent reports.
  Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Add a breadcrumb-style log entry visible alongside the next crash report.
  void log(String message) {
    if (kDebugMode) debugPrint('[log] $message');
    _crashlytics.log(message);
  }

  /// Record an error that did NOT crash the app (e.g. a caught network
  /// failure). Always provide [context] so reports are grouped meaningfully.
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stack, {
    required String context,
    Map<String, Object>? attributes,
  }) async {
    if (kDebugMode) {
      debugPrint('[non-fatal] $context: $error');
      if (stack != null) debugPrintStack(stackTrace: stack);
    }
    if (attributes != null) {
      for (final entry in attributes.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    }
    await _crashlytics.recordError(
      error,
      stack,
      reason: context,
      fatal: false,
    );
  }
}
