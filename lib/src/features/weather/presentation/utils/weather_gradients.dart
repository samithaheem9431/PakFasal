import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';

/// PakFasal weather theme helpers — green scaffold + photo-hero text.
class WeatherGradients {
  WeatherGradients._();

  /// Soft green wash used when a photo background is unavailable.
  static List<Color> forCurrent(
    CurrentWeather current, {
    bool isDark = false,
  }) {
    final isNight = isNightNow(current);
    if (isDark || isNight) {
      return const [
        Color(0xFF0F3818),
        Color(0xFF162A1D),
        Color(0xFF102017),
      ];
    }
    return const [
      Color(0xFF1B5E20),
      Color(0xFF0F3818),
      Color(0xFF102017),
    ];
  }

  static Color scaffoldFallback({required bool isDark}) =>
      isDark ? AppColors.darkSurface : AppColors.darkGreen;

  /// White hero text over the photo + green overlay.
  static Color heroText({required bool isDark}) => AppColors.white;

  static Color heroSubtext({required bool isDark}) =>
      AppColors.white.withValues(alpha: 0.88);

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
