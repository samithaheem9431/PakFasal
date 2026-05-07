import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/weather_models.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_view_mapper.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeatherProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<WeatherProvider>().refreshAll();
    }
  }

  Future<void> _refresh() => context.read<WeatherProvider>().refreshAll();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PakFasalScaffold(
      title: l10n.t('weather'),
      showBack: true,
      child: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _refresh,
        child: Consumer<WeatherProvider>(
          builder: (context, weather, _) {
            final current = weather.current;
            final forecast = weather.forecast;

            if (current == null && weather.isLoading) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [LoadingStateCard()],
              );
            }

            if (current == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [ErrorStateCard(onRetry: _refresh)],
              );
            }

            if (forecast.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (weather.isLoadingForecast)
                    const LoadingStateCard()
                  else
                    ErrorStateCard(onRetry: _refresh),
                ],
              );
            }

            final lastSyncAt = weather.lastSyncAt;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                _TopLocationBar(
                  locationLabel: current.locationLabel,
                  lastSyncedLabel: lastSyncAt == null
                      ? null
                      : '${l10n.t('lastUpdated')}: ${TimeOfDay.fromDateTime(lastSyncAt).format(context)}',
                ),
                const SizedBox(height: 8),
                _HeroWeatherCard(current: current, l10n: l10n),
                const SizedBox(height: 8),
                _HourlyForecastStrip(current: current, forecast: forecast),
                const SizedBox(height: 8),
                _DailyForecastStrip(forecast: forecast, l10n: l10n),
                const SizedBox(height: 8),
                _InsightTiles(
                  uvIndex: 7,
                  rainChance: current.rainChancePercent,
                  airQuality: 42,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Location Bar ────────────────────────────────────────────────────────────

class _TopLocationBar extends StatelessWidget {
  const _TopLocationBar({required this.locationLabel, this.lastSyncedLabel});

  final String locationLabel;
  final String? lastSyncedLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.overlayWhite70, size: 18),
            ],
          ),
          if (lastSyncedLabel != null) ...[
            const SizedBox(height: 3),
            Text(
              lastSyncedLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.overlayWhite70,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Hero Card ───────────────────────────────────────────────────────────────

class _HeroWeatherCard extends StatelessWidget {
  const _HeroWeatherCard({required this.current, required this.l10n});

  final CurrentWeather current;
  final AppLocalizations l10n;

  // Deep canal blue — distinct from primary green, signals "sky/weather" domain
  static const Color _heroBg = Color(0xFF1C6B9E);
  static const Color _heroSurface = Color(0x26FFFFFF); // white 15%
  static const Color _heroSubtext = Color(0x99FFFFFF); // white 60%
  static const Color _heroMuted = Color(0x66FFFFFF);   // white 40%

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    final icon = WeatherViewMapper.iconForCode(current.conditionCode);
    final condition =
        WeatherViewMapper.localizedCondition(l10n, current.conditionCode);
    final feelsLike = (current.temperatureC - 3).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: _heroBg,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: EdgeInsets.all(isCompact ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + temp + season badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather icon in frosted chip
              Container(
                width: isCompact ? 52 : 60,
                height: isCompact ? 52 : 60,
                decoration: BoxDecoration(
                  color: _heroSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: isCompact ? 30 : 36,
                  color: AppColors.cropYellow,
                ),
              ),
              const SizedBox(width: 12),
              // Temp + condition
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperatureC.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: isCompact ? 36 : 42,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.t('feelsLike')} $feelsLike°C',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _heroSubtext,
                      ),
                    ),
                  ],
                ),
              ),
              // Hi/Lo + season badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'H: ${(current.temperatureC + 3).toStringAsFixed(0)}°  '
                    'L: ${(current.temperatureC - 7).toStringAsFixed(0)}°',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _heroSubtext,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _heroSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Kharif season',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Metric chips row
          Row(
            children: [
              _MetricChip(
                icon: Icons.water_drop_outlined,
                label: l10n.t('humidity'),
                value: '${current.humidity}%',
                surface: _heroSurface,
                textColor: _heroMuted,
              ),
              const SizedBox(width: 6),
              _MetricChip(
                icon: Icons.air_rounded,
                label: l10n.t('wind'),
                value: '12 km/h',
                surface: _heroSurface,
                textColor: _heroMuted,
              ),
              const SizedBox(width: 6),
              _MetricChip(
                icon: Icons.compress_rounded,
                label: 'Pressure',
                value: '1012 hPa',
                surface: _heroSurface,
                textColor: _heroMuted,
              ),
              const SizedBox(width: 6),
              _MetricChip(
                icon: Icons.visibility_outlined,
                label: 'Visibility',
                value: '10 km',
                surface: _heroSurface,
                textColor: _heroMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.surface,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color surface;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFB5D4F4)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: textColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hourly Forecast Strip ───────────────────────────────────────────────────

class _HourlyForecastStrip extends StatelessWidget {
  const _HourlyForecastStrip({required this.current, required this.forecast});

  final CurrentWeather current;
  final List<DailyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return _StripCard(
      title: 'Hourly forecast',
      child: SizedBox(
        height: 82,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 7,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final hour = now.add(Duration(hours: index));
            final isNow = index == 0;
            final hourNum = hour.hour > 12 ? hour.hour - 12 : hour.hour;
            final amPm = hour.hour >= 12 ? 'PM' : 'AM';
            final label = isNow ? 'Now' : '$hourNum $amPm';
            final temp =
                (current.temperatureC + (index - 2) * 0.6).clamp(0, 50);

            return Column(
              children: [
                // "Now" gets a green pill, others get plain text
                isNow
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Now',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                const SizedBox(height: 5),
                Icon(
                  WeatherViewMapper.iconForCode(forecast.first.conditionCode),
                  color: AppColors.cropYellow,
                  size: 20,
                ),
                const SizedBox(height: 5),
                Text(
                  '${temp.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── 7-Day Forecast Strip ────────────────────────────────────────────────────

class _DailyForecastStrip extends StatelessWidget {
  const _DailyForecastStrip({required this.forecast, required this.l10n});

  final List<DailyForecast> forecast;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _StripCard(
      title: '7-day forecast',
      trailing: Text(
        'View all',
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      child: SizedBox(
        height: 82,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: forecast.length.clamp(0, 7),
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final day = forecast[index];
            final isToday = index == 0;
            final dayLabel =
                isToday ? 'Today' : day.dateLabel.split(',').first;

            return Column(
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: isToday
                        ? AppColors.primaryGreen
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 5),
                Icon(
                  WeatherViewMapper.iconForCode(day.conditionCode),
                  color: AppColors.cropYellow,
                  size: 20,
                ),
                const SizedBox(height: 5),
                Text(
                  '${day.maxTempC.toStringAsFixed(0)}°/${day.minTempC.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Shared Strip Card Container ─────────────────────────────────────────────

class _StripCard extends StatelessWidget {
  const _StripCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF0F5525),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Insight Tiles ───────────────────────────────────────────────────────────

class _InsightTiles extends StatelessWidget {
  const _InsightTiles({
    required this.uvIndex,
    required this.rainChance,
    required this.airQuality,
  });

  final int uvIndex;
  final int rainChance;
  final int airQuality;

  String _aqiStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    return 'Unhealthy';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tiles = [
          _InsightTile(
            title: 'UV index',
            value: '$uvIndex',
            subtitle: uvIndex > 6 ? 'High' : 'Moderate',
            backgroundColor: const Color(0xFFEBF2E0),
            valueColor: const Color(0xFF3B6D11),
            subtitleColor: const Color(0xFF3B6D11),
            icon: Icons.wb_sunny_outlined,
            iconColor: const Color(0xFF3B6D11),
          ),
          _InsightTile(
            title: 'Rain chance',
            value: '$rainChance%',
            subtitle: rainChance > 40 ? 'Likely' : 'Low',
            backgroundColor: const Color(0xFFE6F1FB),
            valueColor: const Color(0xFF185FA5),
            subtitleColor: const Color(0xFF185FA5),
            icon: Icons.grain_rounded,
            iconColor: const Color(0xFF185FA5),
          ),
          _InsightTile(
            title: 'Air quality',
            value: '$airQuality AQI',
            subtitle: _aqiStatus(airQuality),
            backgroundColor: const Color(0xFFEAF3DE),
            valueColor: const Color(0xFF3B6D11),
            subtitleColor: const Color(0xFF3B6D11),
            icon: Icons.eco_outlined,
            iconColor: const Color(0xFF3B6D11),
          ),
        ];

        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: tiles[0]),
                  const SizedBox(width: 8),
                  Expanded(child: tiles[1]),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: tiles[2]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: tiles[0]),
            const SizedBox(width: 8),
            Expanded(child: tiles[1]),
            const SizedBox(width: 8),
            Expanded(child: tiles[2]),
          ],
        );
      },
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.backgroundColor,
    required this.valueColor,
    required this.subtitleColor,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color backgroundColor;
  final Color valueColor;
  final Color subtitleColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF5a7a5a),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
