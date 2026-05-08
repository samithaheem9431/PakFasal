import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import 'section_card.dart';

/// Visualises today's sunrise and sunset around an arc representing the
/// sun's path. The current sun position is drawn as a glowing dot so
/// users instantly grasp where the day is.
class SunriseSunsetCard extends StatelessWidget {
  const SunriseSunsetCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    this.now,
  });

  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (sunrise == null || sunset == null) {
      return const SizedBox.shrink();
    }
    final current = now ?? DateTime.now();

    final horizon = Theme.of(context).colorScheme.outlineVariant;

    return SectionCard(
      title: l10n.t('weatherSunrise'),
      icon: Icons.wb_twilight_rounded,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2.4,
            child: CustomPaint(
              painter: _SunArcPainter(
                sunrise: sunrise!,
                sunset: sunset!,
                now: current,
                horizonColor: horizon,
                arcColor: AppColors.primaryGreen.withValues(alpha: 0.18),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SunInfo(
                  icon: Icons.wb_sunny_outlined,
                  label: l10n.t('weatherSunrise'),
                  value: TimeOfDay.fromDateTime(sunrise!).format(context),
                  accent: const Color(0xFFFFA726),
                ),
              ),
              Expanded(
                child: _SunInfo(
                  icon: Icons.nights_stay_outlined,
                  label: l10n.t('weatherSunset'),
                  value: TimeOfDay.fromDateTime(sunset!).format(context),
                  accent: const Color(0xFF7E57C2),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunInfo extends StatelessWidget {
  const _SunInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!alignEnd) Icon(icon, size: 18, color: accent),
        if (!alignEnd) const SizedBox(width: 6),
        Column(
          crossAxisAlignment:
              alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        if (alignEnd) const SizedBox(width: 6),
        if (alignEnd) Icon(icon, size: 18, color: accent),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  _SunArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.now,
    required this.horizonColor,
    required this.arcColor,
  });

  final DateTime sunrise;
  final DateTime sunset;
  final DateTime now;
  final Color horizonColor;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height;
    final radiusX = size.width / 2 - 8;
    final radiusY = size.height - 6;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = arcColor;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, centerY),
      width: radiusX * 2,
      height: radiusY * 2,
    );
    canvas.drawArc(rect, math.pi, math.pi, false, arcPaint);

    final horizonPaint = Paint()
      ..color = horizonColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY - 0.5),
      Offset(size.width, centerY - 0.5),
      horizonPaint,
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
        9,
        Paint()..color = const Color(0xFFFFB74D).withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        Offset(dx, dy),
        5,
        Paint()..color = const Color(0xFFFFA726),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter old) =>
      old.sunrise != sunrise ||
      old.sunset != sunset ||
      old.now != now ||
      old.horizonColor != horizonColor ||
      old.arcColor != arcColor;
}
