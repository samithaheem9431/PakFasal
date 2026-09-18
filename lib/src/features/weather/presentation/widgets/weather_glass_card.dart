import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Frosted glass panel — light or dark depending on theme.
class WeatherGlassCard extends StatelessWidget {
  const WeatherGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 16,
    this.blurSigma = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark
                ? AppColors.darkSurfaceHigh.withValues(alpha: 0.78)
                : AppColors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: dark
                  ? AppColors.lightGreen.withValues(alpha: 0.22)
                  : AppColors.primaryGreen.withValues(alpha: 0.18),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.28 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Theme-aware text / chrome for weather cards.
class WeatherGlassStyle {
  WeatherGlassStyle._();

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color label(BuildContext context) => _dark(context)
      ? const Color(0xFFA5D6A7)
      : const Color(0xFF5A7A62);

  static Color value(BuildContext context) =>
      _dark(context) ? AppColors.white : AppColors.darkText;

  static Color muted(BuildContext context) => _dark(context)
      ? AppColors.white.withValues(alpha: 0.65)
      : const Color(0xFF7A9480);

  static Color divider(BuildContext context) => _dark(context)
      ? AppColors.white.withValues(alpha: 0.14)
      : const Color(0x332A6B3A);

  static Color icon(BuildContext context) =>
      _dark(context) ? AppColors.lightGreen : AppColors.primaryGreen;

  static Color accentBlue(BuildContext context) => AppColors.weatherBlue;

  static TextStyle sectionLabel(BuildContext context, {double size = 12}) =>
      TextStyle(
        color: label(context),
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      );

  static TextStyle bigValue(BuildContext context, {double size = 28}) =>
      TextStyle(
        color: value(context),
        fontSize: size,
        fontWeight: FontWeight.w500,
        height: 1.05,
      );

  static TextStyle largeValue(BuildContext context, {double size = 28}) =>
      bigValue(context, size: size);

  static TextStyle body(
    BuildContext context, {
    double size = 13,
    FontWeight weight = FontWeight.w500,
  }) =>
      TextStyle(
        color: value(context).withValues(alpha: 0.92),
        fontSize: size,
        fontWeight: weight,
        height: 1.3,
      );

  static TextStyle caption(BuildContext context, {double size = 12}) =>
      TextStyle(
        color: label(context),
        fontSize: size,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );
}
