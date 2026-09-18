import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

/// Empty / error state — light / dark aware.
class WeatherErrorView extends StatelessWidget {
  const WeatherErrorView({
    super.key,
    required this.onRetry,
    this.message,
    this.onSearchCity,
    this.onUseLocation,
  });

  final VoidCallback onRetry;
  final VoidCallback? onSearchCity;
  final VoidCallback? onUseLocation;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottom = PakFasalFloatingBottomBar.contentClearance(context);
    final textColor = dark ? AppColors.white : AppColors.darkText;
    final muted = dark
        ? AppColors.white.withValues(alpha: 0.7)
        : AppColors.mutedText;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 24, 20, bottom + 16),
      children: [
        Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (dark ? AppColors.lightGreen : AppColors.primaryGreen)
                .withValues(alpha: 0.12),
          ),
          child: Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: dark ? AppColors.lightGreen : AppColors.primaryGreen,
          ),
        ),
        Center(
          child: Text(
            l10n.t('weatherFetchError'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.t('retry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        if (onSearchCity != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onSearchCity,
              icon: const Icon(Icons.search_rounded),
              label: Text(l10n.t('weatherSearchCity')),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    dark ? AppColors.lightGreen : AppColors.primaryGreen,
                side: BorderSide(
                  color: dark ? AppColors.lightGreen : AppColors.primaryGreen,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
        if (onUseLocation != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onUseLocation,
            icon: const Icon(
              Icons.my_location_rounded,
              color: AppColors.weatherBlue,
            ),
            label: Text(
              l10n.t('weatherUseCurrentLocation'),
              style: const TextStyle(color: AppColors.weatherBlue),
            ),
          ),
        ],
      ],
    );
  }
}
