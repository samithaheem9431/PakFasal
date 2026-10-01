import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../utils/farmer_advisor.dart';
import 'weather_glass_card.dart';

/// Farmer advisory list matching the reference card style.
class FarmerAdvisorySection extends StatelessWidget {
  const FarmerAdvisorySection({super.key, required this.advisories});

  final List<FarmerAdvisory> advisories;

  @override
  Widget build(BuildContext context) {
    if (advisories.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return WeatherGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                size: 16,
                color: WeatherGlassStyle.label(context),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.t('farmerAdvisory').toUpperCase(),
                style: WeatherGlassStyle.sectionLabel(context, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < advisories.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: _AdvisoryCard(advisory: advisories[i]),
            ),
        ],
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({required this.advisory});

  final FarmerAdvisory advisory;

  @override
  Widget build(BuildContext context) {
    final accent = advisory.colorFor(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  advisory.body,
                  style: WeatherGlassStyle.body(context, size: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: accent.withValues(alpha: 0.7),
            size: 22,
          ),
        ],
      ),
    );
  }
}
