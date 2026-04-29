import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/weather_repository.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_view_mapper.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with WidgetsBindingObserver {
  final WeatherRepository _repository = WeatherRepository();
  late Future<_WeatherScreenData> _screenFuture;
  Timer? _autoRefreshTimer;
  DateTime? _lastWeatherSyncAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screenFuture = _loadData();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      if (!mounted) return;
      _refreshForecast();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshForecast();
    }
  }

  Future<void> _refreshForecast() async {
    final refreshed = _loadData(forceRefresh: true);
    setState(() => _screenFuture = refreshed);
    await refreshed;
  }

  Future<_WeatherScreenData> _loadData({bool forceRefresh = false}) async {
    final currentFuture = _repository.fetchCurrentWeather(
      forceRefresh: forceRefresh,
    );
    final forecastFuture = _repository.fetchSevenDayForecast(
      forceRefresh: forceRefresh,
    );
    final results = await Future.wait<dynamic>([currentFuture, forecastFuture]);
    if (mounted) {
      setState(() => _lastWeatherSyncAt = DateTime.now());
    } else {
      _lastWeatherSyncAt = DateTime.now();
    }
    return _WeatherScreenData(
      current: results[0] as CurrentWeather,
      forecast: results[1] as List<DailyForecast>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PakFasalScaffold(
      title: l10n.t('weather'),
      showBack: true,
      child: RefreshIndicator(
        onRefresh: _refreshForecast,
        child: FutureBuilder<_WeatherScreenData>(
          future: _screenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [LoadingStateCard()],
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [ErrorStateCard(onRetry: _refreshForecast)],
              );
            }

            final current = snapshot.data!.current;
            final forecast = snapshot.data!.forecast;
            if (forecast.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [ErrorStateCard(onRetry: _refreshForecast)],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                10,
                8,
                10,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                _TopLocationBar(
                  locationLabel: current.locationLabel,
                  lastSyncedLabel: _lastWeatherSyncAt == null
                      ? null
                      : '${l10n.t('lastUpdated')}: ${TimeOfDay.fromDateTime(_lastWeatherSyncAt!).format(context)}',
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

class _TopLocationBar extends StatelessWidget {
  const _TopLocationBar({required this.locationLabel, this.lastSyncedLabel});

  final String locationLabel;
  final String? lastSyncedLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              locationLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            lastSyncedLabel ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.refresh, color: Colors.white, size: 14),
        ],
      ),
    );
  }
}

class _HeroWeatherCard extends StatelessWidget {
  const _HeroWeatherCard({required this.current, required this.l10n});

  final CurrentWeather current;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 380;
    final icon = WeatherViewMapper.iconForCode(current.conditionCode);
    final condition = WeatherViewMapper.localizedCondition(
      l10n,
      current.conditionCode,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFCFEAFF), Color(0xFFA8D4F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: isCompact ? 48 : 56,
              color: const Color(0xFFFFC107),
            ),
            SizedBox(width: isCompact ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperatureC.toStringAsFixed(0)}°C',
                    style: TextStyle(
                      fontSize: isCompact ? 38 : 44,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF133A57),
                      height: 1,
                    ),
                  ),
                  Text(
                    condition,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${l10n.t('feelsLike')} ${(current.temperatureC - 3).toStringAsFixed(0)}°C',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SideMetric(
                  icon: Icons.water_drop_outlined,
                  label: l10n.t('humidity'),
                  value: '${current.humidity}%',
                ),
                _SideMetric(
                  icon: Icons.air,
                  label: l10n.t('wind'),
                  value: '12 km/h',
                ),
                _SideMetric(
                  icon: Icons.compress,
                  label: 'Pressure',
                  value: '1012 hPa',
                ),
                _SideMetric(
                  icon: Icons.visibility_outlined,
                  label: 'Visibility',
                  value: '10 km',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SideMetric extends StatelessWidget {
  const _SideMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1D4A6A)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1D4A6A)),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecastStrip extends StatelessWidget {
  const _HourlyForecastStrip({required this.current, required this.forecast});

  final CurrentWeather current;
  final List<DailyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hourly Forecast',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final hour = now.add(Duration(hours: index));
                  final label = index == 0
                      ? 'Now'
                      : '${hour.hour > 12 ? hour.hour - 12 : hour.hour} ${hour.hour >= 12 ? 'PM' : 'AM'}';
                  final temp = (current.temperatureC + (index - 2) * 0.6)
                      .clamp(0, 50)
                      .toStringAsFixed(0);
                  return Column(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        WeatherViewMapper.iconForCode(
                          forecast.first.conditionCode,
                        ),
                        color: const Color(0xFFF9A825),
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$temp°C',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyForecastStrip extends StatelessWidget {
  const _DailyForecastStrip({required this.forecast, required this.l10n});

  final List<DailyForecast> forecast;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '7-Day Forecast',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 78,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length.clamp(0, 7),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  final dayLabel = index == 0
                      ? 'Today'
                      : day.dateLabel.split(',').first;
                  return Column(
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        WeatherViewMapper.iconForCode(day.conditionCode),
                        color: Colors.amber.shade700,
                        size: 18,
                      ),
                      const SizedBox(height: 4),
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
          ],
        ),
      ),
    );
  }
}

class _InsightTiles extends StatelessWidget {
  const _InsightTiles({
    required this.uvIndex,
    required this.rainChance,
    required this.airQuality,
  });

  final int uvIndex;
  final int rainChance;
  final int airQuality;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InsightTile(
                      title: 'UV Index',
                      value: '$uvIndex',
                      subtitle: uvIndex > 6 ? 'High' : 'Moderate',
                      color: const Color(0xFFE8F4E7),
                      icon: Icons.wb_sunny_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InsightTile(
                      title: 'Rain Chance',
                      value: '$rainChance%',
                      subtitle: rainChance > 40 ? 'Likely' : 'Low',
                      color: const Color(0xFFE9F2FC),
                      icon: Icons.grain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InsightTile(
                title: 'Air Quality',
                value: '$airQuality',
                subtitle: 'Good',
                color: const Color(0xFFF5F1E3),
                icon: Icons.eco_outlined,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _InsightTile(
                title: 'UV Index',
                value: '$uvIndex',
                subtitle: uvIndex > 6 ? 'High' : 'Moderate',
                color: const Color(0xFFE8F4E7),
                icon: Icons.wb_sunny_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InsightTile(
                title: 'Rain Chance',
                value: '$rainChance%',
                subtitle: rainChance > 40 ? 'Likely' : 'Low',
                color: const Color(0xFFE9F2FC),
                icon: Icons.grain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InsightTile(
                title: 'Air Quality',
                value: '$airQuality',
                subtitle: 'Good',
                color: const Color(0xFFF5F1E3),
                icon: Icons.eco_outlined,
              ),
            ),
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
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.green.shade700),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _WeatherScreenData {
  const _WeatherScreenData({required this.current, required this.forecast});

  final CurrentWeather current;
  final List<DailyForecast> forecast;
}
