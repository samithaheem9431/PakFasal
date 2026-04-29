import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── controllers ──────────────────────────────────────────────────────────
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final AnimationController _ringController;
  late final AnimationController _shimmerController;
  late final AnimationController _dotsController;
  late final AnimationController _wheatController;
  late final AnimationController _scanController;
  late final AnimationController _particleController;

  // ── animations ───────────────────────────────────────────────────────────
  late final Animation<double> _pulse;
  late final Animation<double> _fadeLogo;
  late final Animation<double> _fadeText;
  late final Animation<double> _fadeTagline;
  late final Animation<double> _ring1;
  late final Animation<double> _ring2;
  late final Animation<double> _ring3;
  late final Animation<double> _shimmer;
  late final Animation<double> _slideUp;
  late final Animation<double> _wheatSway;

  // ── state ────────────────────────────────────────────────────────────────
  final Color _primaryNeon = const Color(0xFF4AB74B);
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Generate random particles for the background effect
    final rnd = math.Random();
    _particles = List.generate(18, (i) => _Particle(
      x: rnd.nextDouble(),
      y: rnd.nextDouble(),
      speed: 0.2 + rnd.nextDouble() * 0.8,
      size: rnd.nextBool() ? 2.0 : 3.0,
      opacity: 0.3 + rnd.nextDouble() * 0.5,
    ));

    // Pulse – logo breathe
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulse = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Fade/slide – logo + text entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeLogo = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
    );
    _fadeText = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.40, 0.80, curve: Curves.easeOut),
    );
    _fadeTagline = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _fadeController.forward();

    // Expanding rings (3 rings based on HTML design)
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _ring1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ring2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: const Interval(0.25, 1.0, curve: Curves.easeOut)),
    );
    _ring3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: const Interval(0.50, 1.0, curve: Curves.easeOut)),
    );
    _ringController.repeat();

    // Shimmer sweep across logo disc
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _shimmerController.repeat();

    // Dots loading indicator
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _dotsController.repeat(reverse: true);

    // Wheat sway
    _wheatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _wheatSway = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _wheatController, curve: Curves.easeInOut),
    );
    _wheatController.repeat(reverse: true);

    // Scanline effect
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _scanController.repeat();

    // Particle effect
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _particleController.repeat();

    Timer(const Duration(milliseconds: 5000), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;

    final preferences = Hive.box('app_preferences');
    final hasSeenOnboarding =
    preferences.get('onboarding_seen', defaultValue: false) as bool;
    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    final signedIn = context.read<AuthSessionController>().isSignedIn;
    Navigator.pushReplacementNamed(
      context,
      signedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _ringController.dispose();
    _shimmerController.dispose();
    _dotsController.dispose();
    _wheatController.dispose();
    _scanController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0D),
      body: Stack(
        children: [
          // ── Background Gradient ──────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.45, 1.0],
                  colors: [
                    Color(0xFF0F2912),
                    Color(0xFF051408),
                    Color(0xFF071C0A),
                  ],
                ),
              ),
            ),
          ),

          // ── Scanline ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _scanController,
            builder: (_, __) => Positioned(
              top: size.height * _scanController.value,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _scanController.value > 0.95 ? 0 : 0.5,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _primaryNeon.withValues(alpha: 0.15),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Radial Glow Background ────────────────────────────
          Align(
            alignment: const Alignment(0, -0.15),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _primaryNeon.withValues(alpha: 0.18),
                        _primaryNeon.withValues(alpha: 0.07),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Floating Particles ────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                  color: _primaryNeon,
                ),
              ),
            ),
          ),

          // ── Corner Decorations ────────────────────────────────
          Positioned(
            top: 48,
            right: 24,
            child: FadeTransition(
              opacity: _fadeLogo,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: _primaryNeon.withValues(alpha: 0.15)),
                    right: BorderSide(color: _primaryNeon.withValues(alpha: 0.15)),
                  ),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(6)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            left: 24,
            child: FadeTransition(
              opacity: _fadeLogo,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: _primaryNeon.withValues(alpha: 0.15)),
                    left: BorderSide(color: _primaryNeon.withValues(alpha: 0.15)),
                  ),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6)),
                ),
              ),
            ),
          ),

          // ── Wheat silhouette row ──────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _wheatSway,
              builder: (_, __) => CustomPaint(
                size: Size(size.width, 110),
                painter: _WheatPainter(
                  sway: _wheatSway.value,
                  color: _primaryNeon.withValues(alpha: 0.13),
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // Logo with rings + pulse + shimmer
                  FadeTransition(
                    opacity: _fadeLogo,
                    child: ScaleTransition(
                      scale: _pulse,
                      child: SizedBox(
                        width: 164,
                        height: 164,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ring 1
                            AnimatedBuilder(
                              animation: _ring1,
                              builder: (_, __) => Opacity(
                                opacity: (1 - _ring1.value) * 0.8,
                                child: Container(
                                  width: 100 * (1.0 + _ring1.value * 0.9),
                                  height: 100 * (1.0 + _ring1.value * 0.9),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _primaryNeon.withValues(alpha: 0.25)),
                                  ),
                                ),
                              ),
                            ),
                            // Ring 2
                            AnimatedBuilder(
                              animation: _ring2,
                              builder: (_, __) => Opacity(
                                opacity: (1 - _ring2.value) * 0.8,
                                child: Container(
                                  width: 100 * (1.0 + _ring2.value * 0.9),
                                  height: 100 * (1.0 + _ring2.value * 0.9),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _primaryNeon.withValues(alpha: 0.15)),
                                  ),
                                ),
                              ),
                            ),
                            // Ring 3
                            AnimatedBuilder(
                              animation: _ring3,
                              builder: (_, __) => Opacity(
                                opacity: (1 - _ring3.value) * 0.8,
                                child: Container(
                                  width: 100 * (1.0 + _ring3.value * 0.9),
                                  height: 100 * (1.0 + _ring3.value * 0.9),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _primaryNeon.withValues(alpha: 0.08)),
                                  ),
                                ),
                              ),
                            ),
                            // Logo Disc
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF1A3D1D), Color(0xFF0F2612)],
                                ),
                                border: Border.all(color: _primaryNeon.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 40,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Inner Glow
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            center: const Alignment(-0.3, -0.4),
                                            colors: [
                                              _primaryNeon.withValues(alpha: 0.15),
                                              Colors.transparent
                                            ],
                                            stops: const [0.0, 0.6],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Icon
                                    Icon(
                                      Icons.agriculture_rounded,
                                      color: _primaryNeon,
                                      size: 52,
                                    ),
                                    // Shimmer sweep
                                    AnimatedBuilder(
                                      animation: _shimmer,
                                      builder: (_, __) => Positioned.fill(
                                        child: CustomPaint(
                                          painter: _ShimmerPainter(_shimmer.value),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Sun accent dot
                            Positioned(
                              top: 44,
                              right: 44,
                              child: AnimatedBuilder(
                                animation: _dotsController,
                                builder: (_, __) => Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF9D61C),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF9D61C).withValues(alpha: 0.6 * _dotsController.value),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  FadeTransition(
                    opacity: _fadeText,
                    child: AnimatedBuilder(
                      animation: _slideUp,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: child,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: const Color(0xFFE8F5E9),
                            shadows: [
                              Shadow(color: _primaryNeon.withValues(alpha: 0.35), blurRadius: 30)
                            ],
                          ),
                          children: [
                            const TextSpan(text: 'Pak'),
                            TextSpan(
                              text: 'Fasal',
                              style: TextStyle(color: _primaryNeon),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  FadeTransition(
                    opacity: _fadeTagline,
                    child: AnimatedBuilder(
                      animation: _slideUp,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: child,
                      ),
                      child: Text(
                        'SMART FARMING · PAKISTAN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFFA0D2A0).withValues(alpha: 0.75),
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Thin divider line
                  FadeTransition(
                    opacity: _fadeTagline,
                    child: AnimatedBuilder(
                      animation: _slideUp,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: child,
                      ),
                      child: Container(
                        width: 40,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              _primaryNeon.withValues(alpha: 0.5),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Animated loading dots
                  FadeTransition(
                    opacity: _fadeTagline,
                    child: _AnimatedDots(controller: _dotsController, color: _primaryNeon),
                  ),
                ],
              ),
            ),
          ),

          // ── Version Tag ──────────────────────────────────────────
          Positioned(
            bottom: 122,
            left: 0,
            right: 0,
            child: Text(
              'v2.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: _primaryNeon.withValues(alpha: 0.35),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper classes & widgets ─────────────────────────────────────────────────

class _Particle {
  _Particle({required this.x, required this.y, required this.speed, required this.size, required this.opacity});
  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress, required this.color});
  final List<_Particle> particles;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Calculate continuous upward movement
      final currentY = (p.y - (progress * p.speed)) % 1.0;
      // Fade out at the very top
      final currentOpacity = currentY < 0.1 ? (currentY / 0.1) * p.opacity : p.opacity;

      final paint = Paint()
        ..color = color.withValues(alpha: currentOpacity < 0 ? 0 : currentOpacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(p.x * size.width, (currentY < 0 ? 1.0 + currentY : currentY) * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller, required this.color});
  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final delay = i * 0.20;
        final anim = Tween<double>(begin: 0.0, end: -7.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay.clamp(0.0, 1.0),
              (delay + 0.60).clamp(0.0, 1.0),
              curve: Curves.easeInOut,
            ),
          ),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, anim.value),
            child: Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 
                  0.4 + 0.5 * ((anim.value.abs()) / 7),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Custom painters ───────────────────────────────────────────────────────────

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.48, 0.5, 0.52, 1.0],
      ).createShader(
        Rect.fromLTWH(x - size.width * 0.5, 0, size.width, size.height),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

class _WheatPainter extends CustomPainter {
  _WheatPainter({required this.sway, required this.color});
  final double sway;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const count = 16;
    final spacing = size.width / count;

    for (int i = 0; i < count; i++) {
      final baseX = spacing * i + spacing / 2;
      final baseY = size.height;
      // Stagger heights
      final h = 50.0 + (i % 3) * 18.0;
      final swayOffset = sway * 4 * math.sin(i * 0.9);

      final tipX = baseX + swayOffset;
      final tipY = baseY - h;

      // Stalk
      final path = Path()
        ..moveTo(baseX, baseY)
        ..quadraticBezierTo(
          baseX + swayOffset * 0.5,
          baseY - h * 0.55,
          tipX,
          tipY,
        );
      canvas.drawPath(path, paint);

      // Grain head
      canvas.save();
      canvas.translate(tipX, tipY);
      canvas.rotate(swayOffset * 0.04);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 7, height: 14),
        headPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WheatPainter old) =>
      old.sway != sway || old.color != color;
}