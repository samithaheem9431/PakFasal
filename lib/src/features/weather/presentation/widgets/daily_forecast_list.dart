import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_view_mapper.dart';
import 'section_card.dart';

/// 7-day forecast vertical list. Each row is a card with the day, weather
/// icon, rain probability, and a small Hi/Lo bar that visualizes the day's
/// temperature range relative to the week's overall range.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({super.key, required this.forecast});

  final List<DailyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (forecast.isEmpty) {
      return SectionCard(
        title: l10n.t('weather7DayTitle'),
        icon: Icons.date_range_rounded,
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

    final allMin = forecast.map((d) => d.minTempC).reduce(_min);
    final allMax = forecast.map((d) => d.maxTempC).reduce(_max);

    return SectionCard(
      title: l10n.t('weather7DayTitle'),
      icon: Icons.date_range_rounded,
      child: Column(
        children: [
          for (var i = 0; i < forecast.length.clamp(0, 7); i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: _DailyRow(
                forecast: forecast[i],
                isToday: i == 0,
                isTomorrow: i == 1,
                weekMin: allMin,
                weekMax: allMax,
              ),
            ),
        ],
      ),
    );
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;
}

String? _localizedWeekday(AppLocalizations l10n, DateTime? date) {
  if (date == null) return null;
  // DateTime.weekday: 1 = Mon ... 7 = Sun
  const keys = [
    'dowMon',
    'dowTue',
    'dowWed',
    'dowThu',
    'dowFri',
    'dowSat',
    'dowSun',
  ];
  final idx = (date.weekday - 1).clamp(0, 6);
  return l10n.t(keys[idx]);
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({
    required this.forecast,
    required this.isToday,
    required this.isTomorrow,
    required this.weekMin,
    required this.weekMax,
  });

  final DailyForecast forecast;
  final bool isToday;
  final bool isTomorrow;
  final double weekMin;
  final double weekMax;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dayLabel = isToday
        ? l10n.t('weatherToday')
        : isTomorrow
            ? l10n.t('weatherTomorrow')
            : _localizedWeekday(l10n, forecast.date) ??
                forecast.dateLabel.split(',').first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          // Day label — clip with ellipsis on long Urdu labels.
          SizedBox(
            width: 60,
            child: Text(
              dayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday ? AppColors.primaryGreen : scheme.onSurface,
              ),
            ),
          ),
          // Icon
          SizedBox(
            width: 36,
            height: 36,
            child: _DailyIcon(
              iconCode: forecast.iconCode,
              fallback: WeatherViewMapper.iconForCode(forecast.conditionCode),
            ),
          ),
          const SizedBox(width: 6),
          // Rain probability — use FittedBox so "100%" never overflows.
          SizedBox(
            width: 46,
            child: forecast.rainChance > 0
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grain,
                          size: 13,
                          color: AppColors.weatherBlue,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${forecast.rainChance}%',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.weatherBlue,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 6),
          // Temperature range bar
          Expanded(
            child: _TempRangeBar(
              min: forecast.minTempC,
              max: forecast.maxTempC,
              weekMin: weekMin,
              weekMax: weekMax,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyIcon extends StatelessWidget {
  const _DailyIcon({required this.iconCode, required this.fallback});

  final String? iconCode;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    final url = WeatherViewMapper.networkIconUrl(iconCode);
    if (url == null) {
      return Icon(fallback, size: 22, color: AppColors.cropYellow);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          Icon(fallback, size: 22, color: AppColors.cropYellow),
      errorWidget: (_, __, ___) =>
          Icon(fallback, size: 22, color: AppColors.cropYellow),
    );
  }
}

/// Mini bar that shows where today's min/max sits within the week's range,
/// styled like Apple Weather's daily list.
class _TempRangeBar extends StatelessWidget {
  const _TempRangeBar({
    required this.min,
    required this.max,
    required this.weekMin,
    required this.weekMax,
  });

  final double min;
  final double max;
  final double weekMin;
  final double weekMax;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '${min.toStringAsFixed(0)}°',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final span = (weekMax - weekMin).abs().clamp(1, 1000).toDouble();
              final leftFrac = ((min - weekMin) / span).clamp(0.0, 1.0);
              final widthFrac =
                  ((max - min).abs() / span).clamp(0.05, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Positioned(
                    left: leftFrac * constraints.maxWidth,
                    top: 0,
                    child: Container(
                      width: widthFrac * constraints.maxWidth,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.weatherBlue,
                            AppColors.cropYellow,
                            Color(0xFFEF5350),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: Text(
            '${max.toStringAsFixed(0)}°',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
