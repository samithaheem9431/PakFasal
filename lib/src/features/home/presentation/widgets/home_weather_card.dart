import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../weather/domain/entities/weather_models.dart';

class HomeWeatherCard extends StatelessWidget {
  const HomeWeatherCard({
    super.key,
    required this.weather,
    required this.temperatureLabel,
    required this.humidityLabel,
    required this.rainChanceLabel,
    this.lastSyncedLabel,
    this.isOffline = false,
  });

  final CurrentWeather weather;
  final String temperatureLabel;
  final String humidityLabel;
  final String rainChanceLabel;
  final String? lastSyncedLabel;
  final bool isOffline;

  static const _radius = 22.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feelsLike = (weather.temperatureC - 3).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColors.primaryGreen : Colors.white;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius - 1.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/dashboard/weather_bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x4D000000),
                      Color(0x1A000000),
                      Color(0x00000000),
                    ],
                    stops: [0.0, 0.45, 0.75],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              weather.locationLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (lastSyncedLabel != null) ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            lastSyncedLabel!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: weather.temperatureC - 5,
                          end: weather.temperatureC,
                        ),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: value.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 56,
                                    fontWeight: FontWeight.w800,
                                    height: 0.95,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                const TextSpan(
                                  text: '°C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.t('feelsLike')} $feelsLike°',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                        child: Row(
                          children: [
                            _MetricColumn(
                              icon: Icons.water_drop_outlined,
                              value: '${weather.humidity.toStringAsFixed(0)}%',
                              label: humidityLabel,
                            ),
                            Container(
                              width: 1,
                              height: 42,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            _MetricColumn(
                              icon: Icons.cloudy_snowing,
                              value: '${weather.rainChancePercent}%',
                              label: rainChanceLabel,
                            ),
                            Container(
                              width: 1,
                              height: 42,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            _MetricColumn(
                              icon: Icons.air,
                              value:
                                  '${weather.windSpeedKmh.toStringAsFixed(0)} km/h',
                              label: l10n.t('wind'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
