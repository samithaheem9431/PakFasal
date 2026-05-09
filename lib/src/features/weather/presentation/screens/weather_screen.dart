import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../providers/weather_provider.dart';
import '../utils/farmer_advisor.dart';
import '../widgets/crop_alert_banner.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/farmer_advisory_section.dart';
import '../widgets/hourly_forecast_slider.dart';
import '../widgets/sunrise_sunset_card.dart';
import '../widgets/temperature_hero_card.dart';
import '../widgets/weather_error_view.dart';
import '../widgets/weather_highlights_grid.dart';
import '../widgets/weather_skeleton.dart';

/// Premium agriculture-themed weather dashboard.
///
/// Composition (top → bottom):
///   1. [CropAlertBannerStack]       severe alerts (heatwave, heavy rain…)
///   2. [TemperatureHeroCard]        big temperature + condition
///   3. [HourlyForecastSlider]       next 12 hours
///   4. [WeatherHighlightsGrid]      humidity / wind / UV / pressure …
///   5. [SunriseSunsetCard]          sun arc + times
///   6. [FarmerAdvisorySection]      irrigation / spraying / harvest tips
///   7. [DailyForecastList]          7-day outlook
///
/// State, networking, caching and offline behaviour are all delegated to
/// [WeatherProvider]; this screen is "dumb" and only composes widgets.
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
    return PakFasalScaffold(
      title: l10n.t('weather'),
      showBack: true,
      child: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _refresh,
        child: Consumer<WeatherProvider>(
          builder: (context, weather, _) {
            // First-load empty state — show skeleton.
            if (!weather.hasSnapshot && weather.isLoading) {
              return const WeatherSkeleton();
            }
            // Total failure (no cache, no live data).
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

// ─────────────────────────────────────────────────────────────────────────

class _WeatherContent extends StatelessWidget {
  const _WeatherContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weather = context.watch<WeatherProvider>();
    final snapshot = weather.snapshot!;
    final current = snapshot.current;

    final advisories = FarmerAdvisor.advise(l10n, snapshot);
    final cropAlerts = FarmerAdvisor.alerts(l10n, snapshot);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        14,
        14,
        14,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        if (weather.isStale) ...[
          _OfflineHint(message: l10n.t('weatherOfflineNotice')),
          const SizedBox(height: 8),
        ],
        if (cropAlerts.isNotEmpty) ...[
          CropAlertBannerStack(alerts: cropAlerts),
          const SizedBox(height: 12),
        ],
        TemperatureHeroCard(current: current),
        const SizedBox(height: 12),
        HourlyForecastSlider(hourly: snapshot.hourly),
        const SizedBox(height: 12),
        WeatherHighlightsGrid(current: current),
        const SizedBox(height: 12),
        if (current.sunrise != null && current.sunset != null) ...[
          SunriseSunsetCard(
            sunrise: current.sunrise,
            sunset: current.sunset,
          ),
          const SizedBox(height: 12),
        ],
        FarmerAdvisorySection(advisories: advisories),
        if (advisories.isNotEmpty) const SizedBox(height: 12),
        DailyForecastList(forecast: snapshot.daily),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────

class _OfflineHint extends StatelessWidget {
  const _OfflineHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFFFD180) : const Color(0xFF8C5500);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
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
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

