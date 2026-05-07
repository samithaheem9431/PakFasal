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
/// See `config/app_config.example.json` for the schema.
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

  // ── Weather (Open-Meteo) ─────────────────────────────────────────────────

  /// Base URL for the weather API. Open-Meteo is keyless, so no API key
  /// constant is needed; the URL is configurable for proxying / testing.
  static const String weatherApiBaseUrl = String.fromEnvironment(
    'WEATHER_API_BASE_URL',
    defaultValue: 'https://api.open-meteo.com/v1',
  );

  // ── Build-time environment label ─────────────────────────────────────────

  /// Optional label like `dev`, `staging`, `prod` to distinguish builds in
  /// logs / crash reports.
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static bool get isProduction => environment == 'prod';
}
