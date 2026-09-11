import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../weather/domain/entities/weather_models.dart';
import '../../../weather/presentation/utils/weather_view_mapper.dart';

class HomeWeatherCard extends StatelessWidget {
  const HomeWeatherCard({
    super.key,
    required this.weather,
    required this.temperatureLabel,
    required this.humidityLabel,
    required this.rainChanceLabel,
    this.lastSyncedLabel,
    this.isOffline = false,
  });

  final CurrentWeather weather;
  final String temperatureLabel;
  final String humidityLabel;
  final String rainChanceLabel;
  final String? lastSyncedLabel;
  final bool isOffline;

  // ── Green palette ────────────────────────────────────────────────────────
  static const _cardBg = Color(0xFF1B5E20); // deep forest green
  static const _accentGreen = Color(0xFF69F0AE); // mint accent
  static const _softWhite = Color(0xCCFFFFFF); // 80% white
  static const _dimWhite = Color(0x73FFFFFF); // 45% white for hints
  static const _divider = Color(0x1AFFFFFF); // 10% white divider
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1B5E20), // Deep green
                const Color(0xFF2E7D32), // Lighter green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative wave patterns (simulating farm fields) ──────
              Positioned(
                bottom: -20,
                left: -40,
                right: -40,
                child: CustomPaint(
                  size: Size(double.infinity, 120),
                  painter: _WavePainter(),
                ),
              ),
              
              // ── Sun/Cloud icon (large, top right) ─────────────────────
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    WeatherViewMapper.iconForCode(weather.conditionCode),
                    color: const Color(0xFFFFD54F),
                    size: 48,
                  ),
                ),
              ),

              // ── Main content ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Location with pin icon ────────────────────────
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: _softWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          weather.locationLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _softWhite,
                          ),
                        ),
                      ],
                    ),
                    
                    // ── Last updated time ─────────────────────────────
                    if (lastSyncedLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          lastSyncedLabel!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: _dimWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ── Large temperature display ─────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: weather.temperatureC - 5,
                            end: weather.temperatureC,
                          ),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 0.9,
                              letterSpacing: -3,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: _softWhite,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // ── Feels like ────────────────────────────────────
                    Text(
                      '${l10n.t('feelsLike')} ${(weather.temperatureC - 3).toStringAsFixed(0)}°  ·  ${l10n.t('updatedJustNow')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _softWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Three metric icons (Humidity, Rain, Wind) ─────
                    Row(
                      children: [
                        _CompactMetricIcon(
                          icon: Icons.water_drop,
                          value: '${weather.humidity.toStringAsFixed(0)}%',
                          label: humidityLabel,
                        ),
                        const SizedBox(width: 24),
                        _CompactMetricIcon(
                          icon: Icons.cloudy_snowing,
                          value: '${weather.rainChancePercent}%',
                          label: rainChanceLabel,
                        ),
                        const SizedBox(width: 24),
                        _CompactMetricIcon(
                          icon: Icons.air,
                          value: '${weather.windSpeedKmh.toStringAsFixed(0)} km/h',
                          label: l10n.t('wind'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compact metric icon (Horizontal layout) ────────────────────────────────
class _CompactMetricIcon extends StatelessWidget {
  const _CompactMetricIcon({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  static const _softWhite = Color(0xCCFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _softWhite,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _softWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave painter for decorative farm field effect ──────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFF388E3C).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // First wave (lower)
    final path1 = Path();
    path1.moveTo(0, size.height * 0.5);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.5,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    // Second wave (upper)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.3);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.3,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.3,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
