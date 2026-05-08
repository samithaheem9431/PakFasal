import 'package:flutter/material.dart';

import '../../domain/entities/weather_models.dart';

/// Returns a tasteful background gradient for the hero card based on the
/// current weather condition + time of day.
///
/// We deliberately pick muted, agriculture-friendly tones (deep canal blue,
/// soft sunset amber, overcast slate) rather than saturated weather-app
/// gradients — the rest of the app uses a green palette and we want the
/// weather screen to feel premium without screaming.
class WeatherGradients {
  WeatherGradients._();

  static List<Color> forCurrent(CurrentWeather current) {
    final code = current.conditionCode;
    final isNight = _isNight(current);

    // Thunderstorm / storm — moody indigo
    if (code >= 95) {
      return const [Color(0xFF1E2A47), Color(0xFF3D4E73)];
    }
    // Snow — frosted blue
    if (code >= 71 && code <= 86) {
      return const [Color(0xFF6A8FB1), Color(0xFFB7D2E6)];
    }
    // Rain / showers — overcast slate-blue
    if (code >= 51 && code <= 82) {
      return const [Color(0xFF2C5E7C), Color(0xFF4F86A8)];
    }
    // Fog / mist
    if (code == 45 || code == 48) {
      return const [Color(0xFF6E7A82), Color(0xFFA8B2B8)];
    }
    // Cloudy
    if (code >= 2 && code <= 3) {
      return isNight
          ? const [Color(0xFF2A3850), Color(0xFF455A78)]
          : const [Color(0xFF4A6B85), Color(0xFF7FA0BA)];
    }
    // Clear / partly cloudy
    if (isNight) {
      return const [Color(0xFF1B2A4E), Color(0xFF34487A)];
    }
    // Default sunny — deep canal blue (matches PakFasal "sky" identity)
    return const [Color(0xFF1C6B9E), Color(0xFF3A8DB8)];
  }

  /// Soft surface accent matching the hero gradient (used by chips / chips
  /// on the hero card).
  static Color heroSurface() => const Color(0x26FFFFFF);
  static Color heroSubtext() => const Color(0x99FFFFFF);
  static Color heroMuted() => const Color(0x66FFFFFF);

  static bool _isNight(CurrentWeather c) {
    final now = c.observedAt ?? DateTime.now();
    final sunrise = c.sunrise;
    final sunset = c.sunset;
    if (sunrise != null && sunset != null) {
      return now.isBefore(sunrise) || now.isAfter(sunset);
    }
    final hour = now.hour;
    return hour < 6 || hour >= 19;
  }
}
