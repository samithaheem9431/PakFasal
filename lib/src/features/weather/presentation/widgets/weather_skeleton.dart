import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-screen skeleton placeholder shown on first load while the snapshot
/// is being fetched. Uses a soft shimmer effect (via a custom animation)
/// so users feel responsive feedback rather than a blank screen.
class WeatherSkeleton extends StatelessWidget {
  const WeatherSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const _HeroSkeleton(),
        const SizedBox(height: 14),
        Center(
          child: SpinKitPulse(
            color: AppColors.primaryGreen.withValues(alpha: 0.6),
            size: 32,
          ),
        ),
        const SizedBox(height: 14),
        const _BarSkeleton(height: 110),
        const SizedBox(height: 12),
        const _BarSkeleton(height: 220),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _BarSkeleton(height: 90)),
            SizedBox(width: 10),
            Expanded(child: _BarSkeleton(height: 90)),
          ],
        ),
      ],
    );
  }
}

class _HeroSkeleton extends StatefulWidget {
  const _HeroSkeleton();

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
        return Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen
                    .withValues(alpha: 0.18 + 0.07 * _controller.value),
                AppColors.lightGreen
                    .withValues(alpha: 0.10 + 0.05 * _controller.value),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BarSkeleton extends StatelessWidget {
  const _BarSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}
