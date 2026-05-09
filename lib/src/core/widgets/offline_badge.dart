import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OfflineBadge extends StatelessWidget {
  const OfflineBadge({
    super.key,
    required this.isOffline,
    this.isCompact = false,
  });

  final bool isOffline;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Tuned slightly brighter in dark mode so the badge reads against
    // dark surfaces while staying within the warning/success palette.
    final color = isOffline
        ? (isDark ? const Color(0xFFFFB74D) : AppColors.warning)
        : (isDark ? const Color(0xFF81C784) : AppColors.success);
    final icon = isOffline ? Icons.cloud_off : Icons.cloud_done;
    final text = isOffline ? 'Offline' : 'Online';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isCompact ? 14 : 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
