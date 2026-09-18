import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../providers/weather_provider.dart';
import '../utils/farmer_advisor.dart';
import '../utils/weather_gradients.dart';
import '../utils/weather_view_mapper.dart';
import '../widgets/crop_alert_banner.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/farmer_advisory_section.dart';
import '../widgets/hourly_forecast_slider.dart';
import '../widgets/temperature_hero_card.dart';
import '../widgets/weather_error_view.dart';
import '../widgets/weather_highlights_grid.dart';
import '../widgets/weather_skeleton.dart';
import '../widgets/weather_sky_background.dart';
import '../widgets/weather_glass_card.dart';

/// Apple Weather–style immersive dashboard.
///
/// Composition (top → bottom):
///   1. Collapsing hero (city / temp / condition / H-L)
///   2. Hourly glass strip
///   3. 10-day forecast
///   4. Detail metric tiles
///   5. Crop alerts + farmer advisories
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

  Future<void> _useCurrentLocation() async {
    await context.read<WeatherProvider>().useCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PakFasalScaffold(
      title: l10n.t('weather'),
      showBack: true,
      backgroundColor: WeatherGradients.scaffoldFallback(isDark: isDark),
      extendBehindBottomBar: true,
      actions: [
        IconButton(
          tooltip: l10n.t('weatherSearchCity'),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.weatherCitySearch),
          icon: const Icon(Icons.search_rounded, color: AppColors.white),
        ),
      ],
      child: RefreshIndicator(
        color: isDark ? AppColors.lightGreen : AppColors.primaryGreen,
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.white,
        onRefresh: _refresh,
        child: Consumer<WeatherProvider>(
          builder: (context, weather, _) {
            if (!weather.hasSnapshot && weather.isLoading) {
              return const WeatherSkeleton();
            }
            if (!weather.hasSnapshot) {
              return WeatherErrorView(
                onRetry: _refresh,
                onUseLocation: _useCurrentLocation,
                message: weather.error?.toString(),
              );
            }
            return const _WeatherContent();
          },
        ),
      ),
    );
  }
}

class _WeatherContent extends StatefulWidget {
  const _WeatherContent();

  @override
  State<_WeatherContent> createState() => _WeatherContentState();
}

class _WeatherContentState extends State<_WeatherContent> {
  double _collapse = 0;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final next = (n.metrics.pixels / 120).clamp(0.0, 1.0);
    if ((next - _collapse).abs() > 0.01) {
      setState(() => _collapse = next);
    }
    return false;
  }

  String _hourlySummary(
    AppLocalizations l10n,
    WeatherProvider weather,
  ) {
    final current = weather.snapshot!.current;
    final condition = current.conditionLabel ??
        WeatherViewMapper.localizedCondition(l10n, current.conditionCode);
    final wind = current.windSpeedKmh.toStringAsFixed(0);
    return '$condition. ${l10n.t('wind')} $wind ${l10n.t('kmh')}.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weather = context.watch<WeatherProvider>();
    final snapshot = weather.snapshot!;
    final current = snapshot.current;
    final isMyLocation = weather.activeLocation?.isCurrent ?? true;

    final advisories = FarmerAdvisor.advise(l10n, snapshot);
    final cropAlerts = FarmerAdvisor.alerts(l10n, snapshot);

    final topInset = 12.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: WeatherSkyBackground(current: current),
        ),
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: context.pagePadding(
              horizontal: 16,
              top: topInset,
              bottom: 16 +
                  PakFasalFloatingBottomBar.contentClearance(context),
            ),
            children: [
              if (weather.isStale) ...[
                _OfflineHint(message: l10n.t('weatherOfflineNotice')),
                const SizedBox(height: 10),
              ],
              TemperatureHeroCard(
                current: current,
                collapseProgress: _collapse,
                isMyLocation: isMyLocation,
              ),
              const SizedBox(height: 8),
              HourlyForecastSlider(
                hourly: snapshot.hourly,
                summary: _hourlySummary(l10n, weather),
              ),
              const SizedBox(height: 12),
              DailyForecastList(
                forecast: snapshot.daily,
                currentTempC: current.temperatureC,
              ),
              const SizedBox(height: 12),
              WeatherHighlightsGrid(current: current),
              if (cropAlerts.isNotEmpty) ...[
                const SizedBox(height: 12),
                CropAlertBannerStack(alerts: cropAlerts),
              ],
              if (advisories.isNotEmpty) ...[
                const SizedBox(height: 12),
                FarmerAdvisorySection(advisories: advisories),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OfflineHint extends StatelessWidget {
  const _OfflineHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: WeatherGlassStyle.body(context, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}
