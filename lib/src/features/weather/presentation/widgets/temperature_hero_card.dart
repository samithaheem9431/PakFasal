import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_gradients.dart';
import '../utils/weather_view_mapper.dart';

/// Apple Weather–style hero — black in light mode, white in dark mode.
class TemperatureHeroCard extends StatelessWidget {
  const TemperatureHeroCard({
    super.key,
    required this.current,
    this.collapseProgress = 0,
    this.isMyLocation = true,
  });

  final CurrentWeather current;
  final double collapseProgress;
  final bool isMyLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final condition = current.conditionLabel ??
        WeatherViewMapper.localizedCondition(l10n, current.conditionCode);
    final hi = current.maxTempC ?? current.temperatureC;
    final lo = current.minTempC ?? (current.temperatureC - 5);
    final temp = current.temperatureC.toStringAsFixed(0);
    final compact = collapseProgress >= 0.45;
    final text = WeatherGradients.heroText(isDark: isDark);
    final sub = WeatherGradients.heroSubtext(isDark: isDark);

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: compact
          ? _CompactHero(
              locationLabel: current.locationLabel,
              temp: temp,
              condition: condition,
              textColor: text,
            )
          : _ExpandedHero(
              isMyLocation: isMyLocation,
              myLocationLabel: l10n.t('myLocation').toUpperCase(),
              locationLabel: current.locationLabel,
              temp: temp,
              condition: condition,
              hiLo:
                  'H:${hi.toStringAsFixed(0)}°  L:${lo.toStringAsFixed(0)}°',
              textColor: text,
              subColor: sub,
            ),
    );
  }
}

class _ExpandedHero extends StatelessWidget {
  const _ExpandedHero({
    required this.isMyLocation,
    required this.myLocationLabel,
    required this.locationLabel,
    required this.temp,
    required this.condition,
    required this.hiLo,
    required this.textColor,
    required this.subColor,
  });

  final bool isMyLocation;
  final String myLocationLabel;
  final String locationLabel;
  final String temp;
  final String condition;
  final String hiLo;
  final Color textColor;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMyLocation)
          Text(
            myLocationLabel,
            style: TextStyle(
              color: subColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        Text(
          locationLabel,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 34,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$temp°',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w200,
            fontSize: 92,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          condition,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hiLo,
          style: TextStyle(
            color: subColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _CompactHero extends StatelessWidget {
  const _CompactHero({
    required this.locationLabel,
    required this.temp,
    required this.condition,
    required this.textColor,
  });

  final String locationLabel;
  final String temp;
  final String condition;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locationLabel,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$temp° | $condition',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
