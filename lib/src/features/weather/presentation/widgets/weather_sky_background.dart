import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_gradients.dart';

/// Full-bleed day/night weather photo with a soft green readability wash.
class WeatherSkyBackground extends StatelessWidget {
  const WeatherSkyBackground({
    super.key,
    required this.current,
  });

  final CurrentWeather current;

  static const _dayBg = 'assets/images/dashboard/weather_bg.jpg';
  static const _nightBg = 'assets/images/dashboard/weather_bg_night.jpg';

  @override
  Widget build(BuildContext context) {
    final isNight = WeatherGradients.isNightNow(current);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        (MediaQuery.sizeOf(context).width * dpr).round().clamp(480, 1600);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          isNight ? _nightBg : _dayBg,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          cacheWidth: cacheWidth,
          filterQuality: FilterQuality.medium,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isNight || isDark
                  ? [
                      AppColors.darkGreen.withValues(alpha: 0.55),
                      AppColors.darkSurface.withValues(alpha: 0.72),
                      AppColors.darkSurface.withValues(alpha: 0.88),
                    ]
                  : [
                      AppColors.primaryGreen.withValues(alpha: 0.28),
                      AppColors.darkGreen.withValues(alpha: 0.45),
                      const Color(0xFF0A1F10).withValues(alpha: 0.78),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}
