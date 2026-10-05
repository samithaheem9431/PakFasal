import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/performance/device_performance.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen skeleton for first load — light / dark aware.
class WeatherSkeleton extends StatelessWidget {
  const WeatherSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = DevicePerformance.reduceMotion;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _HeroSkeleton(isDark: dark, animate: !reduceMotion),
        const SizedBox(height: 14),
        if (!reduceMotion)
          Center(
            child: SpinKitPulse(
              color: dark ? AppColors.lightGreen : AppColors.primaryGreen,
              size: 32,
            ),
          )
        else
          const SizedBox(
            height: 32,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
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
  const _HeroSkeleton({required this.isDark, required this.animate});

  final bool isDark;
  final bool animate;

  @override
  State<_HeroSkeleton> createState() => _HeroSkeletonState();
}

class _HeroSkeletonState extends State<_HeroSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1400),
        vsync: this,
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
    final base = widget.isDark ? AppColors.darkSurfaceHigh : AppColors.white;
    final border = (widget.isDark ? AppColors.lightGreen : AppColors.primaryGreen)
        .withValues(alpha: 0.12);

    Widget box(double alpha) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: base.withValues(alpha: alpha),
          border: Border.all(color: border),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) return box(0.7);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => box(0.45 + 0.25 * controller.value),
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
