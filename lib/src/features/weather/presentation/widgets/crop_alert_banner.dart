import 'package:flutter/material.dart';

import '../utils/farmer_advisor.dart';
import 'weather_glass_card.dart';

/// Stack of banners for serious crop alerts (heatwave, heavy rain, frost,
/// high wind, thunderstorm). Banners are sorted by severity so the most
/// pressing warning appears at the top.
class CropAlertBannerStack extends StatelessWidget {
  const CropAlertBannerStack({super.key, required this.alerts});

  final List<CropAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    final sorted = [...alerts]
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
            child: _AlertBanner(alert: sorted[i]),
          ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.alert});

  final CropAlert alert;

  @override
  Widget build(BuildContext context) {
    final accent = alert.accent;
    return WeatherGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(alert.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                if (alert.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    alert.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: WeatherGlassStyle.body(context, size: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
