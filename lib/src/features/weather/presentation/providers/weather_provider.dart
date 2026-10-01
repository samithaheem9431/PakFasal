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
///   * Hydrates from Hive on bootstrap so the weather card paints instantly
///     on cold start (no spinner flash when cache exists).
///   * [ensureLoaded] is a no-op when data already exists; safe to call
///     from `initState` of any consumer.
///   * [refreshAll] forces a network refetch (pull-to-refresh).
///   * [softRefresh] refreshes quietly when TTL expires — keeps showing
///     cached data; never flips the UI to a loading/retry state.
///   * [selectLocation] switches to a user-picked city and refetches.
///   * In-flight snapshot loads are de-duplicated.
///   * [startAutoRefresh] enables a periodic background refresh.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository() {
    unawaited(_bootstrap());
  }

  final WeatherRepository _repository;

  WeatherSnapshot? _snapshot;
  WeatherLocation? _activeLocation;
  List<WeatherLocation> _savedLocations = const <WeatherLocation>[];

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isFromCache = false;
  bool _isStale = false;
  bool _bootstrapped = false;
  Object? _error;
  Object? _searchError;
  List<WeatherLocation> _searchResults = const <WeatherLocation>[];

  Future<WeatherFetchResult>? _inFlightFetch;
  Future<void>? _bootstrapFuture;
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

  /// Paints cached weather immediately, then refreshes in the background
  /// only when the TTL has expired. Safe to call repeatedly.
  Future<void> ensureLoaded() async {
    await _bootstrapFuture;
    if (_isLoading) return;

    if (hasSnapshot) {
      if (_isSnapshotExpired) {
        // Keep showing the card; refresh quietly without a loading flash.
        unawaited(_loadSnapshot(forceRefresh: false, silent: true));
      }
      await _loadSavedLocationsSilently();
      return;
    }

    await _loadSnapshot(forceRefresh: false);
    await _loadSavedLocationsSilently();
  }

  /// Force-refreshes the snapshot bypassing the cache TTL (pull-to-refresh).
  /// Still keeps existing data on screen while the network call runs.
  Future<void> refreshAll() =>
      _loadSnapshot(forceRefresh: true, silent: hasSnapshot);

  /// Quiet refresh used on app resume / auto-timer. Skips work when the
  /// current snapshot is still within TTL so the card never flickers.
  Future<void> softRefresh() async {
    await _bootstrapFuture;
    if (!hasSnapshot) {
      await ensureLoaded();
      return;
    }
    if (!_isSnapshotExpired && !_isStale) return;
    await _loadSnapshot(forceRefresh: false, silent: true);
  }

  /// Re-resolves the current location (e.g. user moved) and refetches.
  Future<void> useCurrentLocation() async {
    _activeLocation = await _repository.resolveActiveLocation(forceGps: true);
    await _loadSnapshot(forceRefresh: true, silent: hasSnapshot);
  }

  /// Switches the active location to [location] and refetches.
  Future<void> selectLocation(WeatherLocation location) async {
    _activeLocation = location;
    await _repository.selectLocation(location);
    await _repository.addSavedLocation(location);
    await _loadSnapshot(forceRefresh: true, silent: hasSnapshot);
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

  bool get _isSnapshotExpired {
    final fetchedAt = _snapshot?.fetchedAt;
    if (fetchedAt == null) return true;
    return DateTime.now().difference(fetchedAt) >=
        WeatherConstants.currentCacheTtl;
  }

  Future<void> _bootstrap() {
    return _bootstrapFuture ??= () async {
      await _hydrateFromCache();
      _bootstrapped = true;
    }();
  }

  /// Disk → memory before any GPS/network work so the dashboard card can
  /// render on the first frame after cold start.
  Future<void> _hydrateFromCache() async {
    if (hasSnapshot) return;
    try {
      final cached = await _repository.loadLastCachedSnapshot();
      if (cached == null || hasSnapshot) return;
      _snapshot = cached;
      _activeLocation = cached.location;
      _isFromCache = true;
      _isStale = DateTime.now().difference(cached.fetchedAt) >=
          WeatherConstants.currentCacheTtl;
      _error = null;
      notifyListeners();
    } catch (error, stack) {
      ErrorLogger.instance.recordNonFatal(
        error,
        stack,
        context: 'WeatherProvider._hydrateFromCache',
      );
    }
  }

  Future<void> _loadSnapshot({
    required bool forceRefresh,
    bool silent = false,
  }) async {
    if (_inFlightFetch != null && !forceRefresh) {
      await _inFlightFetch;
      return;
    }

    // Only show a loading state when we have nothing to paint. Existing
    // cached data stays on screen during background / forced refreshes.
    final showLoading = !silent && !hasSnapshot;
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

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
        _isFromCache = result.fromCache;
        _isStale = result.isStale;
        // Soft offline: keep the card, never flip to a hard retry state.
        _error = null;
      } else if (!hasSnapshot) {
        _error = result.error;
      } else {
        _isStale = true;
      }

      if (result.error != null && result.snapshot == null) {
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
      // Never wipe a usable snapshot on a transient failure.
      if (!hasSnapshot) {
        _error = error;
      } else {
        _isStale = true;
      }
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
    _autoRefreshTimer = Timer.periodic(interval, (_) => softRefresh());
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

  @visibleForTesting
  bool get debugBootstrapped => _bootstrapped;
}
