import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';

class DashboardTile extends StatefulWidget {
  const DashboardTile({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.onTap,
    this.imageScale = 1.0,
    this.showLightBackdrop = false,
  });

  final String imageAsset;
  final String title;
  final VoidCallback onTap;

  /// Slight zoom for busy icons so they read clearer in small tiles.
  final double imageScale;

  /// Soft white plate behind the icon in light mode (helps bright subjects).
  final bool showLightBackdrop;

  @override
  State<DashboardTile> createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleSize = context.scaleFont(12, min: 0.9, max: 1.2);
    final hPad = context.screenWidth < 360 ? 6.0 : 8.0;

    // Light green background for tiles in light mode
    final baseSurface =
        isDark ? scheme.surfaceContainerHighest : const Color(0xFFF1F8F5);
    final pressedSurface =
        isDark ? scheme.surfaceContainerHigh : const Color(0xFFE8F5E9);

    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _pressed ? pressedSurface : baseSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pressed
                ? scheme.primary.withValues(alpha: 0.35)
                : scheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _pressed ? 0.08 : 0.15),
              blurRadius: _pressed ? 4 : 10,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: scheme.primary.withValues(alpha: 0.12),
            highlightColor: scheme.primary.withValues(alpha: 0.16),
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final side = constraints.biggest.shortestSide;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Soft plate so bright icons stay readable in light mode
                            if (!isDark && widget.showLightBackdrop)
                              Container(
                                width: side * 0.9,
                                height: side * 0.9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.72),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.primary
                                          .withValues(alpha: 0.10),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            Transform.scale(
                              scale: widget.imageScale,
                              child: Image.asset(
                                widget.imageAsset,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                gaplessPlayback: true,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 36,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: titleSize,
                      height: 1.15,
                      letterSpacing: 0.2,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
