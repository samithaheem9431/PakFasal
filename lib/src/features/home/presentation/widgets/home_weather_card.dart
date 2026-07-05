import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../weather/domain/entities/weather_models.dart';
import '../../../weather/presentation/utils/weather_view_mapper.dart';

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

  // ── Green palette ────────────────────────────────────────────────────────
  static const _cardBg = Color(0xFF1B5E20); // deep forest green
  static const _accentGreen = Color(0xFF69F0AE); // mint accent
  static const _softWhite = Color(0xCCFFFFFF); // 80% white
  static const _dimWhite = Color(0x73FFFFFF); // 45% white for hints
  static const _divider = Color(0x1AFFFFFF); // 10% white divider
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── Decorative depth blobs ────────────────────────────────
            Positioned(
              top: -60,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentGreen.withValues(alpha: 0.07),
                ),
              ),
            ),

            // ── Main content ──────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Location row ──────────────────────────────
                      Row(
                        children: [
                          // Live/Offline indicator dot
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOffline
                                  ? const Color(0xFFFFB74D)
                                  : _accentGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    weather.locationLabel,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _softWhite,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                if (isOffline) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFB74D)
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFFB74D)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.cloud_off_rounded,
                                          size: 10,
                                          color: const Color(0xFFFFB74D),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          l10n.t('offline'),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFFFB74D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Icon(
                              WeatherViewMapper.iconForCode(
                                weather.conditionCode,
                              ),
                              color: _accentGreen,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      if (lastSyncedLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          lastSyncedLabel!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _dimWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      // ── Temperature display ───────────────────────
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: weather.temperatureC - 5,
                              end: weather.temperatureC,
                            ),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              '°C',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: _dimWhite,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Feels like subtitle ───────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          '${l10n.t('feelsLike')} ${(weather.temperatureC - 3).toStringAsFixed(0)}°  ·  ${l10n.t('updatedJustNow')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _dimWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Metric strip (icon + value + label) ───────────────
                Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: _divider)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _MetricCell(
                            icon: Icons.water_drop_outlined,
                            value: '${weather.humidity.toStringAsFixed(0)}%',
                            label: humidityLabel,
                          ),
                        ),
                        const _VerticalDivider(),
                        Expanded(
                          child: _MetricCell(
                            icon: Icons.grain,
                            value: '${weather.rainChancePercent}%',
                            label: rainChanceLabel,
                          ),
                        ),
                        const _VerticalDivider(),
                        Expanded(
                          child: _MetricCell(
                            icon: Icons.air,
                            value: '${weather.windSpeedKmh.toStringAsFixed(0)} km/h',
                            label: l10n.t('wind'),
                          ),
                        ),
                      ],
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

// ── Metric cell ────────────────────────────────────────────────────────────
class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  static const _accentGreen = Color(0xFF69F0AE);
  static const _dimWhite = Color(0x73FFFFFF);
  static const _metricBg = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon in frosted bubble
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _metricBg,
            ),
            child: Icon(icon, color: _accentGreen, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: _dimWhite,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thin vertical separator between metric cells ───────────────────────────
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: const Color(0x1AFFFFFF));
  }
}
