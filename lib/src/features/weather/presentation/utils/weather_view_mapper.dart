import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../constants/weather_constants.dart';

/// Maps weather codes/icon codes to view-layer data (icons, labels, colors).
///
/// The internal code-space loosely mirrors WMO weather codes used by
/// Open-Meteo (clear=0, cloudy<=3, drizzle/rain<=67, snow<=77,
/// showers=80..82, thunderstorm>=95). The OpenWeatherMap service maps
/// its own ids into this same space (see [WeatherApiService]) so all
/// downstream UI can use a single mapper.
class WeatherViewMapper {
  WeatherViewMapper._();

  // ── Icon lookup ────────────────────────────────────────────────────────

  /// Returns a Material icon best matching [code]. Used as a non-network
  /// fallback (and in dense lists where loading network icons is overkill).
  static IconData iconForCode(int code, {bool isNight = false}) {
    if (code == 0) return isNight ? Icons.nightlight_round : Icons.wb_sunny;
    if (code == 1) return isNight ? Icons.nights_stay : Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code == 51 || code == 53 || code == 55) return Icons.grain;
    if (code == 56 || code == 57) return Icons.ac_unit;
    if (code == 61 || code == 63 || code == 65) return Icons.umbrella;
    if (code == 66 || code == 67) return Icons.ac_unit;
    if (code == 71 || code == 73 || code == 75 || code == 77) {
      return Icons.ac_unit;
    }
    if (code == 80 || code == 81 || code == 82) return Icons.shower;
    if (code == 85 || code == 86) return Icons.snowing;
    return Icons.thunderstorm;
  }

  /// Returns the URL of the OpenWeatherMap icon asset for [iconCode]
  /// (e.g. "10d"). Returns null when [iconCode] is null/empty so callers
  /// can fall back to [iconForCode].
  static String? networkIconUrl(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) return null;
    return '${WeatherConstants.owmIconUrlPrefix}$iconCode@4x.png';
  }

  // ── Localized labels ───────────────────────────────────────────────────

  static String localizedCondition(AppLocalizations l10n, int code) {
    if (code == 0 || code == 1) return l10n.t('weatherClear');
    if (code <= 3) return l10n.t('weatherCloudy');
    if (code == 45 || code == 48) return l10n.t('weatherCloudy');
    if (code <= 67) return l10n.t('weatherRain');
    if (code <= 77) return l10n.t('weatherSnow');
    if (code <= 82) return l10n.t('weatherRain');
    if (code <= 86) return l10n.t('weatherSnow');
    if (code <= 99) return l10n.t('weatherStorm');
    return l10n.t('weatherGeneral');
  }

  /// Bucket-text for a UV index value (Low / Moderate / High / Very high /
  /// Extreme), localized.
  static String localizedUvLabel(AppLocalizations l10n, double uv) {
    if (uv < 3) return l10n.t('weatherUVLow');
    if (uv < 6) return l10n.t('weatherUVModerate');
    if (uv < 8) return l10n.t('weatherUVHigh');
    if (uv < 11) return l10n.t('weatherUVVeryHigh');
    return l10n.t('weatherUVExtreme');
  }

  /// Bucket-text for a US-AQI value (Good / Moderate / Unhealthy …),
  /// localized to the existing l10n keys (`good`, `moderate`, `bad`).
  static String localizedAqiLabel(AppLocalizations l10n, int aqi) {
    if (aqi <= 50) return l10n.t('good');
    if (aqi <= 100) return l10n.t('moderate');
    return l10n.t('bad');
  }
}
