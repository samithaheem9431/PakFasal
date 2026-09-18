import 'package:flutter/material.dart';

import '../../domain/entities/weather_models.dart';
import '../utils/weather_gradients.dart';

/// Full-bleed sky behind the weather scroll (theme-aware).
class WeatherSkyBackground extends StatelessWidget {
  const WeatherSkyBackground({
    super.key,
    required this.current,
  });

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = WeatherGradients.forCurrent(current, isDark: isDark);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.length >= 3
              ? colors
              : [
                  colors.first,
                  Color.lerp(colors.first, colors.last, 0.5) ?? colors.last,
                  colors.last,
                ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
