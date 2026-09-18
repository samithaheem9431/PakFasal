import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/weather_models.dart';
import '../utils/weather_view_mapper.dart';
import '../../../../core/theme/app_colors.dart';
import 'weather_glass_card.dart';
import 'weather_metric_tile.dart';

/// Apple Weather detail grid: Feels Like, UV, Wind, Sunrise, Precip,
/// Visibility, Humidity, Pressure.
class WeatherHighlightsGrid extends StatelessWidget {
  const WeatherHighlightsGrid({super.key, required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feelsDiff =
        current.apparentTemperatureC - current.temperatureC;
    final feelsNote = feelsDiff.abs() < 0.5
        ? null
        : feelsDiff > 0
            ? l10n.t('weatherFeelsWarmer')
            : l10n.t('weatherFeelsCooler');

    final uvLabel =
        WeatherViewMapper.localizedUvLabel(l10n, current.uvIndex);
    final dew = current.dewPointC;
    final humiditySub = dew == null
        ? null
        : '${l10n.t('weatherDewPoint')} ${dew.toStringAsFixed(0)}°';

    final visibilityNote = current.visibilityKm >= 10
        ? l10n.t('weatherClearView')
        : current.visibilityKm >= 5
            ? l10n.t('moderate')
            : l10n.t('weatherLimitedView');

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WeatherMetricTile(
                icon: Icons.thermostat_outlined,
                label: l10n.t('feelsLike'),
                value: '${current.apparentTemperatureC.toStringAsFixed(0)}°',
                subtitle: feelsNote,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherMetricTile(
                icon: Icons.wb_sunny_outlined,
                label: l10n.t('weatherUVIndex'),
                value: current.uvIndex.toStringAsFixed(0),
                subtitle: uvLabel,
                footer: _UvSpectrumBar(uv: current.uvIndex),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _WindCard(current: current),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SunriseTile(current: current),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherMetricTile(
                icon: Icons.water_drop_outlined,
                label: l10n.t('rainChance'),
                value: '${current.rainChancePercent}%',
                subtitle: l10n.t('weatherToday'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WeatherMetricTile(
                icon: Icons.visibility_outlined,
                label: l10n.t('weatherVisibility'),
                value:
                    '${current.visibilityKm.toStringAsFixed(0)} ${l10n.t('km')}',
                subtitle: visibilityNote,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherMetricTile(
                icon: Icons.water_outlined,
                label: l10n.t('humidity'),
                value: '${current.humidity}%',
                subtitle: humiditySub,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PressureTile(current: current),
      ],
    );
  }
}

class _UvSpectrumBar extends StatelessWidget {
  const _UvSpectrumBar({required this.uv});

  final double uv;

  @override
  Widget build(BuildContext context) {
    final t = (uv / 11).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF66BB6A),
                    Color(0xFFFFEE58),
                    Color(0xFFFFA726),
                    Color(0xFFEF5350),
                    Color(0xFFAB47BC),
                  ],
                ),
              ),
            ),
            Positioned(
              left: t * constraints.maxWidth - 5,
              top: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26, width: 1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WindCard extends StatelessWidget {
  const _WindCard({required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deg = current.windDirectionDeg;
    final cardinal = _windCardinal(deg);
    final speed = current.windSpeedKmh.toStringAsFixed(0);

    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air, size: 14, color: WeatherGlassStyle.label(context)),
              const SizedBox(width: 6),
              Text(
                l10n.t('wind').toUpperCase(),
                style: WeatherGlassStyle.sectionLabel(context, size: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _WindRow(
                      label: l10n.t('wind'),
                      value: '$speed ${l10n.t('kmh')}',
                    ),
                    Divider(height: 18, color: WeatherGlassStyle.divider(context)),
                    _WindRow(
                      label: l10n.t('weatherDirection'),
                      value: deg == null
                          ? (cardinal ?? '—')
                          : '${deg.toStringAsFixed(0)}° ${cardinal ?? ''}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _WindCompass(
                degrees: deg ?? 0,
                speedLabel: '$speed\n${l10n.t('kmh')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _windCardinal(int? deg) {
    if (deg == null) return null;
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final i = ((deg % 360) / 45).round() % 8;
    return dirs[i];
  }
}

class _WindRow extends StatelessWidget {
  const _WindRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: WeatherGlassStyle.caption(context)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _WindCompass extends StatelessWidget {
  const _WindCompass({
    required this.degrees,
    required this.speedLabel,
  });

  final int degrees;
  final String speedLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: CustomPaint(
        painter: _CompassPainter(degrees: degrees.toDouble()),
        child: Center(
          child: Text(
            speedLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.15,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.degrees});

  final double degrees;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.primaryGreen.withValues(alpha: 0.35);
    canvas.drawCircle(c, r, ring);

    final labelStyle = TextPainter(
      textDirection: TextDirection.ltr,
    );
    void drawLabel(String t, Offset o) {
      labelStyle.text = TextSpan(
        text: t,
        style: const TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      labelStyle.layout();
      labelStyle.paint(
        canvas,
        o - Offset(labelStyle.width / 2, labelStyle.height / 2),
      );
    }

    drawLabel('N', Offset(c.dx, c.dy - r + 10));
    drawLabel('E', Offset(c.dx + r - 10, c.dy));
    drawLabel('S', Offset(c.dx, c.dy + r - 10));
    drawLabel('W', Offset(c.dx - r + 10, c.dy));

    // Meteorological: wind FROM direction; needle points that way.
    final rad = (degrees - 90) * math.pi / 180;
    final tip = Offset(c.dx + r * 0.72 * math.cos(rad), c.dy + r * 0.72 * math.sin(rad));
    final needle = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, tip, needle);
    canvas.drawCircle(tip, 4, Paint()..color = AppColors.primaryGreen);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.degrees != degrees;
}

class _SunriseTile extends StatelessWidget {
  const _SunriseTile({required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sunrise = current.sunrise;
    final sunset = current.sunset;
    final value = sunrise == null
        ? '—'
        : TimeOfDay.fromDateTime(sunrise).format(context);
    final sub = sunset == null
        ? null
        : '${l10n.t('weatherSunset')} ${TimeOfDay.fromDateTime(sunset).format(context)}';

    return WeatherMetricTile(
      icon: Icons.wb_twilight_rounded,
      label: l10n.t('weatherSunrise'),
      value: value,
      subtitle: sub,
      footer: sunrise != null && sunset != null
          ? SizedBox(
              height: 36,
              width: double.infinity,
              child: CustomPaint(
                painter: _MiniSunArcPainter(
                  sunrise: sunrise,
                  sunset: sunset,
                  now: current.observedAt ?? DateTime.now(),
                ),
              ),
            )
          : null,
    );
  }
}

class _MiniSunArcPainter extends CustomPainter {
  _MiniSunArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.now,
  });

  final DateTime sunrise;
  final DateTime sunset;
  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height;
    final radiusX = size.width / 2 - 2;
    final radiusY = size.height - 2;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, centerY),
      width: radiusX * 2,
      height: radiusY * 2,
    );

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.primaryGreen.withValues(alpha: 0.25),
    );

    final totalMs = sunset.difference(sunrise).inMilliseconds;
    final progress =
        ((now.difference(sunrise).inMilliseconds) / (totalMs == 0 ? 1 : totalMs))
            .clamp(0.0, 1.0);
    if (progress > 0 && progress < 1) {
      final angle = math.pi + math.pi * progress;
      final dx = size.width / 2 + radiusX * math.cos(angle);
      final dy = centerY + radiusY * math.sin(angle);
      canvas.drawCircle(
        Offset(dx, dy),
        4,
        Paint()..color = const Color(0xFFFFB74D),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniSunArcPainter oldDelegate) =>
      oldDelegate.sunrise != sunrise ||
      oldDelegate.sunset != sunset ||
      oldDelegate.now != now;
}

class _PressureTile extends StatelessWidget {
  const _PressureTile({required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Typical sea-level range ~980–1040 for gauge.
    final t = ((current.pressureHpa - 980) / 60).clamp(0.0, 1.0);

    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      size: 14,
                      color: WeatherGlassStyle.label(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.t('weatherPressure').toUpperCase(),
                      style: WeatherGlassStyle.sectionLabel(context, size: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${current.pressureHpa} ${l10n.t('hpa')}',
                  style: WeatherGlassStyle.bigValue(context, size: 28),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            height: 70,
            child: CustomPaint(
              painter: _PressureGaugePainter(t: t),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressureGaugePainter extends CustomPainter {
  _PressureGaugePainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.85);
    final r = size.width * 0.42;
    final rect = Rect.fromCircle(center: c, radius: r);

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primaryGreen.withValues(alpha: 0.2),
    );

    canvas.drawArc(
      rect,
      math.pi,
      math.pi * t,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primaryGreen,
    );

    final angle = math.pi + math.pi * t;
    final tip = Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
    canvas.drawCircle(tip, 4, Paint()..color = AppColors.primaryGreen);
  }

  @override
  bool shouldRepaint(covariant _PressureGaugePainter oldDelegate) =>
      oldDelegate.t != t;
}
