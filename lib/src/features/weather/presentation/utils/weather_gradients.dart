import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';

/// Sky / hero gradients — bright sky-blue in light, deep blue-green in dark.
class WeatherGradients {
  WeatherGradients._();

  static List<Color> forCurrent(
    CurrentWeather current, {
    bool isDark = false,
  }) {
    final code = current.conditionCode;
    final isNight = isNightNow(current);
    // Same deep blue sky in light + dark (user preference).
    return _blueSky(code, isNight);
  }

  static List<Color> _blueSky(int code, bool isNight) {
    if (code >= 95) {
      return const [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF102017)];
    }
    if (code >= 71 && code <= 86) {
      return const [Color(0xFF263238), Color(0xFF37474F), Color(0xFF102017)];
    }
    if (code >= 51 && code <= 82) {
      return const [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF0F3818)];
    }
    if (code == 45 || code == 48) {
      return const [Color(0xFF37474F), Color(0xFF455A64), Color(0xFF102017)];
    }
    if (code >= 2 && code <= 3) {
      return const [Color(0xFF1B3A4B), Color(0xFF24556A), Color(0xFF102017)];
    }
    if (isNight) {
      return const [Color(0xFF0D47A1), Color(0xFF0F3818), Color(0xFF102017)];
    }
    return const [
      Color(0xFF1565C0),
      Color(0xFF0D47A1),
      Color(0xFF0F3818),
    ];
  }

  static Color scaffoldFallback({required bool isDark}) =>
      const Color(0xFF0D47A1);

  /// White hero text — sky is deep blue in both themes.
  static Color heroText({required bool isDark}) => AppColors.white;

  static Color heroSubtext({required bool isDark}) =>
      AppColors.white.withValues(alpha: 0.85);

  static bool isNightNow(CurrentWeather c) {
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
