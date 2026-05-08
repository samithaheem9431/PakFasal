// Domain entities for the weather feature.
//
// These are deliberately plain immutable Dart classes (no codegen) so they
// are easy to read for an FYP project and have zero build-runner overhead.
// All fields added during the v2 redesign are nullable / have safe defaults
// so any pre-existing consumer (home dashboard, sensor screen) keeps
// compiling and running without modification.

/// Severity for [WeatherAlert] / crop-specific warnings.
enum WeatherSeverity { info, advisory, warning, severe }

/// One snapshot of "right now" at the active location.
class CurrentWeather {
  const CurrentWeather({
    required this.locationLabel,
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.humidity,
    required this.windSpeedKmh,
    required this.pressureHpa,
    required this.visibilityKm,
    required this.uvIndex,
    required this.airQualityIndex,
    this.weatherAlert,
    required this.rainChancePercent,
    required this.conditionCode,
    // ── v2 fields (optional, BC-safe) ──
    this.conditionLabel,
    this.iconCode,
    this.minTempC,
    this.maxTempC,
    this.dewPointC,
    this.cloudCoverPercent,
    this.windDirectionDeg,
    this.sunrise,
    this.sunset,
    this.observedAt,
    this.latitude,
    this.longitude,
  });

  // ── v1 fields (kept for BC) ────────────────────────────────────────────
  final String locationLabel;
  final double temperatureC;
  final double apparentTemperatureC;
  final int humidity;
  final double windSpeedKmh;
  final int pressureHpa;
  final double visibilityKm;
  final double uvIndex;
  final int airQualityIndex;
  final String? weatherAlert;
  final int rainChancePercent;
  final int conditionCode;

  // ── v2 fields ──────────────────────────────────────────────────────────
  /// Localized / English condition label from the API ("Light rain").
  final String? conditionLabel;

  /// Provider-specific icon code (OWM "10d", "01n", etc.). Used for
  /// network-icon rendering when available.
  final String? iconCode;

  /// True daily Hi/Lo (was previously approximated as ±x in the UI).
  final double? minTempC;
  final double? maxTempC;

  final double? dewPointC;
  final int? cloudCoverPercent;
  final int? windDirectionDeg;

  /// Local sunrise/sunset for today.
  final DateTime? sunrise;
  final DateTime? sunset;

  /// When the API observation/forecast was generated.
  final DateTime? observedAt;

  /// Coordinates of the active location — used to render local time tags
  /// and re-issue requests.
  final double? latitude;
  final double? longitude;
}

/// Forecast point for a single hour.
class HourlyForecastPoint {
  const HourlyForecastPoint({
    required this.timeLabel,
    required this.temperatureC,
    required this.conditionCode,
    this.time,
    this.iconCode,
    this.rainProbabilityPercent,
    this.windSpeedKmh,
  });

  final String timeLabel;
  final double temperatureC;
  final int conditionCode;

  // ── v2 fields ──
  final DateTime? time;
  final String? iconCode;
  final int? rainProbabilityPercent;
  final double? windSpeedKmh;
}

/// One day in the 7-day forecast.
class DailyForecast {
  const DailyForecast({
    required this.dateLabel,
    required this.maxTempC,
    required this.minTempC,
    required this.rainChance,
    required this.conditionCode,
    this.date,
    this.iconCode,
    this.conditionLabel,
    this.windSpeedKmh,
    this.humidity,
    this.uvIndex,
    this.sunrise,
    this.sunset,
  });

  final String dateLabel;
  final double maxTempC;
  final double minTempC;
  final int rainChance;
  final int conditionCode;

  // ── v2 fields ──
  final DateTime? date;
  final String? iconCode;
  final String? conditionLabel;
  final double? windSpeedKmh;
  final int? humidity;
  final double? uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;
}

/// Provider-emitted alert (e.g. National Weather Service, OWM alerts array).
class WeatherAlert {
  const WeatherAlert({
    required this.title,
    required this.description,
    required this.severity,
    this.sender,
    this.start,
    this.end,
    this.tags = const <String>[],
  });

  final String title;
  final String description;
  final WeatherSeverity severity;
  final String? sender;
  final DateTime? start;
  final DateTime? end;
  final List<String> tags;
}

/// A user-selected or auto-detected geographic location.
class WeatherLocation {
  const WeatherLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.isCurrent = false,
  });

  /// Human-readable label, e.g. "Lahore, Pakistan".
  final String label;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  /// `true` when this location was resolved from device GPS (rather than
  /// user-picked from search results).
  final bool isCurrent;

  Map<String, dynamic> toJson() => {
        'label': label,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
        'isCurrent': isCurrent,
      };

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      label: (json['label'] as String?) ?? 'Unknown',
      latitude: ((json['latitude'] as num?) ?? 0).toDouble(),
      longitude: ((json['longitude'] as num?) ?? 0).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      isCurrent: (json['isCurrent'] as bool?) ?? false,
    );
  }
}

/// Aggregate of everything a weather screen needs at one snapshot in time.
/// Kept as a value-object so widgets can take it as a single immutable
/// argument (cheap == comparison, easy to memoise).
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.alerts,
    required this.fetchedAt,
  });

  final WeatherLocation location;
  final CurrentWeather current;
  final List<HourlyForecastPoint> hourly;
  final List<DailyForecast> daily;
  final List<WeatherAlert> alerts;
  final DateTime fetchedAt;
}
