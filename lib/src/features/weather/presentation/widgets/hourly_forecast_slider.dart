import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_view_mapper.dart';
import 'weather_glass_card.dart';

/// Hourly strip with summary header.
class HourlyForecastSlider extends StatelessWidget {
  const HourlyForecastSlider({
    super.key,
    required this.hourly,
    this.summary,
  });

  final List<HourlyForecastPoint> hourly;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (hourly.isEmpty) {
      return WeatherGlassCard(
        child: SizedBox(
          height: 60,
          child: Center(
            child: Text(
              l10n.t('loading'),
              style: WeatherGlassStyle.caption(context),
            ),
          ),
        ),
      );
    }

    final items = hourly.take(12).toList();
    final summaryText = summary ?? _defaultSummary(l10n, items.first);

    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: WeatherGlassStyle.icon(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WeatherGlassStyle.body(context, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: WeatherGlassStyle.divider(context)),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => VerticalDivider(
                width: 20,
                thickness: 1,
                indent: 8,
                endIndent: 8,
                color: WeatherGlassStyle.divider(context),
              ),
              itemBuilder: (context, index) {
                final point = items[index];
                final isNow = index == 0;
                return _HourlyColumn(
                  label: isNow ? l10n.t('weatherNow') : point.timeLabel,
                  tempC: point.temperatureC,
                  isNow: isNow,
                  iconCode: point.iconCode,
                  fallbackIcon:
                      WeatherViewMapper.iconForCode(point.conditionCode),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _defaultSummary(AppLocalizations l10n, HourlyForecastPoint first) {
    final condition = WeatherViewMapper.localizedCondition(
      l10n,
      first.conditionCode,
    );
    final wind = first.windSpeedKmh;
    if (wind != null && wind > 0) {
      return '$condition. ${l10n.t('wind')} '
          '${wind.toStringAsFixed(0)} ${l10n.t('kmh')}.';
    }
    return condition;
  }
}

class _HourlyColumn extends StatelessWidget {
  const _HourlyColumn({
    required this.label,
    required this.tempC,
    required this.isNow,
    required this.iconCode,
    required this.fallbackIcon,
  });

  final String label;
  final double tempC;
  final bool isNow;
  final String? iconCode;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final valueColor = WeatherGlassStyle.value(context);
    return SizedBox(
      width: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              color: valueColor,
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: _IconOrFallback(
              iconCode: iconCode,
              fallbackIcon: fallbackIcon,
            ),
          ),
          Text(
            '${tempC.toStringAsFixed(0)}°',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconOrFallback extends StatelessWidget {
  const _IconOrFallback({
    required this.iconCode,
    required this.fallbackIcon,
  });

  final String? iconCode;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final tint = WeatherGlassStyle.icon(context);
    final url = WeatherViewMapper.networkIconUrl(iconCode);
    if (url == null) {
      return Icon(fallbackIcon, size: 24, color: tint);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) => Icon(fallbackIcon, size: 24, color: tint),
      errorWidget: (_, __, ___) => Icon(fallbackIcon, size: 24, color: tint),
    );
  }
}
