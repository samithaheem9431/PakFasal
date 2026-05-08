import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_view_mapper.dart';
import 'section_card.dart';

/// Horizontal slider of hourly forecast pills. Highlights "Now" with a
/// filled green pill so the current hour is visually anchored.
class HourlyForecastSlider extends StatelessWidget {
  const HourlyForecastSlider({super.key, required this.hourly});

  final List<HourlyForecastPoint> hourly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (hourly.isEmpty) {
      return SectionCard(
        title: l10n.t('weatherHourlyTitle'),
        child: SizedBox(
          height: 60,
          child: Center(
            child: Text(
              l10n.t('loading'),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final items = hourly.take(12).toList();

    return SectionCard(
      title: l10n.t('weatherHourlyTitle'),
      child: SizedBox(
        height: 118,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final point = items[index];
            final isNow = index == 0;
            return _HourlyPill(
              label: isNow ? l10n.t('weatherNow') : point.timeLabel,
              tempC: point.temperatureC,
              isNow: isNow,
              iconCode: point.iconCode,
              fallbackIcon:
                  WeatherViewMapper.iconForCode(point.conditionCode),
              rainProbability: point.rainProbabilityPercent,
            );
          },
        ),
      ),
    );
  }
}

class _HourlyPill extends StatelessWidget {
  const _HourlyPill({
    required this.label,
    required this.tempC,
    required this.isNow,
    required this.iconCode,
    required this.fallbackIcon,
    required this.rainProbability,
  });

  final String label;
  final double tempC;
  final bool isNow;
  final String? iconCode;
  final IconData fallbackIcon;
  final int? rainProbability;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isNow
            ? AppColors.primaryGreen
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isNow
              ? AppColors.primaryGreen
              : AppColors.primaryGreen.withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: isNow
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isNow ? AppColors.white : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 32,
            height: 32,
            child: _IconOrFallback(
              iconCode: iconCode,
              fallbackIcon: fallbackIcon,
              tint: isNow ? AppColors.cropYellow : AppColors.cropYellow,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${tempC.toStringAsFixed(0)}°',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isNow ? AppColors.white : scheme.onSurface,
            ),
          ),
          if (rainProbability != null && rainProbability! > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grain,
                  size: 10,
                  color: isNow
                      ? AppColors.white.withValues(alpha: 0.85)
                      : AppColors.weatherBlue,
                ),
                const SizedBox(width: 2),
                Text(
                  '$rainProbability%',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isNow
                        ? AppColors.white.withValues(alpha: 0.85)
                        : AppColors.weatherBlue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IconOrFallback extends StatelessWidget {
  const _IconOrFallback({
    required this.iconCode,
    required this.fallbackIcon,
    required this.tint,
  });

  final String? iconCode;
  final IconData fallbackIcon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final url = WeatherViewMapper.networkIconUrl(iconCode);
    if (url == null) {
      return Icon(fallbackIcon, size: 22, color: tint);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) => Icon(fallbackIcon, size: 22, color: tint),
      errorWidget: (_, __, ___) => Icon(fallbackIcon, size: 22, color: tint),
    );
  }
}
