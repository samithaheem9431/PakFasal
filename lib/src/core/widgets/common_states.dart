import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../performance/device_performance.dart';
import '../theme/app_colors.dart';

/// Compact inline loading row (buttons, nested panels).
class LoadingStateCard extends StatelessWidget {
  const LoadingStateCard({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message ?? localizations.t('loading'))),
          ],
        ),
      ),
    );
  }
}

/// Shared list/grid skeleton used across Marketplace, Govt Schemes, etc.
/// Matches the weather-style pulse blocks without per-screen duplication.
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 96,
    this.featuredHeight = 140,
    this.showFeatured = true,
  });

  final int itemCount;
  final double itemHeight;
  final double featuredHeight;
  final bool showFeatured;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        if (showFeatured) ...[
          _SkeletonBar(height: featuredHeight, isDark: dark),
          const SizedBox(height: 12),
        ],
        for (var i = 0; i < itemCount; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _SkeletonBar(height: itemHeight, isDark: dark),
        ],
      ],
    );
  }
}

class _SkeletonBar extends StatefulWidget {
  const _SkeletonBar({required this.height, required this.isDark});

  final double height;
  final bool isDark;

  @override
  State<_SkeletonBar> createState() => _SkeletonBarState();
}

class _SkeletonBarState extends State<_SkeletonBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (!DevicePerformance.reduceMotion) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base =
        widget.isDark ? AppColors.darkSurfaceHigh : AppColors.white;
    final border = (widget.isDark ? AppColors.lightGreen : AppColors.primaryGreen)
        .withValues(alpha: 0.12);

    Widget bar(double alpha) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: base.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return bar(widget.isDark ? 0.65 : 0.72);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return bar(0.45 + 0.25 * controller.value);
      },
    );
  }
}

class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({super.key, this.onRetry, this.message});

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message ?? localizations.t('errorState'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onErrorContainer,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: Text(localizations.t('retry')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
