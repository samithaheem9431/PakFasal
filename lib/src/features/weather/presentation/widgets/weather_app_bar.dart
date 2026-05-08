import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Sticky top bar shown above the hero card with location, today's date,
/// and quick actions (search city, use GPS).
class WeatherTopBar extends StatelessWidget {
  const WeatherTopBar({
    super.key,
    required this.locationLabel,
    this.lastSyncedLabel,
    this.onSearchTap,
    this.onLocationTap,
    this.isOffline = false,
  });

  final String locationLabel;
  final String? lastSyncedLabel;
  final VoidCallback? onSearchTap;
  final VoidCallback? onLocationTap;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.darkGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Location button (taps open city search) ──
          Expanded(
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.overlayWhite70,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      today,
                      style: const TextStyle(
                        color: AppColors.overlayWhite70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isOffline) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded,
                                color: AppColors.white, size: 11),
                            const SizedBox(width: 5),
                            Text(
                              l10n.t('cached'),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (lastSyncedLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        lastSyncedLabel!,
                        style: const TextStyle(
                          color: AppColors.overlayWhite70,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.my_location_rounded,
            tooltip: l10n.t('weatherUseCurrentLocation'),
            onTap: onLocationTap,
          ),
          const SizedBox(width: 6),
          _CircleAction(
            icon: Icons.search_rounded,
            tooltip: l10n.t('weatherSearchCity'),
            onTap: onSearchTap,
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: AppColors.white, size: 19),
          ),
        ),
      ),
    );
  }
}
