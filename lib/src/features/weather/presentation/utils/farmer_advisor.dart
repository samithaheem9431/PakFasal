import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../constants/weather_constants.dart';
import '../../domain/entities/weather_models.dart';

/// Severity of a farmer-facing recommendation. Drives icon and color
/// choices in [FarmerAdvisoryCard].
enum AdvisoryKind { positive, neutral, caution, alert }

/// One piece of localized actionable advice + the reason behind it.
class FarmerAdvisory {
  const FarmerAdvisory({
    required this.title,
    required this.body,
    required this.kind,
    required this.icon,
  });

  final String title;
  final String body;
  final AdvisoryKind kind;
  final IconData icon;

  Color colorFor(BuildContext context) => switch (kind) {
        AdvisoryKind.positive => AppColors.success,
        AdvisoryKind.neutral => AppColors.weatherBlue,
        AdvisoryKind.caution => AppColors.warning,
        AdvisoryKind.alert => AppColors.error,
      };

  Color backgroundFor(BuildContext context) =>
      colorFor(context).withValues(alpha: 0.10);
}

/// One serious crop alert (heatwave, heavy rain, etc.). Distinct from
/// soft advisories above — these are warnings that demand action.
class CropAlert {
  const CropAlert({
    required this.title,
    required this.body,
    required this.icon,
    required this.severity,
  });

  final String title;
  final String body;
  final IconData icon;
  final WeatherSeverity severity;

  Color get accent => switch (severity) {
        WeatherSeverity.severe => AppColors.error,
        WeatherSeverity.warning => const Color(0xFFE65100),
        WeatherSeverity.advisory => AppColors.warning,
        WeatherSeverity.info => AppColors.weatherBlue,
      };
}

/// Pure functions that turn a [WeatherSnapshot] into farmer-facing
/// advisories and crop alerts. Keeping these out of widgets makes the
/// logic easy to unit-test and to localize in one place.
class FarmerAdvisor {
  FarmerAdvisor._();

  /// Returns 1–4 most-relevant advisories for the next 24 hours.
  static List<FarmerAdvisory> advise(
    AppLocalizations l10n,
    WeatherSnapshot snapshot,
  ) {
    final out = <FarmerAdvisory>[];
    final current = snapshot.current;
    final today = snapshot.daily.isNotEmpty ? snapshot.daily.first : null;
    final tomorrow =
        snapshot.daily.length > 1 ? snapshot.daily[1] : null;
    final next24h = _next24hMaxRain(snapshot);

    final isWindy = current.windSpeedKmh >=
        WeatherConstants.windSpeedSprayUnsafeKmh;
    final isRainSoon = next24h >= WeatherConstants.rainProbabilityHigh;
    final isDry = next24h <= WeatherConstants.rainProbabilityLow &&
        current.windSpeedKmh < WeatherConstants.windSpeedSprayUnsafeKmh;
    final isHot = current.temperatureC >= WeatherConstants.heatwaveTemperatureC;

    // ── Irrigation guidance ──
    if (isRainSoon) {
      out.add(FarmerAdvisory(
        title: l10n.t('advisoryAvoidIrrigation'),
        body: l10n.t('advisoryAvoidIrrigationBody'),
        kind: AdvisoryKind.neutral,
        icon: Icons.water_drop_outlined,
      ));
    } else if (current.temperatureC < WeatherConstants.heatwaveTemperatureC &&
        current.windSpeedKmh < WeatherConstants.windSpeedHighKmh) {
      out.add(FarmerAdvisory(
        title: l10n.t('advisoryGoodIrrigation'),
        body: l10n.t('advisoryGoodIrrigationBody'),
        kind: AdvisoryKind.positive,
        icon: Icons.water_drop,
      ));
    }

    // ── Spraying guidance ──
    if (isWindy || isRainSoon) {
      out.add(FarmerAdvisory(
        title: l10n.t('advisoryAvoidSpraying'),
        body: l10n.t('advisoryAvoidSprayingBody'),
        kind: AdvisoryKind.caution,
        icon: Icons.spa_outlined,
      ));
    } else if (isDry) {
      out.add(FarmerAdvisory(
        title: l10n.t('advisoryGoodSpraying'),
        body: l10n.t('advisoryGoodSprayingBody'),
        kind: AdvisoryKind.positive,
        icon: Icons.spa,
      ));
    }

    // ── Tomorrow rain heads-up ──
    if (tomorrow != null &&
        tomorrow.rainChance >= WeatherConstants.rainProbabilityHigh) {
      out.add(FarmerAdvisory(
        title: l10n.t('advisoryRainTomorrow'),
        body: l10n.t('advisoryRainTomorrowBody'),
        kind: AdvisoryKind.neutral,
        icon: Icons.event,
      ));
    }

    // ── Heat protection ──
    if (isHot) {
      out.add(FarmerAdvisory(
        title: l10n.t('advisoryProtectFromHeat'),
        body: l10n.t('advisoryProtectFromHeatBody'),
        kind: AdvisoryKind.alert,
        icon: Icons.local_fire_department_outlined,
      ));
    }

    // ── Harvest window ──
    if (!isRainSoon &&
        today != null &&
        tomorrow != null &&
        today.rainChance < WeatherConstants.rainProbabilityLow &&
        tomorrow.rainChance < WeatherConstants.rainProbabilityLow &&
        out.length < 3) {
      out.add(FarmerAdvisory(
        title: l10n.t('advisoryHarvestWindow'),
        body: l10n.t('advisoryHarvestWindowBody'),
        kind: AdvisoryKind.positive,
        icon: Icons.agriculture_outlined,
      ));
    }

    return out.take(4).toList(growable: false);
  }

  /// Returns the active crop alerts (heavy rain, heatwave, frost, high
  /// wind, thunderstorm). These are derived from thresholds on the
  /// current/forecast data and complemented by provider-emitted alerts.
  static List<CropAlert> alerts(
    AppLocalizations l10n,
    WeatherSnapshot snapshot,
  ) {
    final out = <CropAlert>[];
    final c = snapshot.current;

    if (c.conditionCode >= 95) {
      out.add(CropAlert(
        title: l10n.t('cropAlertThunderstorm'),
        body: l10n.t('cropAlertThunderstormBody'),
        icon: Icons.thunderstorm,
        severity: WeatherSeverity.severe,
      ));
    }

    final next24h = _next24hMaxRain(snapshot);
    if (next24h >= 80) {
      out.add(CropAlert(
        title: l10n.t('cropAlertHeavyRain'),
        body: l10n.t('cropAlertHeavyRainBody'),
        icon: Icons.water,
        severity: WeatherSeverity.warning,
      ));
    }

    if (c.temperatureC >= WeatherConstants.heatwaveTemperatureC) {
      out.add(CropAlert(
        title: l10n.t('cropAlertHeatwave'),
        body: l10n.t('cropAlertHeatwaveBody'),
        icon: Icons.local_fire_department,
        severity: WeatherSeverity.warning,
      ));
    }

    if ((c.minTempC ?? c.temperatureC) <=
        WeatherConstants.frostTemperatureC) {
      out.add(CropAlert(
        title: l10n.t('cropAlertFrost'),
        body: l10n.t('cropAlertFrostBody'),
        icon: Icons.ac_unit,
        severity: WeatherSeverity.warning,
      ));
    }

    if (c.windSpeedKmh >= WeatherConstants.windSpeedHighKmh) {
      out.add(CropAlert(
        title: l10n.t('cropAlertHighWind'),
        body: l10n.t('cropAlertHighWindBody'),
        icon: Icons.air,
        severity: WeatherSeverity.advisory,
      ));
    }

    // Surface provider alerts (OWM One Call) verbatim too.
    for (final providerAlert in snapshot.alerts) {
      out.add(CropAlert(
        title: providerAlert.title,
        body: providerAlert.description.isEmpty
            ? (providerAlert.sender ?? '')
            : providerAlert.description,
        icon: Icons.warning_amber_rounded,
        severity: providerAlert.severity,
      ));
    }

    return out;
  }

  static double _next24hMaxRain(WeatherSnapshot s) {
    var max = 0;
    for (final h in s.hourly.take(8)) {
      final p = h.rainProbabilityPercent;
      if (p != null && p > max) max = p;
    }
    if (max == 0) {
      max = s.current.rainChancePercent;
    }
    return max.toDouble();
  }
}
