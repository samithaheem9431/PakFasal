import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_view_mapper.dart';
import 'weather_glass_card.dart';

/// Apple-style multi-day forecast with temperature range bars.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.forecast,
    this.currentTempC,
  });

  final List<DailyForecast> forecast;
  final double? currentTempC;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (forecast.isEmpty) {
      return WeatherGlassCard(
        child: SizedBox(
          height: 60,
          child: Center(
            child: Text(l10n.t('loading'), style: WeatherGlassStyle.caption(context)),
          ),
        ),
      );
    }

    final days = forecast.take(10).toList();
    final allMin = days.map((d) => d.minTempC).reduce(_min);
    final allMax = days.map((d) => d.maxTempC).reduce(_max);

    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 14,
                color: WeatherGlassStyle.label(context),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.t('weather10DayTitle').toUpperCase(),
                style: WeatherGlassStyle.sectionLabel(context, size: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: WeatherGlassStyle.divider(context)),
            _DailyRow(
              forecast: days[i],
              isToday: i == 0,
              weekMin: allMin,
              weekMax: allMax,
              currentTempC: i == 0 ? currentTempC : null,
            ),
          ],
        ],
      ),
    );
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;
}

String? _localizedWeekday(AppLocalizations l10n, DateTime? date) {
  if (date == null) return null;
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
    required this.weekMin,
    required this.weekMax,
    this.currentTempC,
  });

  final DailyForecast forecast;
  final bool isToday;
  final double weekMin;
  final double weekMax;
  final double? currentTempC;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dayLabel = isToday
        ? l10n.t('weatherToday')
        : _localizedWeekday(l10n, forecast.date) ??
            forecast.dateLabel.split(',').first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              dayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: WeatherGlassStyle.value(context)),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: _DailyIcon(
              iconCode: forecast.iconCode,
              fallback: WeatherViewMapper.iconForCode(forecast.conditionCode),
            ),
          ),
          SizedBox(
            width: 40,
            child: forecast.rainChance > 0
                ? Text(
                    '${forecast.rainChance}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64B5F6),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: _TempRangeBar(
              min: forecast.minTempC,
              max: forecast.maxTempC,
              weekMin: weekMin,
              weekMax: weekMax,
              currentTempC: currentTempC,
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
      return Icon(fallback, size: 22, color: WeatherGlassStyle.icon(context));
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          Icon(fallback, size: 22, color: WeatherGlassStyle.icon(context)),
      errorWidget: (_, __, ___) =>
          Icon(fallback, size: 22, color: WeatherGlassStyle.icon(context)),
    );
  }
}

class _TempRangeBar extends StatelessWidget {
  const _TempRangeBar({
    required this.min,
    required this.max,
    required this.weekMin,
    required this.weekMax,
    this.currentTempC,
  });

  final double min;
  final double max;
  final double weekMin;
  final double weekMax;
  final double? currentTempC;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '${min.toStringAsFixed(0)}°',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: WeatherGlassStyle.label(context)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final span = (weekMax - weekMin).abs().clamp(1, 1000).toDouble();
              final leftFrac = ((min - weekMin) / span).clamp(0.0, 1.0);
              final widthFrac = ((max - min).abs() / span).clamp(0.05, 1.0);
              final barLeft = leftFrac * constraints.maxWidth;
              final barWidth = widthFrac * constraints.maxWidth;

              double? markerX;
              if (currentTempC != null) {
                final m =
                    ((currentTempC! - weekMin) / span).clamp(0.0, 1.0);
                markerX = m * constraints.maxWidth;
              }

              return SizedBox(
                height: 10,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: WeatherGlassStyle.value(context).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: barLeft,
                      child: Container(
                        width: barWidth,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF64B5F6),
                              Color(0xFFFFD54F),
                              Color(0xFFFF8A65),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    if (markerX != null)
                      Positioned(
                        left: markerX - 5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '${max.toStringAsFixed(0)}°',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: WeatherGlassStyle.value(context)),
          ),
        ),
      ],
    );
  }
}
