import 'package:flutter/material.dart';

class DashboardTile extends StatefulWidget {
  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon bubble with green background ─────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (_pressed
                              ? scheme.primary.withValues(alpha: 0.25)
                              : scheme.primary.withValues(alpha: 0.18))
                          : (_pressed
                              ? scheme.primary.withValues(alpha: 0.9)
                              : scheme.primary),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ── Label ────────────────────────────────────────────
                  Flexible(
                    child: Text(
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