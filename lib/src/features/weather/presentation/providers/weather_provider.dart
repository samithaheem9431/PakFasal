import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/error_logger.dart';
import '../../constants/weather_constants.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/weather_api_service.dart';
import '../../domain/entities/weather_models.dart';

/// High-level UI state machine for the weather feature.
///
/// Coordinates location resolution, snapshot fetching, city search and
/// saved locations. Two screens (home dashboard + weather screen) share
/// this provider so they always render the same data without triggering
/// duplicate network calls.
///
/// Behaviour:
///   * [ensureLoaded] is a no-op when data already exists; safe to call
///     from `initState` of any consumer.
///   * [refreshAll] forces a network refetch.
///   * [selectLocation] switches to a user-picked city and refetches.
///   * In-flight snapshot loads are de-duplicated.
///   * [startAutoRefresh] enables a periodic background refresh.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository();

  final WeatherRepository _repository;

  WeatherSnapshot? _snapshot;
  WeatherLocation? _activeLocation;
  List<WeatherLocation> _savedLocations = const <WeatherLocation>[];

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isFromCache = false;
  bool _isStale = false;
  Object? _error;
  Object? _searchError;
  List<WeatherLocation> _searchResults = const <WeatherLocation>[];

  Future<WeatherFetchResult>? _inFlightFetch;
  Timer? _autoRefreshTimer;
  String? _lastSearchQuery;
  int _searchSequence = 0;

  // ── Public read-only state ─────────────────────────────────────────────

  WeatherSnapshot? get snapshot => _snapshot;
  WeatherLocation? get activeLocation => _activeLocation;
  List<WeatherLocation> get savedLocations => _savedLocations;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isFromCache => _isFromCache;
  bool get isStale => _isStale;
  Object? get error => _error;
  Object? get searchError => _searchError;
  List<WeatherLocation> get searchResults => _searchResults;

  bool get hasSnapshot => _snapshot != null;
  bool get hasError => _error != null && _snapshot == null;

  DateTime? get lastSyncAt => _snapshot?.fetchedAt;

  // ── Backwards-compat surface used by existing screens ─────────────────
  // (home_dashboard_screen.dart, sensor_screen.dart, home_weather_card.dart)

  CurrentWeather? get current => _snapshot?.current;
  List<DailyForecast> get forecast =>
      _snapshot?.daily ?? const <DailyForecast>[];
  List<HourlyForecastPoint> get hourly =>
      _snapshot?.hourly ?? const <HourlyForecastPoint>[];
  List<WeatherAlert> get alerts => _snapshot?.alerts ?? const <WeatherAlert>[];

  bool get isLoadingForecast => _isLoading && (_snapshot?.daily.isEmpty ?? true);
  bool get isLoadingCurrent => _isLoading && _snapshot?.current == null;
  bool get isLoadingHourly =>
      _isLoading && (_snapshot?.hourly.isEmpty ?? true);

  /// BC alias for legacy screens that still call `loadCurrent` on the
  /// retry path. The new architecture fetches everything as one snapshot,
  /// so all three legacy loaders forward to [_loadSnapshot].
  Future<void> loadCurrent({bool forceRefresh = false}) =>
      _loadSnapshot(forceRefresh: forceRefresh);

  Future<void> loadForecast({bool forceRefresh = false}) =>
      _loadSnapshot(forceRefresh: forceRefresh);

  Future<void> loadHourly({bool forceRefresh = false}) =>
      _loadSnapshot(forceRefresh: forceRefresh);

  // ── Loaders ────────────────────────────────────────────────────────────

  /// Loads weather data if not already loaded. Safe to call repeatedly.
  Future<void> ensureLoaded() async {
    if (hasSnapshot || _isLoading) return;
    await _loadSnapshot(forceRefresh: false);
    await _loadSavedLocationsSilently();
  }

  /// Force-refreshes the snapshot bypassing the cache TTL.
  Future<void> refreshAll() => _loadSnapshot(forceRefresh: true);

  /// Re-resolves the current location (e.g. user moved) and refetches.
  Future<void> useCurrentLocation() async {
    _activeLocation = await _repository.resolveActiveLocation(forceGps: true);
    await _loadSnapshot(forceRefresh: true);
  }

  /// Switches the active location to [location] and refetches.
  Future<void> selectLocation(WeatherLocation location) async {
    _activeLocation = location;
    await _repository.selectLocation(location);
    await _repository.addSavedLocation(location);
    await _loadSnapshot(forceRefresh: true);
    await _loadSavedLocationsSilently();
  }

  Future<void> removeSavedLocation(WeatherLocation location) async {
    await _repository.removeSavedLocation(location);
    await _loadSavedLocationsSilently();
  }

  /// Searches for cities matching [query]. Late results are dropped if a
  /// newer search has been started in the meantime.
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    _lastSearchQuery = trimmed;
    if (trimmed.length < WeatherConstants.citySearchMinChars) {
      _searchResults = const [];
      _searchError = null;
      _isSearching = false;
      notifyListeners();
      return;
    }

    final mySequence = ++_searchSequence;
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    final WeatherApiResult<List<WeatherLocation>> result =
        await _repository.searchCities(trimmed);

    if (mySequence != _searchSequence) return; // stale response, ignore

    if (result.isSuccess) {
      _searchResults = result.data ?? const [];
      _searchError = null;
    } else {
      _searchResults = const [];
      _searchError = result.error;
    }
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchSequence++;
    _searchResults = const [];
    _searchError = null;
    _isSearching = false;
    _lastSearchQuery = null;
    notifyListeners();
  }

  // ── Internal ───────────────────────────────────────────────────────────

  Future<void> _loadSnapshot({required bool forceRefresh}) async {
    if (_inFlightFetch != null && !forceRefresh) {
      await _inFlightFetch;
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeLocation ??= await _repository.resolveActiveLocation();
      final fetch = _repository.fetchSnapshot(
        location: _activeLocation!,
        forceRefresh: forceRefresh,
      );
      _inFlightFetch = fetch;
      final result = await fetch;

      if (result.snapshot != null) {
        _snapshot = result.snapshot;
        _activeLocation = result.snapshot!.location;
      }
      _isFromCache = result.fromCache;
      _isStale = result.isStale;
      _error = result.error;

      if (result.error != null) {
        ErrorLogger.instance.recordNonFatal(
          result.error!,
          StackTrace.current,
          context: 'WeatherProvider._loadSnapshot',
          attributes: {
            'force_refresh': forceRefresh,
            'from_cache': result.fromCache,
            'is_stale': result.isStale,
          },
        );
      }
    } catch (error, stack) {
      _error = error;
      ErrorLogger.instance.recordNonFatal(
        error,
        stack,
        context: 'WeatherProvider._loadSnapshot.unexpected',
        attributes: {'force_refresh': forceRefresh},
      );
    } finally {
      _isLoading = false;
      _inFlightFetch = null;
      notifyListeners();
    }
  }

  Future<void> _loadSavedLocationsSilently() async {
    try {
      _savedLocations = await _repository.loadSavedLocations();
      notifyListeners();
    } catch (_) {
      // Saved-locations load is best-effort; never block the UI on it.
    }
  }

  // ── Auto-refresh timer ─────────────────────────────────────────────────

  void startAutoRefresh({
    Duration interval = WeatherConstants.autoRefreshInterval,
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

  // ── Debug / introspection ──────────────────────────────────────────────

  @visibleForTesting
  String? get debugLastSearchQuery => _lastSearchQuery;
}
