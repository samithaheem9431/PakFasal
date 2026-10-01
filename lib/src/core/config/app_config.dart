/// Centralised, compile-time application configuration.
///
/// Secrets are injected with **`--dart-define`** / **`--dart-define-from-file`**
/// so they are never shipped as a readable asset JSON in the APK/IPA.
///
/// Local development:
/// ```bash
/// cp config/app_config.example.json config/dev.json
/// # fill in keys in config/dev.json (git-ignored)
/// flutter run --dart-define-from-file=config/dev.json
/// ```
///
/// Or use the IDE launch config in `.vscode/launch.json`.
///
/// When a key is empty, features degrade gracefully (e.g. learning shows demo
/// videos, weather falls back to Open-Meteo where possible).
///
/// Call [AppConfig.init] early from `main.dart` (no-op today; kept for a stable
/// startup hook if runtime config is added later).
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

  /// Startup hook — intentionally a no-op; defines are compile-time only.
  static Future<void> init() async {}

  // ── YouTube Data API v3 ──────────────────────────────────────────────────

  /// API key for the YouTube Data API. When empty, the learning module
  /// silently falls back to local demo videos.
  static String get youtubeApiKey => _envYoutubeApiKey;

  /// Optional channel filter for YouTube search.
  static String get youtubeChannelId => _envYoutubeChannelId;

  /// Base URL for the YouTube Data API. Configurable for testing / proxying.
  static String get youtubeApiBaseUrl => _envYoutubeApiBaseUrl;

  static bool get hasYoutubeApiKey => youtubeApiKey.isNotEmpty;

  // ── Weather (Open-Meteo, legacy fallback) ────────────────────────────────

  static String get weatherApiBaseUrl => _envWeatherApiBaseUrl;

  // ── Weather (OpenWeatherMap — primary provider) ──────────────────────────

  static String get openWeatherApiKey => _envOpenWeatherApiKey;

  static String get openWeatherBaseUrl => _envOpenWeatherBaseUrl;

  static bool get hasOpenWeatherApiKey => openWeatherApiKey.isNotEmpty;

  static bool get useOneCallV3 =>
      _envOpenWeatherUseOneCallV3.toLowerCase() == 'true';

  // ── Cloudinary (profile image uploads) ───────────────────────────────────

  /// Cloud name from the Cloudinary dashboard.
  static String get cloudinaryCloudName => _envCloudinaryCloudName;

  /// Unsigned upload preset restricted to image uploads (e.g. folder
  /// `pakfasal/profiles`). Never put the API secret in the app.
  static String get cloudinaryUploadPreset => _envCloudinaryUploadPreset;

  static bool get hasCloudinaryConfig =>
      cloudinaryCloudName.isNotEmpty && cloudinaryUploadPreset.isNotEmpty;

  // ── Build-time environment label ─────────────────────────────────────────

  static String get environment => _envEnvironment;

  static bool get isProduction => environment == 'prod';
}
