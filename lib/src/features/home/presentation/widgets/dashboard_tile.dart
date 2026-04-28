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

  // ── Green palette ────────────────────────────────────────────────────────
  static const _forestGreen   = Color(0xFF2E7D32);
  static const _lightGreen    = Color(0xFFE8F5E9);
  static const _midGreen      = Color(0xFFC8E6C9);
  static const _pressedGreen  = Color(0xFFD0EDD1);
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          // Pressed: slightly deeper green tint; default: white with green border
          color: _pressed ? _pressedGreen : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _pressed ? _forestGreen.withValues(alpha: 0.35) : _midGreen,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _forestGreen.withValues(alpha: _pressed ? 0.04 : 0.08),
              blurRadius: _pressed ? 4 : 10,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: _lightGreen,
            highlightColor: _lightGreen.withValues(alpha: 0.6),
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon bubble ──────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _pressed
                            ? [_midGreen, _lightGreen]
                            : [_lightGreen, _lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _forestGreen.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: _forestGreen,
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
                        fontSize: 13,
                        letterSpacing: 0.2,
                        color: _pressed
                            ? _forestGreen
                            : const Color(0xFF1B5E20),
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