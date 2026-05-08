/// Centralised, build-time application configuration.
///
/// All values are read from `--dart-define` (or
/// `--dart-define-from-file=config/dev.json`) so that **no secret ever lives
/// in the source tree**. If a value is not provided at build time, a safe
/// default is used (or the feature gracefully degrades — see
/// [hasYoutubeApiKey]).
///
/// To run with secrets locally:
///
/// ```bash
/// flutter run --dart-define-from-file=config/dev.json
/// ```
///
/// See `config/app_config.json` for the schema.
class AppConfig {
  AppConfig._();

  // ── YouTube Data API v3 ──────────────────────────────────────────────────

  /// API key for the YouTube Data API. When empty, the learning module
  /// silently falls back to local demo videos.
  static const String youtubeApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );

  /// Optional channel filter for YouTube search.
  static const String youtubeChannelId = String.fromEnvironment(
    'YOUTUBE_CHANNEL_ID',
    defaultValue: '',
  );

  /// Base URL for the YouTube Data API. Configurable for testing / proxying.
  static const String youtubeApiBaseUrl = String.fromEnvironment(
    'YOUTUBE_API_BASE_URL',
    defaultValue: 'https://www.googleapis.com/youtube/v3',
  );

  static bool get hasYoutubeApiKey => youtubeApiKey.isNotEmpty;

  // ── Weather (Open-Meteo, legacy fallback) ────────────────────────────────

  /// Legacy base URL kept for the offline-friendly Open-Meteo fallback.
  /// Used only when [openWeatherApiKey] is empty so the app keeps working
  /// without paid keys (e.g. in development / CI).
  static const String weatherApiBaseUrl = String.fromEnvironment(
    'WEATHER_API_BASE_URL',
    defaultValue: 'https://api.open-meteo.com/v1',
  );

  // ── Weather (OpenWeatherMap — primary provider) ──────────────────────────

  /// API key for OpenWeatherMap. When empty, the weather feature
  /// transparently falls back to the keyless Open-Meteo provider so the
  /// rest of the app continues to work in dev builds.
  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );

  /// Base URL for OpenWeatherMap. Configurable for testing / proxying.
  static const String openWeatherBaseUrl = String.fromEnvironment(
    'OPENWEATHER_API_BASE_URL',
    defaultValue: 'https://api.openweathermap.org',
  );

  /// When `true`, the app uses One Call API 3.0 (paid plan, single request
  /// returning current + hourly + daily + alerts). When `false`, the
  /// service falls back to free 2.5 endpoints (current + 5-day/3-hour
  /// forecast) and synthesises 7-day data on the client side.
  static const String _openWeatherUseOneCallV3 = String.fromEnvironment(
    'OPENWEATHER_USE_ONECALL_V3',
    defaultValue: 'false',
  );

  static bool get hasOpenWeatherApiKey => openWeatherApiKey.isNotEmpty;
  static bool get useOneCallV3 =>
      _openWeatherUseOneCallV3.toLowerCase() == 'true';

  // ── Build-time environment label ─────────────────────────────────────────

  /// Optional label like `dev`, `staging`, `prod` to distinguish builds in
  /// logs / crash reports.
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static bool get isProduction => environment == 'prod';
}
