import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

/// Full-screen skeleton for first load — light / dark aware.
class WeatherSkeleton extends StatelessWidget {
  const WeatherSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottom = PakFasalFloatingBottomBar.contentClearance(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      children: [
        _HeroSkeleton(isDark: dark),
        const SizedBox(height: 14),
        Center(
          child: SpinKitPulse(
            color: dark ? AppColors.lightGreen : AppColors.primaryGreen,
            size: 32,
          ),
        ),
        const SizedBox(height: 14),
        _BarSkeleton(height: 110, isDark: dark),
        const SizedBox(height: 12),
        _BarSkeleton(height: 220, isDark: dark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _BarSkeleton(height: 120, isDark: dark)),
            const SizedBox(width: 10),
            Expanded(child: _BarSkeleton(height: 120, isDark: dark)),
          ],
        ),
      ],
    );
  }
}

class _HeroSkeleton extends StatefulWidget {
  const _HeroSkeleton({required this.isDark});

  final bool isDark;

  @override
  State<_HeroSkeleton> createState() => _HeroSkeletonState();
}

class _HeroSkeletonState extends State<_HeroSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final base = widget.isDark
            ? AppColors.darkSurfaceHigh
            : AppColors.white;
        return Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: base.withValues(
              alpha: 0.45 + 0.25 * _controller.value,
            ),
            border: Border.all(
              color: (widget.isDark
                      ? AppColors.lightGreen
                      : AppColors.primaryGreen)
                  .withValues(alpha: 0.12),
            ),
          ),
        );
      },
    );
  }
}

class _BarSkeleton extends StatelessWidget {
  const _BarSkeleton({required this.height, required this.isDark});

  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurfaceHigh : AppColors.white)
            .withValues(alpha: isDark ? 0.65 : 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.lightGreen : AppColors.primaryGreen)
              .withValues(alpha: 0.12),
        ),
      ),
    );
  }
}
