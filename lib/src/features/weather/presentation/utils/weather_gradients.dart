import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';

/// PakFasal weather theme — soft mint page + green accents.
class WeatherGradients {
  WeatherGradients._();

  static List<Color> forCurrent(
    CurrentWeather current, {
    bool isDark = false,
  }) {
    if (isDark) {
      return const [
        Color(0xFF0F3818),
        Color(0xFF162A1D),
        Color(0xFF102017),
      ];
    }
    return const [
      Color(0xFFF1FBF2),
      Color(0xFFE8F5E9),
      Color(0xFFF5F5F5),
    ];
  }

  static Color scaffoldFallback({required bool isDark}) =>
      isDark ? AppColors.darkSurface : AppColors.softSurfaceGreen;

  static Color heroText({required bool isDark}) => AppColors.white;

  static Color heroSubtext({required bool isDark}) =>
      AppColors.white.withValues(alpha: 0.9);

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
