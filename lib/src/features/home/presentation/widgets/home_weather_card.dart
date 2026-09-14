import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';
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
  static const _dayBg = 'assets/images/dashboard/weather_bg.jpg';
  static const _nightBg = 'assets/images/dashboard/weather_bg_night.jpg';

  bool get _isNight {
    final now = DateTime.now();
    final sunrise = weather.sunrise;
    final sunset = weather.sunset;
    if (sunrise != null && sunset != null) {
      return now.isBefore(sunrise) || now.isAfter(sunset);
    }
    final hour = now.hour;
    return hour < 6 || hour >= 19;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feelsLike = (weather.temperatureC - 3).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.primaryGreen : Colors.white;
    final bgAsset = _isNight ? _nightBg : _dayBg;
    final tempSize = context.scaleFont(56, min: 0.78, max: 1.15);
    final unitSize = context.scaleFont(24, min: 0.85, max: 1.1);
    final isNarrow = context.screenWidth < 360;
    final contentPad = isNarrow ? 14.0 : 18.0;

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
                bgAsset,
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
                  padding: EdgeInsets.fromLTRB(
                    contentPad,
                    contentPad,
                    contentPad,
                    14,
                  ),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.scaleFont(14),
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
                      SizedBox(height: isNarrow ? 12 : 18),
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: tempSize,
                                    fontWeight: FontWeight.w800,
                                    height: 0.95,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: '°C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: unitSize,
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
                          fontSize: context.scaleFont(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isNarrow ? 8 : 10,
                    0,
                    isNarrow ? 8 : 10,
                    12,
                  ),
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
                              compact: isNarrow,
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
                              compact: isNarrow,
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
                              compact: isNarrow,
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
    this.compact = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: compact ? 18 : 20),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 13 : 15,
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
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
