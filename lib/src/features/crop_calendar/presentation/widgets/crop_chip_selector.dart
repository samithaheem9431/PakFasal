import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../utils/crop_calendar_visuals.dart';

/// Horizontal scrollable list of crop chips with icons.
///
/// Stateless on purpose — the parent owns the selected value so the
/// chip can be reused inside the home screen, a season summary card,
/// or any future surface that needs crop selection.
class CropChipSelector extends StatelessWidget {
  const CropChipSelector({
    super.key,
    required this.crops,
    required this.selectedCrop,
    required this.onCropSelected,
  });

  final List<CropType> crops;
  final CropType selectedCrop;
  final ValueChanged<CropType> onCropSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final crop = crops[index];
          final isSelected = selectedCrop == crop;
          return ChoiceChip(
            label: Row(
              children: [
                Icon(
                  CropCalendarVisuals.iconForCrop(crop),
                  size: 18,
                  color: isSelected
                      ? AppColors.white
                      : AppColors.primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.t(CropCalendarVisuals.cropLabelKey(crop)),
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                    color:
                        isSelected ? AppColors.white : AppColors.darkText,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            selectedColor: AppColors.primaryGreen,
            backgroundColor: AppColors.paleGreen,
            showCheckmark: false,
            onSelected: (selected) {
              if (selected) onCropSelected(crop);
            },
          );
        },
      ),
    );
  }
}
