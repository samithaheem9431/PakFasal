import 'package:flutter/material.dart';

import '../utils/farmer_advisor.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.40)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
