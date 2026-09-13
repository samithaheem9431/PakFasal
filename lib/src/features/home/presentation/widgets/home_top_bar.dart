import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Dashboard header matching the PakFasal green brand bar:
/// menu · circular leaf logo + name/tagline · notification bell with badge,
/// with status-bar bleed and a soft wave bottom edge.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.tagline,
    required this.onMenuTap,
    required this.onNotificationTap,
    this.notificationCount = 3,
  });

  final String tagline;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ClipPath(
      clipper: const _TopBarWaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkGreen,
              AppColors.primaryGreen,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: topInset - 10,
              child: CustomPaint(
                size: const Size(140, 110),
                painter: _LeafAccentPainter(
                  color: AppColors.lightGreen.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: 8,
              child: CustomPaint(
                size: const Size(120, 90),
                painter: _LeafAccentPainter(
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(4, topInset + 6, 4, 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(
                      Icons.menu,
                      size: 26,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PakFasal',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.95),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: onNotificationTap,
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.white,
                          size: 26,
                        ),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          top: 6,
                          right: 8,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                notificationCount > 9
                                    ? '9+'
                                    : '$notificationCount',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarWaveClipper extends CustomClipper<Path> {
  const _TopBarWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveTop = size.height - 18;

    path.lineTo(0, waveTop);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height + 2,
      size.width * 0.48,
      size.height - 10,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height - 22,
      size.width,
      size.height - 6,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Soft stylized leaf shape used as a background accent on the top bar.
class _LeafAccentPainter extends CustomPainter {
  const _LeafAccentPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.05,
      size.width * 0.92,
      size.height * 0.28,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.95,
      size.width * 0.15,
      size.height * 0.55,
    );
    path.close();
    canvas.drawPath(path, paint);

    final vein = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.55),
      Offset(size.width * 0.78, size.height * 0.34),
      vein,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafAccentPainter oldDelegate) =>
      oldDelegate.color != color;
}
