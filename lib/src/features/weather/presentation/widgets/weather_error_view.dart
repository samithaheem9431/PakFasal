import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Friendly empty / error state shown when the very first fetch fails
/// and there is no cached data available either.
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
      children: [
        Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen.withValues(alpha: 0.10),
          ),
          child: const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: AppColors.primaryGreen,
          ),
        ),
        Center(
          child: Text(
            l10n.t('weatherFetchError'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
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
            icon: const Icon(Icons.my_location_rounded),
            label: Text(l10n.t('weatherUseCurrentLocation')),
          ),
        ],
      ],
    );
  }
}
