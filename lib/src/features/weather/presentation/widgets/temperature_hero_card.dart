import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_gradients.dart';
import '../utils/weather_view_mapper.dart';

/// Big "right now" card. Shows the current temperature, feels-like, the
/// weather condition icon (network when OWM key configured, Material
/// fallback otherwise), and the day's H/L.
///
/// The background gradient is computed from the condition + time-of-day
/// so the card subtly shifts colour throughout the day (sunrise → sunny
/// → overcast → night) — a delightful detail that helps the screen feel
/// premium without screaming.
class TemperatureHeroCard extends StatelessWidget {
  const TemperatureHeroCard({
    super.key,
    required this.current,
  });

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCompact = MediaQuery.of(context).size.width < 380;
    final gradient = WeatherGradients.forCurrent(current);
    final iconUrl = WeatherViewMapper.networkIconUrl(current.iconCode);
    final condition = current.conditionLabel ??
        WeatherViewMapper.localizedCondition(l10n, current.conditionCode);

    final hi = current.maxTempC ?? current.temperatureC;
    final lo = current.minTempC ?? (current.temperatureC - 5);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // ── Decorative depth blobs ──
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // ── Content ──
            Padding(
              padding: EdgeInsets.all(isCompact ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Big icon
                      _ConditionIconBubble(
                        iconUrl: iconUrl,
                        fallbackIcon: WeatherViewMapper.iconForCode(
                          current.conditionCode,
                          isNight: _isNight(current),
                        ),
                        size: isCompact ? 64 : 76,
                      ),
                      const SizedBox(width: 14),
                      // Temperature stack
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: current.temperatureC - 4,
                                end: current.temperatureC,
                              ),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      value.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: isCompact ? 60 : 72,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                        height: 1,
                                        letterSpacing: -2,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '°C',
                                        style: TextStyle(
                                          fontSize: isCompact ? 22 : 26,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              WeatherGradients.heroSubtext(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              condition,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.t('feelsLike')} '
                              '${current.apparentTemperatureC.toStringAsFixed(0)}°',
                              style: TextStyle(
                                color: WeatherGradients.heroSubtext(),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: WeatherGradients.heroSurface(),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _HiLoTile(
                          label: l10n.t('weatherHigh'),
                          value: '${hi.toStringAsFixed(0)}°',
                          icon: Icons.arrow_upward_rounded,
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                        _HiLoTile(
                          label: l10n.t('weatherLow'),
                          value: '${lo.toStringAsFixed(0)}°',
                          icon: Icons.arrow_downward_rounded,
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                        _HiLoTile(
                          label: l10n.t('rainChance'),
                          value: '${current.rainChancePercent}%',
                          icon: Icons.grain_rounded,
                        ),
                      ],
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

  bool _isNight(CurrentWeather c) {
    final now = c.observedAt ?? DateTime.now();
    if (c.sunrise != null && c.sunset != null) {
      return now.isBefore(c.sunrise!) || now.isAfter(c.sunset!);
    }
    return now.hour < 6 || now.hour >= 19;
  }
}

class _ConditionIconBubble extends StatelessWidget {
  const _ConditionIconBubble({
    required this.iconUrl,
    required this.fallbackIcon,
    required this.size,
  });

  final String? iconUrl;
  final IconData fallbackIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: WeatherGradients.heroSurface(),
        borderRadius: BorderRadius.circular(18),
      ),
      child: iconUrl == null
          ? Icon(fallbackIcon, size: size * 0.55, color: AppColors.cropYellow)
          : Padding(
              padding: const EdgeInsets.all(4),
              child: CachedNetworkImage(
                imageUrl: iconUrl!,
                fit: BoxFit.contain,
                placeholder: (_, __) => Icon(
                  fallbackIcon,
                  size: size * 0.55,
                  color: AppColors.cropYellow,
                ),
                errorWidget: (_, __, ___) => Icon(
                  fallbackIcon,
                  size: size * 0.55,
                  color: AppColors.cropYellow,
                ),
              ),
            ),
    );
  }
}

class _HiLoTile extends StatelessWidget {
  const _HiLoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Each tile is wrapped in [Expanded] by the parent Row, so it gets
    // a bounded width. We use [FittedBox] for the value row so longer
    // values ("Rain Chance 100%") scale down gracefully on narrow phones
    // (e.g. VIVO Y17) instead of overflowing.
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13, color: WeatherGradients.heroSubtext()),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: WeatherGradients.heroSubtext(),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
