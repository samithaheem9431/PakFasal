import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/crop_calendar_catalog.dart';

/// Horizontal scrollable list of crop choice chips.
class CropChipSelector extends StatelessWidget {
  const CropChipSelector({
    super.key,
    required this.selectedCropId,
    required this.onCropSelected,
  });

  final String selectedCropId;
  final ValueChanged<String> onCropSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crops = CropCalendarCatalog.all;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final crop = crops[index];
          final isSelected = crop.id == selectedCropId;
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  crop.icon,
                  size: 18,
                  color: isSelected ? AppColors.white : AppColors.primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.t(crop.nameKey),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color:
                    isSelected ? AppColors.primaryGreen : AppColors.divider,
              ),
            ),
            onSelected: (selected) {
              if (selected) onCropSelected(crop.id);
            },
          );
        },
      ),
    );
  }
}
