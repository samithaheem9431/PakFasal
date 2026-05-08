import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_view_mapper.dart';
import 'section_card.dart';

/// 2-column grid summarising the day's headline metrics (humidity, wind,
/// UV, pressure, visibility). Each tile is a self-contained card so the
/// grid degrades gracefully on narrow phones (single column).
class WeatherHighlightsGrid extends StatelessWidget {
  const WeatherHighlightsGrid({super.key, required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tiles = <Widget>[
      _MetricTile(
        icon: Icons.water_drop_outlined,
        accent: AppColors.weatherBlue,
        label: l10n.t('humidity'),
        value: '${current.humidity}%',
        subtitle: _humidityComfort(current.humidity, l10n),
      ),
      _MetricTile(
        icon: Icons.air_rounded,
        accent: const Color(0xFF26A69A),
        label: l10n.t('wind'),
        value: '${current.windSpeedKmh.toStringAsFixed(0)} ${l10n.t('kmh')}',
        subtitle: _windCardinal(current.windDirectionDeg),
      ),
      _MetricTile(
        icon: Icons.wb_sunny_outlined,
        accent: const Color(0xFFFFA726),
        label: l10n.t('weatherUVIndex'),
        value: current.uvIndex.toStringAsFixed(1),
        subtitle: WeatherViewMapper.localizedUvLabel(l10n, current.uvIndex),
      ),
      _MetricTile(
        icon: Icons.compress_rounded,
        accent: const Color(0xFF7E57C2),
        label: l10n.t('weatherPressure'),
        value: '${current.pressureHpa} ${l10n.t('hpa')}',
      ),
      _MetricTile(
        icon: Icons.visibility_outlined,
        accent: const Color(0xFF42A5F5),
        label: l10n.t('weatherVisibility'),
        value:
            '${current.visibilityKm.toStringAsFixed(1)} ${l10n.t('km')}',
      ),
      _MetricTile(
        icon: Icons.eco_outlined,
        accent: AppColors.success,
        label: l10n.t('weatherAirQuality'),
        value: current.airQualityIndex == 0
            ? '—'
            : '${current.airQualityIndex} AQI',
        subtitle: current.airQualityIndex == 0
            ? null
            : WeatherViewMapper.localizedAqiLabel(
                l10n,
                current.airQualityIndex,
              ),
      ),
    ];

    return SectionCard(
      title: l10n.t('weatherHighlights'),
      icon: Icons.insights_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          final columns = isNarrow ? 1 : 2;
          return GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 90,
            ),
            itemBuilder: (_, i) => tiles[i],
          );
        },
      ),
    );
  }

  String _humidityComfort(int h, AppLocalizations l10n) {
    if (h < 30) return l10n.t('weatherUVLow');
    if (h < 60) return l10n.t('good');
    if (h < 80) return l10n.t('moderate');
    return l10n.t('weatherUVVeryHigh');
  }

  String? _windCardinal(int? deg) {
    if (deg == null) return null;
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final i = ((deg % 360) / 45).round() % 8;
    return dirs[i];
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
