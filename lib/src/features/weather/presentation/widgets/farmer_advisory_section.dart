import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../utils/farmer_advisor.dart';
import 'weather_glass_card.dart';

/// Renders the list of [FarmerAdvisory]s as glass cards.
class FarmerAdvisorySection extends StatelessWidget {
  const FarmerAdvisorySection({super.key, required this.advisories});

  final List<FarmerAdvisory> advisories;

  @override
  Widget build(BuildContext context) {
    if (advisories.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.agriculture_rounded,
                size: 14,
                color: WeatherGlassStyle.label(context),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.t('farmerAdvisory').toUpperCase(),
                style: WeatherGlassStyle.sectionLabel(context, size: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < advisories.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: _AdvisoryCard(advisory: advisories[i], isDark: dark),
            ),
        ],
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({required this.advisory, required this.isDark});

  final FarmerAdvisory advisory;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accent = advisory.colorFor(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(advisory.icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisory.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  advisory.body,
                  style: WeatherGlassStyle.body(context, size: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
