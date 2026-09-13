import 'package:flutter/material.dart';

class DashboardTile extends StatefulWidget {
  const DashboardTile({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.onTap,
  });

  final String imageAsset;
  final String title;
  final VoidCallback onTap;

  @override
  State<DashboardTile> createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light green background for tiles in light mode
    final baseSurface = isDark ? scheme.surfaceContainerHighest : const Color(0xFFF1F8F5);
    final pressedSurface = isDark ? scheme.surfaceContainerHigh : const Color(0xFFE8F5E9);

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Image.asset(
                      widget.imageAsset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 36,
                        color: scheme.primary,
                      ),
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
                      fontSize: 12,
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
