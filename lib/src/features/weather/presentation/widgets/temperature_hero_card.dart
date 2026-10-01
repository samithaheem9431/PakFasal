import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_gradients.dart';
import '../utils/weather_view_mapper.dart';

/// Photo hero card matching the PakFasal weather dashboard reference.
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

  static const _dayBg = 'assets/images/dashboard/weather_bg.jpg';
  static const _nightBg = 'assets/images/dashboard/weather_bg_night.jpg';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final condition = current.conditionLabel ??
        WeatherViewMapper.localizedCondition(l10n, current.conditionCode);
    final hi = current.maxTempC ?? current.temperatureC;
    final lo = current.minTempC ?? (current.temperatureC - 5);
    final temp = current.temperatureC.toStringAsFixed(0);
    final isNight = WeatherGradients.isNightNow(current);
    final icon = WeatherViewMapper.iconForCode(current.conditionCode);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        (MediaQuery.sizeOf(context).width * dpr).round().clamp(400, 1200);

    return Container(
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              isNight ? _nightBg : _dayBg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              cacheWidth: cacheWidth,
              filterQuality: FilterQuality.medium,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0x99000000),
                    Color(0x40000000),
                    Color(0x14000000),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          current.locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _ConditionGlyph(icon: icon, isNight: isNight),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '$temp°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      height: 0.95,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    condition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'H:${hi.toStringAsFixed(0)}°  L:${lo.toStringAsFixed(0)}°',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionGlyph extends StatelessWidget {
  const _ConditionGlyph({required this.icon, required this.isNight});

  final IconData icon;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    final color = isNight ? const Color(0xFFE0E0E0) : const Color(0xFFFFC107);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
