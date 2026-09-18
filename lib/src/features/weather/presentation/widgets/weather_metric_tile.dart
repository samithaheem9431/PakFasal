import 'package:flutter/material.dart';

import 'weather_glass_card.dart';

/// Apple Weather detail tile: uppercase label + icon, large value, subtitle.
class WeatherMetricTile extends StatelessWidget {
  const WeatherMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.footer,
    this.minHeight = 150,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Widget? footer;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SizedBox(
        height: minHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: WeatherGlassStyle.label(context)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WeatherGlassStyle.sectionLabel(context, size: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WeatherGlassStyle.bigValue(context, size: 30),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: WeatherGlassStyle.caption(context),
              ),
            ],
            if (footer != null) ...[
              const Spacer(),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
