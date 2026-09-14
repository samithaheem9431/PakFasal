import 'package:flutter/material.dart';

/// Material-style width buckets used across PakFasal.
enum AppWindowSize { compact, medium, expanded }

class AppBreakpoints {
  AppBreakpoints._();

  /// Phones (portrait).
  static const double compact = 600;

  /// Large phones / small tablets.
  static const double medium = 900;

  /// Soft max width so content does not stretch edge-to-edge on tablets.
  static const double maxContentWidth = 840;

  /// Reference design width used for light font/hero scaling.
  static const double designWidth = 390;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  AppWindowSize get windowSize {
    final w = screenWidth;
    if (w < AppBreakpoints.compact) return AppWindowSize.compact;
    if (w < AppBreakpoints.medium) return AppWindowSize.medium;
    return AppWindowSize.expanded;
  }

  bool get isCompact => windowSize == AppWindowSize.compact;

  bool get isMedium => windowSize == AppWindowSize.medium;

  bool get isExpanded => windowSize == AppWindowSize.expanded;

  /// Horizontal page inset that grows slightly on wider devices.
  EdgeInsets pagePadding({
    double horizontal = 16,
    double top = 0,
    double bottom = 0,
  }) {
    final h = switch (windowSize) {
      AppWindowSize.compact => horizontal,
      AppWindowSize.medium => horizontal + 8,
      AppWindowSize.expanded => horizontal + 16,
    };
    return EdgeInsets.fromLTRB(h, top, h, bottom);
  }

  int gridColumns({
    int compact = 2,
    int medium = 3,
    int expanded = 4,
  }) {
    return switch (windowSize) {
      AppWindowSize.compact => compact,
      AppWindowSize.medium => medium,
      AppWindowSize.expanded => expanded,
    };
  }

  /// Home quick-access tile columns.
  int dashboardColumns() {
    final w = screenWidth;
    if (w < 360) return 2;
    if (w < AppBreakpoints.compact) return 3;
    if (w < AppBreakpoints.medium) return 4;
    return 6;
  }

  /// Learning / marketplace style topic grids.
  int topicGridColumns() {
    final w = screenWidth;
    if (w < 360) return 1;
    if (w < AppBreakpoints.compact) return 2;
    if (w < AppBreakpoints.medium) return 3;
    return 4;
  }

  double drawerWidth() => (screenWidth * 0.82).clamp(260.0, 360.0);

  /// Light scale relative to a ~390px phone design.
  double scale(double base, {double min = 0.85, double max = 1.2}) {
    final factor = (screenWidth / AppBreakpoints.designWidth).clamp(min, max);
    return base * factor;
  }

  double scaleFont(double base, {double min = 0.9, double max = 1.15}) =>
      scale(base, min: min, max: max);

  /// Shorter phones get a reduced hero; tall tablets get a mild boost.
  double heroHeight(double base) {
    final hFactor = (screenHeight / 780).clamp(0.72, 1.15);
    final wFactor = (screenWidth / AppBreakpoints.designWidth).clamp(0.85, 1.2);
    return base * hFactor * (0.7 + 0.3 * wFactor);
  }
}

/// Centers [child] and caps width on tablets / landscape.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
