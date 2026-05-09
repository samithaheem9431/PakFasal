import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../utils/crop_calendar_visuals.dart';

/// Wrapping row of area chips ("Multan" / "Lahore" today).
///
/// Mirrors the visual language of [CropChipSelector] so the two selectors
/// feel like one set of controls.
class AreaChipSelector extends StatelessWidget {
  const AreaChipSelector({
    super.key,
    required this.areas,
    required this.selectedArea,
    required this.onAreaSelected,
  });

  final List<CropArea> areas;
  final CropArea selectedArea;
  final ValueChanged<CropArea> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: areas.map((area) {
        final selected = selectedArea == area;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color:
                    selected ? AppColors.white : AppColors.primaryGreen,
              ),
              const SizedBox(width: 4),
              Text(l10n.t(CropCalendarVisuals.areaLabelKey(area))),
            ],
          ),
          selected: selected,
          showCheckmark: false,
          selectedColor: AppColors.primaryGreen,
          backgroundColor: AppColors.paleGreen,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.darkText,
          ),
          onSelected: (_) => onAreaSelected(area),
        );
      }).toList(),
    );
  }
}
