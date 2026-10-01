import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Flat PakFasal card for weather sections — readable, no glass blur.
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

  /// Kept for call-site compatibility; blur is no longer used.
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurfaceHigh : AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: dark
              ? AppColors.lightGreen.withValues(alpha: 0.28)
              : AppColors.primaryGreen.withValues(alpha: 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.32 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
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
      : AppColors.primaryGreen;

  static Color value(BuildContext context) =>
      _dark(context) ? AppColors.white : AppColors.darkText;

  static Color muted(BuildContext context) => _dark(context)
      ? AppColors.white.withValues(alpha: 0.65)
      : AppColors.mutedText;

  static Color divider(BuildContext context) => _dark(context)
      ? AppColors.white.withValues(alpha: 0.12)
      : AppColors.divider;

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
        fontWeight: FontWeight.w600,
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
        color: muted(context),
        fontSize: size,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );
}
