import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../providers/crop_calendar_provider.dart';

class CropCalendarTabBar extends StatelessWidget {
  const CropCalendarTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CropCalendarTab selected;
  final ValueChanged<CropCalendarTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget chip(CropCalendarTab tab, String labelKey) {
      final isSelected = selected == tab;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            selected: isSelected,
            label: Center(
              child: Text(
                l10n.t(labelKey),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: isSelected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
            selectedColor: scheme.primary,
            backgroundColor: scheme.surfaceContainerHighest,
            showCheckmark: false,
            onSelected: (_) => onSelected(tab),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          chip(CropCalendarTab.guide, 'cropCalTabGuide'),
          chip(CropCalendarTab.myCrops, 'cropCalTabMyCrops'),
          chip(CropCalendarTab.month, 'cropCalTabMonth'),
        ],
      ),
    );
  }
}
