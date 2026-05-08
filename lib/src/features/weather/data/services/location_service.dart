import 'package:geolocator/geolocator.dart';

/// Result of a "where am I?" call, plus enough context for the UI to show
/// a friendly remediation prompt when something is off.
class LocationResult {
  const LocationResult({this.position, this.error, this.openSettings = false});

  final Position? position;
  final LocationServiceError? error;

  /// True when the UI should show an "Open settings" button (e.g. the user
  /// permanently denied permission).
  final bool openSettings;

  bool get isSuccess => position != null && error == null;
}

/// Reasons GPS can fail. The UI uses these to decide which localized
/// error message + remediation action to show.
enum LocationServiceError {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

/// Thin wrapper around [Geolocator]. Lives in the data layer so the
/// repository (and tests) can swap it for a fake without touching the
/// platform plugin.
class LocationService {
  const LocationService();

  /// Default timeout for a fresh GPS fix.
  static const Duration _fixTimeout = Duration(seconds: 12);

  /// Resolves the device's current coordinates with sensible defaults.
  ///
  /// Returns a [LocationResult] either way — callers should branch on
  /// [LocationResult.isSuccess] rather than expecting an exception. This
  /// lets the UI render an actionable empty-state instead of a crash.
  Future<LocationResult> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          error: LocationServiceError.serviceDisabled,
          openSettings: true,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          error: LocationServiceError.permissionDeniedForever,
          openSettings: true,
        );
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(
          error: LocationServiceError.permissionDenied,
        );
      }

      // Try to use the cached last-known position first for an instant
      // first paint, then always refresh so subsequent reads are fresh.
      final last = await Geolocator.getLastKnownPosition();
      try {
        final fresh = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: _fixTimeout,
          ),
        );
        return LocationResult(position: fresh);
      } catch (_) {
        if (last != null) return LocationResult(position: last);
        return const LocationResult(error: LocationServiceError.timeout);
      }
    } catch (_) {
      return const LocationResult(error: LocationServiceError.unknown);
    }
  }

  /// Opens the device location settings screen.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Opens the per-app permission settings screen.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
