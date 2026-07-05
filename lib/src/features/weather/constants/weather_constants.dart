/// Centralised, immutable constants for the weather feature.
///
/// Endpoints, cache keys, TTLs, and farmer-advisory thresholds live here so
/// that magic numbers stay out of services and widgets, and so that the
/// rest of the codebase can tune behaviour from a single place.
class WeatherConstants {
  WeatherConstants._();

  // ── OpenWeatherMap endpoints (relative paths, joined with the configured
  // base URL by [WeatherApiService]). ─────────────────────────────────────
  static const String owmCurrentPath = '/data/2.5/weather';
  static const String owmFiveDayForecastPath = '/data/2.5/forecast';
  static const String owmAirQualityPath = '/data/2.5/air_pollution';
  static const String owmOneCallV3Path = '/data/3.0/onecall';
  static const String owmGeoDirectPath = '/geo/1.0/direct';
  static const String owmGeoReversePath = '/geo/1.0/reverse';

  /// Full URL prefix for OpenWeatherMap weather icon assets (PNG, 4x).
  static const String owmIconUrlPrefix = 'https://openweathermap.org/img/wn/';

  // ── Open-Meteo fallback (keyless) ──────────────────────────────────────
  static const String openMeteoForecastPath = '/forecast';
  static const String openMeteoGeocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1';
  static const String openMeteoAirQualityBaseUrl =
      'https://air-quality-api.open-meteo.com/v1';

  // ── Hive cache keys (prefixed by location key e.g. "33.68_73.05") ─────
  static const String hiveBoxName = 'weather_cache';
  static const String currentCachePrefix = 'current_';
  static const String forecastCachePrefix = 'forecast_';
  static const String hourlyCachePrefix = 'hourly_';
  static const String alertsCachePrefix = 'alerts_';

  // ── SharedPreferences keys (small, durable user prefs) ────────────────
  static const String prefSelectedLocation = 'weather.selected_location';
  static const String prefSavedLocations = 'weather.saved_locations';
  static const String prefLastSyncMillis = 'weather.last_sync_millis';

  // ── Cache TTLs ─────────────────────────────────────────────────────────
  static const Duration currentCacheTtl = Duration(minutes: 10);
  static const Duration hourlyCacheTtl = Duration(minutes: 30);
  static const Duration forecastCacheTtl = Duration(hours: 3);
  static const Duration autoRefreshInterval = Duration(minutes: 10);
  static const Duration httpTimeout = Duration(seconds: 12);

  // ── UI tuning ──────────────────────────────────────────────────────────
  static const int hourlySliderItemCount = 12;
  static const int dailyForecastDays = 7;
  static const int citySearchMinChars = 2;
  static const int citySearchMaxResults = 8;
  static const int savedLocationsLimit = 5;

  // ── Farmer advisory thresholds ────────────────────────────────────────
  /// Rain probability (%) above which we warn against irrigation/spraying.
  static const int rainProbabilityHigh = 60;

  /// Rain probability (%) below which farmers can spray confidently.
  static const int rainProbabilityLow = 20;

  /// Wind speed (km/h) above which we mark it as "high wind".
  static const double windSpeedHighKmh = 30;

  /// Wind speed (km/h) above which spraying is unsafe.
  static const double windSpeedSprayUnsafeKmh = 18;

  /// Temperature (°C) above which heatwave advisory is shown.
  static const double heatwaveTemperatureC = 38;

  /// Temperature (°C) below which frost warning is shown.
  static const double frostTemperatureC = 2;

  /// UV index above which strong-sun advisory is shown.
  static const double uvIndexHigh = 7;
}
