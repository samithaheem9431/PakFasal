import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/localization_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// [onPrimary] — white text (green app bars).
/// [onSurface] — adapts to light/dark page backgrounds.
enum LanguageToggleVariant { onPrimary, onSurface }

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({
    super.key,
    this.variant = LanguageToggleVariant.onPrimary,
    this.showChevron = false,
  });

  final LanguageToggleVariant variant;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocalizationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color foreground;
    final Color background;
    final Color border;

    if (variant == LanguageToggleVariant.onSurface) {
      foreground = isDark ? AppColors.white : AppTheme.primaryGreen;
      background = isDark
          ? AppColors.white.withValues(alpha: 0.12)
          : AppColors.white.withValues(alpha: 0.72);
      border = isDark
          ? AppColors.white.withValues(alpha: 0.35)
          : AppTheme.primaryGreen.withValues(alpha: 0.35);
    } else {
      foreground = AppColors.white;
      background = AppColors.white.withValues(alpha: 0.2);
      border = AppColors.white.withValues(alpha: 0.3);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.toggleLanguage,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 16,
                color: foreground,
              ),
              const SizedBox(width: 4),
              Text(
                controller.isUrdu ? 'اردو' : 'EN',
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: foreground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
