import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/error_logger.dart';
import '../../data/repositories/weather_repository.dart';
import '../../domain/entities/weather_models.dart';

/// Centralised state for current weather and the 7-day forecast.
///
/// Replaces the previous per-screen `FutureBuilder` + `static Future` pattern
/// with a single source of truth. Two screens (home dashboard + weather
/// screen) can listen to this provider and they will share the same data
/// without triggering duplicate network calls.
///
/// Behaviour:
///   * `ensureLoaded()` is a no-op when data already exists; safe to call
///     from `initState` of any consumer.
///   * `refreshAll()` forces a network refetch of both current + forecast.
///   * In-flight requests are de-duplicated: if `loadCurrent()` is called
///     while a previous load is still pending, the same Future is returned.
///   * An optional auto-refresh timer can be enabled with [startAutoRefresh].
class WeatherProvider extends ChangeNotifier {
  WeatherProvider({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository();

  final WeatherRepository _repository;

  CurrentWeather? _current;
  List<DailyForecast> _forecast = const <DailyForecast>[];
  Object? _currentError;
  Object? _forecastError;
  bool _isLoadingCurrent = false;
  bool _isLoadingForecast = false;
  DateTime? _lastSyncAt;

  Future<CurrentWeather>? _inFlightCurrent;
  Future<List<DailyForecast>>? _inFlightForecast;

  Timer? _autoRefreshTimer;

  // ── Public read-only state ──────────────────────────────────────────────
  CurrentWeather? get current => _current;
  List<DailyForecast> get forecast => _forecast;

  bool get hasCurrent => _current != null;
  bool get hasForecast => _forecast.isNotEmpty;

  bool get isLoadingCurrent => _isLoadingCurrent;
  bool get isLoadingForecast => _isLoadingForecast;
  bool get isLoading => _isLoadingCurrent || _isLoadingForecast;

  Object? get currentError => _currentError;
  Object? get forecastError => _forecastError;
  bool get hasCurrentError => _currentError != null && _current == null;
  bool get hasForecastError => _forecastError != null && _forecast.isEmpty;

  DateTime? get lastSyncAt => _lastSyncAt;

  // ── Loaders ─────────────────────────────────────────────────────────────

  /// Loads current + forecast if they are not already loaded.
  /// Safe to call repeatedly; callers don't need to track first-load themselves.
  Future<void> ensureLoaded() async {
    final futures = <Future<void>>[];
    if (!hasCurrent && !_isLoadingCurrent) {
      futures.add(loadCurrent());
    }
    if (!hasForecast && !_isLoadingForecast) {
      futures.add(loadForecast());
    }
    if (futures.isNotEmpty) await Future.wait(futures);
  }

  Future<CurrentWeather?> loadCurrent({bool forceRefresh = false}) async {
    if (_inFlightCurrent != null && !forceRefresh) {
      return _inFlightCurrent;
    }

    _isLoadingCurrent = true;
    _currentError = null;
    notifyListeners();

    final future = _repository.fetchCurrentWeather(forceRefresh: forceRefresh);
    _inFlightCurrent = future;

    try {
      final result = await future;
      _current = result;
      _lastSyncAt = DateTime.now();
      return result;
    } catch (error, stack) {
      _currentError = error;
      ErrorLogger.instance.recordNonFatal(
        error,
        stack,
        context: 'WeatherProvider.loadCurrent',
        attributes: {'force_refresh': forceRefresh},
      );
      return null;
    } finally {
      _isLoadingCurrent = false;
      _inFlightCurrent = null;
      notifyListeners();
    }
  }

  Future<List<DailyForecast>?> loadForecast({bool forceRefresh = false}) async {
    if (_inFlightForecast != null && !forceRefresh) {
      return _inFlightForecast;
    }

    _isLoadingForecast = true;
    _forecastError = null;
    notifyListeners();

    final future =
        _repository.fetchSevenDayForecast(forceRefresh: forceRefresh);
    _inFlightForecast = future;

    try {
      final result = await future;
      _forecast = result;
      _lastSyncAt = DateTime.now();
      return result;
    } catch (error, stack) {
      _forecastError = error;
      ErrorLogger.instance.recordNonFatal(
        error,
        stack,
        context: 'WeatherProvider.loadForecast',
        attributes: {'force_refresh': forceRefresh},
      );
      return null;
    } finally {
      _isLoadingForecast = false;
      _inFlightForecast = null;
      notifyListeners();
    }
  }

  /// Refreshes both current and forecast in parallel, bypassing the cache.
  Future<void> refreshAll() async {
    await Future.wait<void>([
      loadCurrent(forceRefresh: true),
      loadForecast(forceRefresh: true),
    ]);
  }

  // ── Auto-refresh timer ──────────────────────────────────────────────────

  /// Starts (or restarts) a periodic auto-refresh. Idempotent.
  void startAutoRefresh({
    Duration interval = const Duration(minutes: 10),
  }) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) => refreshAll());
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
