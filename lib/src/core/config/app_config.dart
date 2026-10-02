import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Centralised application configuration.
///
/// Values resolve in this order (highest first):
///
/// 1. **`--dart-define` / `--dart-define-from-file`** — preferred for CI /
///    release (e.g. `flutter run --dart-define-from-file=config/dev.json`).
/// 2. **`config/app_config.json`** — optional bundled asset for local
///    `flutter run` without CLI flags. Keep this file git-ignored when it
///    contains real keys (copy from `config/app_config.example.json`).
/// 3. **Hard-coded defaults** — empty / safe fallbacks (demo videos, etc.).
///
/// Call [AppConfig.init] from `main.dart` before any feature reads config.
class AppConfig {
  AppConfig._();

  static const String _envYoutubeApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );
  static const String _envYoutubeChannelId = String.fromEnvironment(
    'YOUTUBE_CHANNEL_ID',
    defaultValue: '',
  );
  static const String _envYoutubeApiBaseUrl = String.fromEnvironment(
    'YOUTUBE_API_BASE_URL',
    defaultValue: 'https://www.googleapis.com/youtube/v3',
  );

  static const String _envWeatherApiBaseUrl = String.fromEnvironment(
    'WEATHER_API_BASE_URL',
    defaultValue: 'https://api.open-meteo.com/v1',
  );
  static const String _envOpenWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );
  static const String _envOpenWeatherBaseUrl = String.fromEnvironment(
    'OPENWEATHER_API_BASE_URL',
    defaultValue: 'https://api.openweathermap.org',
  );
  static const String _envOpenWeatherUseOneCallV3 = String.fromEnvironment(
    'OPENWEATHER_USE_ONECALL_V3',
    defaultValue: 'false',
  );
  static const String _envEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String _envCloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );
  static const String _envCloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '',
  );
  static const String _envGoogleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );
  static const String _envPrivacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: '',
  );
  static const String _envAccountDeletionUrl = String.fromEnvironment(
    'ACCOUNT_DELETION_URL',
    defaultValue: '',
  );

  /// Default public URLs for Play Console (GitHub Pages on PakFasal repo).
  /// Override via config if you later move to a custom domain.
  static const String _defaultPrivacyPolicyUrl =
      'https://samithaheem9431.github.io/PakFasal/privacy/';
  static const String _defaultAccountDeletionUrl =
      'https://samithaheem9431.github.io/PakFasal/delete-account/';

  static Map<String, String> _runtime = const <String, String>{};
  static bool _initialised = false;

  /// Loads optional `config/app_config.json` from assets (if present).
  static Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    try {
      final raw = await rootBundle.loadString('config/app_config.json');
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _runtime = <String, String>{
          for (final entry in decoded.entries)
            if (entry.value != null && !entry.key.startsWith('_'))
              entry.key: entry.value.toString(),
        };
      }
    } catch (_) {
      _runtime = const <String, String>{};
    }
  }

  static String _resolve(String key, String envValue, String fallback) {
    if (envValue.isNotEmpty) return envValue;
    final fromJson = _runtime[key];
    if (fromJson != null && fromJson.isNotEmpty) return fromJson;
    return fallback;
  }

  // ── YouTube Data API v3 ──────────────────────────────────────────────────

  static String get youtubeApiKey =>
      _resolve('YOUTUBE_API_KEY', _envYoutubeApiKey, '');

  static String get youtubeChannelId =>
      _resolve('YOUTUBE_CHANNEL_ID', _envYoutubeChannelId, '');

  static String get youtubeApiBaseUrl => _resolve(
        'YOUTUBE_API_BASE_URL',
        _envYoutubeApiBaseUrl,
        'https://www.googleapis.com/youtube/v3',
      );

  static bool get hasYoutubeApiKey => youtubeApiKey.isNotEmpty;

  // ── Weather ──────────────────────────────────────────────────────────────

  static String get weatherApiBaseUrl => _resolve(
        'WEATHER_API_BASE_URL',
        _envWeatherApiBaseUrl,
        'https://api.open-meteo.com/v1',
      );

  static String get openWeatherApiKey =>
      _resolve('OPENWEATHER_API_KEY', _envOpenWeatherApiKey, '');

  static String get openWeatherBaseUrl => _resolve(
        'OPENWEATHER_API_BASE_URL',
        _envOpenWeatherBaseUrl,
        'https://api.openweathermap.org',
      );

  static String get _openWeatherUseOneCallV3 => _resolve(
        'OPENWEATHER_USE_ONECALL_V3',
        _envOpenWeatherUseOneCallV3,
        'false',
      );

  static bool get hasOpenWeatherApiKey => openWeatherApiKey.isNotEmpty;

  static bool get useOneCallV3 =>
      _openWeatherUseOneCallV3.toLowerCase() == 'true';

  // ── Cloudinary ───────────────────────────────────────────────────────────

  static String get cloudinaryCloudName =>
      _resolve('CLOUDINARY_CLOUD_NAME', _envCloudinaryCloudName, '');

  static String get cloudinaryUploadPreset =>
      _resolve('CLOUDINARY_UPLOAD_PRESET', _envCloudinaryUploadPreset, '');

  static bool get hasCloudinaryConfig =>
      cloudinaryCloudName.isNotEmpty && cloudinaryUploadPreset.isNotEmpty;

  // ── Google Sign-In ───────────────────────────────────────────────────────

  /// OAuth 2.0 Web client ID from Firebase Console → Project settings →
  /// Your apps → Web app (or Google Cloud → Credentials).
  ///
  /// On Android this is passed as `serverClientId` so Google returns an
  /// `idToken` that Firebase Auth can verify. Leave empty only for local
  /// experiments — production Android builds need this value.
  static String get googleWebClientId =>
      _resolve('GOOGLE_WEB_CLIENT_ID', _envGoogleWebClientId, '');

  static bool get hasGoogleWebClientId => googleWebClientId.isNotEmpty;

  // ── Legal / Play Store ───────────────────────────────────────────────────

  /// Public Privacy Policy URL (Play Console + in-app “open online”).
  static String get privacyPolicyUrl => _resolve(
        'PRIVACY_POLICY_URL',
        _envPrivacyPolicyUrl,
        _defaultPrivacyPolicyUrl,
      );

  /// Public account-deletion request URL (Data safety form).
  static String get accountDeletionUrl => _resolve(
        'ACCOUNT_DELETION_URL',
        _envAccountDeletionUrl,
        _defaultAccountDeletionUrl,
      );

  // ── Environment ──────────────────────────────────────────────────────────

  static String get environment =>
      _resolve('APP_ENV', _envEnvironment, 'dev');

  static bool get isProduction => environment == 'prod';
}
