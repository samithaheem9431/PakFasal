import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/error_logger.dart';
import '../../constants/weather_constants.dart';
import '../../domain/entities/weather_models.dart';
import '../services/location_service.dart';
import '../services/weather_api_service.dart';

/// Result returned by the repository — surfaces both the data and any
/// transient state (offline/stale cache) for the UI to render correctly.
class WeatherFetchResult {
  const WeatherFetchResult({
    required this.snapshot,
    required this.fromCache,
    required this.isStale,
    this.error,
  });

  /// Always populated when a snapshot was available (live or cached).
  /// Null only when the very first call fails and there is no cache yet.
  final WeatherSnapshot? snapshot;

  /// True when [snapshot] came from disk (Hive) instead of the network.
  final bool fromCache;

  /// True when [snapshot] exists but is older than the configured TTL.
  /// Used by the UI to show a subtle "showing cached data" hint.
  final bool isStale;

  /// Network/parse error encountered. May be non-null even when [snapshot]
  /// is non-null (e.g. cache served because network failed).
  final Object? error;
}

/// Orchestrates location → API → cache for the weather feature.
///
/// Responsibilities:
///   * Resolve the active [WeatherLocation] (GPS or user-picked).
///   * Fetch a [WeatherSnapshot] via [WeatherApiService] and cache it.
///   * Serve cached data when the network fails (offline first).
///   * Persist the user's last-selected city + saved cities list so the
///     next launch shows their preferred location instantly.
class WeatherRepository {
  WeatherRepository({
    WeatherApiService? apiService,
    LocationService? locationService,
    Box? cacheBox,
  })  : _api = apiService ?? WeatherApiService(),
        _location = locationService ?? const LocationService(),
        _box = cacheBox ?? Hive.box(WeatherConstants.hiveBoxName);

  final WeatherApiService _api;
  final LocationService _location;
  final Box _box;

  // ── Public API ─────────────────────────────────────────────────────────

  /// Resolves the active location for this session.
  ///
  /// Priority:
  ///   1. User's last manually-selected city (persistent).
  ///   2. Device GPS (when available).
  ///   3. Last successfully-used location from cache.
  ///   4. A safe default (Lahore, Pakistan) so the UI never crashes.
  Future<WeatherLocation> resolveActiveLocation({
    bool forceGps = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceGps) {
      final raw = prefs.getString(WeatherConstants.prefSelectedLocation);
      if (raw != null && raw.isNotEmpty) {
        try {
          final selected = WeatherLocation.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          if (!selected.isCurrent) return selected;
        } catch (_) {/* fall through to GPS */}
      }
    }

    final gps = await _location.getCurrentPosition();
    if (gps.isSuccess && gps.position != null) {
      final pos = gps.position!;
      final label = await _api.reverseGeocode(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      final location = WeatherLocation(
        label: label,
        latitude: pos.latitude,
        longitude: pos.longitude,
        isCurrent: true,
      );
      await _persistSelectedLocation(location);
      return location;
    }

    // GPS failed — log *why* so this is diagnosable from Crashlytics/console
    // instead of silently always showing the Lahore fallback below.
    ErrorLogger.instance.log(
      'weather_repository: GPS resolution failed (${gps.error?.name ?? 'no position'}), '
      'falling back to cache/default location',
    );

    // Fall back to whatever we cached last time.
    final cachedSnapshot = _readSnapshotCache(_lastUsedLocationKey(prefs));
    if (cachedSnapshot != null) return cachedSnapshot.location;

    // Absolute fallback so the UI always has something to render.
    return const WeatherLocation(
      label: 'Lahore, Pakistan',
      latitude: 31.5204,
      longitude: 74.3587,
    );
  }

  /// Fetches a complete [WeatherSnapshot] for [location].
  ///
  /// Behaviour:
  ///   * When `forceRefresh` is false and cache is fresh → returns cache.
  ///   * Otherwise → fetches from network; on failure, falls back to
  ///     whatever cache exists (even if stale) so the UI stays usable
  ///     when offline.
  Future<WeatherFetchResult> fetchSnapshot({
    required WeatherLocation location,
    bool forceRefresh = false,
  }) async {
    final key = _locationKey(location.latitude, location.longitude);
    final cached = _readSnapshotCache(key);

    if (!forceRefresh && cached != null && _isFresh(cached)) {
      return WeatherFetchResult(
        snapshot: cached,
        fromCache: true,
        isStale: false,
      );
    }

    final result = await _api.fetchSnapshot(
      latitude: location.latitude,
      longitude: location.longitude,
      locationLabel: location.label,
    );

    if (result.isSuccess && result.data != null) {
      await _writeSnapshotCache(key, result.data!);
      await _persistLastUsedLocation(location);
      return WeatherFetchResult(
        snapshot: result.data,
        fromCache: false,
        isStale: false,
      );
    }

    // Network/parse failure — fall back to cache if any.
    if (cached != null) {
      return WeatherFetchResult(
        snapshot: cached,
        fromCache: true,
        isStale: true,
        error: result.error,
      );
    }
    return WeatherFetchResult(
      snapshot: null,
      fromCache: false,
      isStale: false,
      error: result.error,
    );
  }

  // ── Saved cities ───────────────────────────────────────────────────────

  Future<List<WeatherLocation>> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getStringList(WeatherConstants.prefSavedLocations) ?? const [];
    return raw
        .map((entry) {
          try {
            return WeatherLocation.fromJson(
              jsonDecode(entry) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<WeatherLocation>()
        .toList(growable: false);
  }

  Future<void> addSavedLocation(WeatherLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getStringList(WeatherConstants.prefSavedLocations) ?? const [];
    final list = [...existing];

    list.removeWhere((entry) {
      try {
        final loc = WeatherLocation.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
        return _sameLocation(loc, location);
      } catch (_) {
        return false;
      }
    });
    list.insert(0, jsonEncode(location.toJson()));

    final trimmed = list.take(WeatherConstants.savedLocationsLimit).toList();
    await prefs.setStringList(
      WeatherConstants.prefSavedLocations,
      trimmed,
    );
  }

  Future<void> removeSavedLocation(WeatherLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getStringList(WeatherConstants.prefSavedLocations) ?? const [];
    final list = existing.where((entry) {
      try {
        final loc = WeatherLocation.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
        return !_sameLocation(loc, location);
      } catch (_) {
        return true;
      }
    }).toList();
    await prefs.setStringList(
      WeatherConstants.prefSavedLocations,
      list,
    );
  }

  Future<void> selectLocation(WeatherLocation location) =>
      _persistSelectedLocation(location);

  Future<WeatherApiResult<List<WeatherLocation>>> searchCities(
    String query,
  ) =>
      _api.searchCities(query);

  // ── Backwards compatibility helpers ────────────────────────────────────
  // The legacy [SensorScreen] calls fetchCurrentWeather() directly. Keep
  // a thin wrapper so existing call sites keep working without churn.

  Future<CurrentWeather> fetchCurrentWeather({
    bool forceRefresh = false,
  }) async {
    final location = await resolveActiveLocation();
    final result = await fetchSnapshot(
      location: location,
      forceRefresh: forceRefresh,
    );
    if (result.snapshot != null) return result.snapshot!.current;
    throw result.error ?? Exception('Could not fetch current weather');
  }

  Future<List<DailyForecast>> fetchSevenDayForecast({
    bool forceRefresh = false,
  }) async {
    final location = await resolveActiveLocation();
    final result = await fetchSnapshot(
      location: location,
      forceRefresh: forceRefresh,
    );
    if (result.snapshot != null) return result.snapshot!.daily;
    throw result.error ?? Exception('Could not fetch 7-day forecast');
  }

  Future<List<HourlyForecastPoint>> fetchHourlyForecast({
    bool forceRefresh = false,
  }) async {
    final location = await resolveActiveLocation();
    final result = await fetchSnapshot(
      location: location,
      forceRefresh: forceRefresh,
    );
    if (result.snapshot != null) return result.snapshot!.hourly;
    throw result.error ?? Exception('Could not fetch hourly forecast');
  }

  // ── Cache helpers ──────────────────────────────────────────────────────

  String _locationKey(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  String? _lastUsedLocationKey(SharedPreferences prefs) {
    final raw = prefs.getString(WeatherConstants.prefSelectedLocation);
    if (raw == null) return null;
    try {
      final loc =
          WeatherLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return _locationKey(loc.latitude, loc.longitude);
    } catch (_) {
      return null;
    }
  }

  bool _sameLocation(WeatherLocation a, WeatherLocation b) {
    return (a.latitude - b.latitude).abs() < 0.01 &&
        (a.longitude - b.longitude).abs() < 0.01;
  }

  bool _isFresh(WeatherSnapshot snapshot) {
    return DateTime.now().difference(snapshot.fetchedAt) <
        WeatherConstants.currentCacheTtl;
  }

  Future<void> _persistSelectedLocation(WeatherLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      WeatherConstants.prefSelectedLocation,
      jsonEncode(location.toJson()),
    );
  }

  Future<void> _persistLastUsedLocation(WeatherLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      WeatherConstants.prefLastSyncMillis,
      DateTime.now().millisecondsSinceEpoch,
    );
    // Only overwrite the selected pointer if user hasn't explicitly picked
    // something else (selected is preserved by [selectLocation]).
    if (location.isCurrent) {
      await prefs.setString(
        WeatherConstants.prefSelectedLocation,
        jsonEncode(location.toJson()),
      );
    }
  }

  WeatherSnapshot? _readSnapshotCache(String? key) {
    if (key == null) return null;
    final raw = _box.get('snapshot_$key') as String?;
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _snapshotFromJson(map);
    } catch (e, s) {
      debugPrint('weather_repository: cache decode failed → $e\n$s');
      return null;
    }
  }

  Future<void> _writeSnapshotCache(
    String key,
    WeatherSnapshot snapshot,
  ) async {
    try {
      await _box.put('snapshot_$key', jsonEncode(_snapshotToJson(snapshot)));
    } catch (e, s) {
      debugPrint('weather_repository: cache write failed → $e\n$s');
    }
  }

  Map<String, dynamic> _snapshotToJson(WeatherSnapshot s) => {
        'fetchedAt': s.fetchedAt.millisecondsSinceEpoch,
        'location': s.location.toJson(),
        'current': _currentToJson(s.current),
        'hourly': s.hourly.map(_hourlyToJson).toList(),
        'daily': s.daily.map(_dailyToJson).toList(),
        'alerts': s.alerts.map(_alertToJson).toList(),
      };

  WeatherSnapshot _snapshotFromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      location: WeatherLocation.fromJson(
        (json['location'] as Map<String, dynamic>?) ?? const {},
      ),
      current: _currentFromJson(
        (json['current'] as Map<String, dynamic>?) ?? const {},
      ),
      hourly: ((json['hourly'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_hourlyFromJson)
          .toList(),
      daily: ((json['daily'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_dailyFromJson)
          .toList(),
      alerts: ((json['alerts'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_alertFromJson)
          .toList(),
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(
        ((json['fetchedAt'] as num?) ?? 0).toInt(),
      ),
    );
  }

  // ── (de)serialization ──────────────────────────────────────────────────

  Map<String, dynamic> _currentToJson(CurrentWeather c) => {
        'locationLabel': c.locationLabel,
        'temperatureC': c.temperatureC,
        'apparentTemperatureC': c.apparentTemperatureC,
        'humidity': c.humidity,
        'windSpeedKmh': c.windSpeedKmh,
        'pressureHpa': c.pressureHpa,
        'visibilityKm': c.visibilityKm,
        'uvIndex': c.uvIndex,
        'airQualityIndex': c.airQualityIndex,
        'weatherAlert': c.weatherAlert,
        'rainChancePercent': c.rainChancePercent,
        'conditionCode': c.conditionCode,
        'conditionLabel': c.conditionLabel,
        'iconCode': c.iconCode,
        'minTempC': c.minTempC,
        'maxTempC': c.maxTempC,
        'dewPointC': c.dewPointC,
        'cloudCoverPercent': c.cloudCoverPercent,
        'windDirectionDeg': c.windDirectionDeg,
        'sunrise': c.sunrise?.millisecondsSinceEpoch,
        'sunset': c.sunset?.millisecondsSinceEpoch,
        'observedAt': c.observedAt?.millisecondsSinceEpoch,
        'latitude': c.latitude,
        'longitude': c.longitude,
      };

  CurrentWeather _currentFromJson(Map<String, dynamic> m) => CurrentWeather(
        locationLabel: (m['locationLabel'] as String?) ?? 'Unknown',
        temperatureC: ((m['temperatureC'] as num?) ?? 0).toDouble(),
        apparentTemperatureC:
            ((m['apparentTemperatureC'] as num?) ?? 0).toDouble(),
        humidity: ((m['humidity'] as num?) ?? 0).toInt(),
        windSpeedKmh: ((m['windSpeedKmh'] as num?) ?? 0).toDouble(),
        pressureHpa: ((m['pressureHpa'] as num?) ?? 0).toInt(),
        visibilityKm: ((m['visibilityKm'] as num?) ?? 0).toDouble(),
        uvIndex: ((m['uvIndex'] as num?) ?? 0).toDouble(),
        airQualityIndex: ((m['airQualityIndex'] as num?) ?? 0).toInt(),
        weatherAlert: m['weatherAlert'] as String?,
        rainChancePercent: ((m['rainChancePercent'] as num?) ?? 0).toInt(),
        conditionCode: ((m['conditionCode'] as num?) ?? 0).toInt(),
        conditionLabel: m['conditionLabel'] as String?,
        iconCode: m['iconCode'] as String?,
        minTempC: (m['minTempC'] as num?)?.toDouble(),
        maxTempC: (m['maxTempC'] as num?)?.toDouble(),
        dewPointC: (m['dewPointC'] as num?)?.toDouble(),
        cloudCoverPercent: (m['cloudCoverPercent'] as num?)?.toInt(),
        windDirectionDeg: (m['windDirectionDeg'] as num?)?.toInt(),
        sunrise: _maybeDate(m['sunrise']),
        sunset: _maybeDate(m['sunset']),
        observedAt: _maybeDate(m['observedAt']),
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> _hourlyToJson(HourlyForecastPoint h) => {
        'timeLabel': h.timeLabel,
        'temperatureC': h.temperatureC,
        'conditionCode': h.conditionCode,
        'time': h.time?.millisecondsSinceEpoch,
        'iconCode': h.iconCode,
        'rainProbabilityPercent': h.rainProbabilityPercent,
        'windSpeedKmh': h.windSpeedKmh,
      };

  HourlyForecastPoint _hourlyFromJson(Map<String, dynamic> m) =>
      HourlyForecastPoint(
        timeLabel: (m['timeLabel'] as String?) ?? '--',
        temperatureC: ((m['temperatureC'] as num?) ?? 0).toDouble(),
        conditionCode: ((m['conditionCode'] as num?) ?? 0).toInt(),
        time: _maybeDate(m['time']),
        iconCode: m['iconCode'] as String?,
        rainProbabilityPercent: (m['rainProbabilityPercent'] as num?)?.toInt(),
        windSpeedKmh: (m['windSpeedKmh'] as num?)?.toDouble(),
      );

  Map<String, dynamic> _dailyToJson(DailyForecast d) => {
        'dateLabel': d.dateLabel,
        'maxTempC': d.maxTempC,
        'minTempC': d.minTempC,
        'rainChance': d.rainChance,
        'conditionCode': d.conditionCode,
        'date': d.date?.millisecondsSinceEpoch,
        'iconCode': d.iconCode,
        'conditionLabel': d.conditionLabel,
        'windSpeedKmh': d.windSpeedKmh,
        'humidity': d.humidity,
        'uvIndex': d.uvIndex,
        'sunrise': d.sunrise?.millisecondsSinceEpoch,
        'sunset': d.sunset?.millisecondsSinceEpoch,
      };

  DailyForecast _dailyFromJson(Map<String, dynamic> m) => DailyForecast(
        dateLabel: (m['dateLabel'] as String?) ?? '',
        maxTempC: ((m['maxTempC'] as num?) ?? 0).toDouble(),
        minTempC: ((m['minTempC'] as num?) ?? 0).toDouble(),
        rainChance: ((m['rainChance'] as num?) ?? 0).toInt(),
        conditionCode: ((m['conditionCode'] as num?) ?? 0).toInt(),
        date: _maybeDate(m['date']),
        iconCode: m['iconCode'] as String?,
        conditionLabel: m['conditionLabel'] as String?,
        windSpeedKmh: (m['windSpeedKmh'] as num?)?.toDouble(),
        humidity: (m['humidity'] as num?)?.toInt(),
        uvIndex: (m['uvIndex'] as num?)?.toDouble(),
        sunrise: _maybeDate(m['sunrise']),
        sunset: _maybeDate(m['sunset']),
      );

  Map<String, dynamic> _alertToJson(WeatherAlert a) => {
        'title': a.title,
        'description': a.description,
        'severity': a.severity.name,
        'sender': a.sender,
        'start': a.start?.millisecondsSinceEpoch,
        'end': a.end?.millisecondsSinceEpoch,
        'tags': a.tags,
      };

  WeatherAlert _alertFromJson(Map<String, dynamic> m) => WeatherAlert(
        title: (m['title'] as String?) ?? 'Weather alert',
        description: (m['description'] as String?) ?? '',
        severity: WeatherSeverity.values.firstWhere(
          (s) => s.name == m['severity'],
          orElse: () => WeatherSeverity.warning,
        ),
        sender: m['sender'] as String?,
        start: _maybeDate(m['start']),
        end: _maybeDate(m['end']),
        tags:
            ((m['tags'] as List<dynamic>?) ?? const []).whereType<String>().toList(),
      );

  DateTime? _maybeDate(dynamic v) {
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    return null;
  }
}
