import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Centralised, runtime-aware application configuration.
///
/// Values are resolved with the following precedence (highest first):
///
/// 1. **`--dart-define` / `--dart-define-from-file`** — compile-time defines.
///    Used in CI / production builds so secrets can be injected without
///    shipping them in the asset bundle.
/// 2. **`config/app_config.json`** — bundled JSON asset, loaded once at
///    startup via [AppConfig.init]. This is the convenient development flow
///    where running `flutter run` (or pressing the IDE's Run button) "just
///    works" without remembering CLI flags.
/// 3. **Hard-coded defaults** — empty / safe fallbacks so the app degrades
///    gracefully (e.g. learning module shows demo data when no key is set).
///
/// Call [AppConfig.init] **before** any feature reads from this class —
/// `main.dart` does this immediately after `WidgetsFlutterBinding.ensureInitialized()`.
class AppConfig {
  AppConfig._();

  // ── Compile-time defines (kept for prod / CI) ────────────────────────────

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

  // ── Runtime overrides loaded from bundled JSON ───────────────────────────

  static Map<String, String> _runtime = const <String, String>{};
  static bool _initialised = false;

  /// Loads `config/app_config.json` from the bundled assets (if present) so
  /// development builds don't need `--dart-define-from-file`.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops. Failures are
  /// swallowed so the app keeps working with compile-time / default values.
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
      // Asset missing or malformed — fall back to compile-time defines.
      _runtime = const <String, String>{};
    }
  }

  /// Resolves a value, preferring `--dart-define` (when non-empty), then the
  /// runtime JSON, then the supplied default.
  static String _resolve(String key, String envValue, String fallback) {
    if (envValue.isNotEmpty) return envValue;
    final fromJson = _runtime[key];
    if (fromJson != null && fromJson.isNotEmpty) return fromJson;
    return fallback;
  }

  // ── YouTube Data API v3 ──────────────────────────────────────────────────

  /// API key for the YouTube Data API. When empty, the learning module
  /// silently falls back to local demo videos.
  static String get youtubeApiKey =>
      _resolve('YOUTUBE_API_KEY', _envYoutubeApiKey, '');

  /// Optional channel filter for YouTube search.
  static String get youtubeChannelId =>
      _resolve('YOUTUBE_CHANNEL_ID', _envYoutubeChannelId, '');

  /// Base URL for the YouTube Data API. Configurable for testing / proxying.
  static String get youtubeApiBaseUrl => _resolve(
        'YOUTUBE_API_BASE_URL',
        _envYoutubeApiBaseUrl,
        'https://www.googleapis.com/youtube/v3',
      );

  static bool get hasYoutubeApiKey => youtubeApiKey.isNotEmpty;

  // ── Weather (Open-Meteo, legacy fallback) ────────────────────────────────

  static String get weatherApiBaseUrl => _resolve(
        'WEATHER_API_BASE_URL',
        _envWeatherApiBaseUrl,
        'https://api.open-meteo.com/v1',
      );

  // ── Weather (OpenWeatherMap — primary provider) ──────────────────────────

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

  // ── Build-time environment label ─────────────────────────────────────────

  static String get environment =>
      _resolve('APP_ENV', _envEnvironment, 'dev');

  static bool get isProduction => environment == 'prod';
}
