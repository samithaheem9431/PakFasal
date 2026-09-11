import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/localization_controller.dart';
import '../theme/app_colors.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocalizationController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.language,
            size: 16,
            color: AppColors.white,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: controller.toggleLanguage,
            child: Text(
              controller.isUrdu ? 'اردو' : 'EN',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
