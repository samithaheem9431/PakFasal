import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../utils/farmer_advisor.dart';
import 'section_card.dart';

/// Renders the list of [FarmerAdvisory]s as colourful cards. Hides itself
/// when the advisor returns no items so the section never feels empty.
class FarmerAdvisorySection extends StatelessWidget {
  const FarmerAdvisorySection({super.key, required this.advisories});

  final List<FarmerAdvisory> advisories;

  @override
  Widget build(BuildContext context) {
    if (advisories.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return SectionCard(
      title: l10n.t('farmerAdvisory'),
      icon: Icons.agriculture_rounded,
      child: Column(
        children: [
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
        color: advisory.backgroundFor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
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
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
