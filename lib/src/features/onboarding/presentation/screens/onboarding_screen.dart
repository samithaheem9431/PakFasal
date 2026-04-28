import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  // Entry animation controller
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // ── SLIDE DEFINITIONS — only colors changed ──────────────────────────────
  static const _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      icon: Icons.wb_sunny_rounded,
      titleKey: 'onboardingTitle1',
      descriptionKey: 'onboardingDesc1',
      // Slide 1 · Forest green
      gradient: [Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
      iconColor: Color(0xFF2E7D32),
    ),
    _OnboardingSlide(
      icon: Icons.eco_rounded,
      titleKey: 'onboardingTitle2',
      descriptionKey: 'onboardingDesc2',
      // Slide 2 · Emerald teal-green
      gradient: [Color(0xFFE0F2F1), Color(0xFF80CBC4)],
      iconColor: Color(0xFF00695C),
    ),
    _OnboardingSlide(
      icon: Icons.insights_rounded,
      titleKey: 'onboardingTitle3',
      descriptionKey: 'onboardingDesc3',
      // Slide 3 · Lime yellow-green
      gradient: [Color(0xFFF9FBE7), Color(0xFFDCEDC8)],
      iconColor: Color(0xFF558B2F),
    ),
  ];
  // ────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // --- UNCHANGED LOGIC ---
  Future<void> _finishOnboarding() async {
    final box = Hive.box('app_preferences');
    await box.put('onboarding_seen', true);
    if (!mounted) return;

    final signedIn = context.read<AuthSessionController>().isSignedIn;
    Navigator.pushReplacementNamed(
      context,
      signedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  void _nextPage() {
    if (_currentPage == _slides.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );
  }
  // -----------------------

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isLast = _currentPage == _slides.length - 1;

    // Resolve the active slide's accent color for dots & button
    final activeColor = _slides[_currentPage].iconColor;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          // Background smoothly transitions between each slide's gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.6, 1.0],
            colors: [
              _slides[_currentPage].gradient[0],
              _slides[_currentPage].gradient[0].withOpacity(0.85),
              _slides[_currentPage].gradient[1],
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative background blobs ──────────────────────────────
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.05),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(0.06),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.05),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            // ─────────────────────────────────────────────────────────────

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Skip button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextButton(
                            onPressed: _finishOnboarding,
                            style: TextButton.styleFrom(
                              foregroundColor: activeColor,
                            ),
                            child: Text(
                              localizations.t('skip'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Parallax PageView
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (value) =>
                              setState(() => _currentPage = value),
                          itemCount: _slides.length,
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double pageOffset = 0.0;
                                if (_pageController.position.haveDimensions) {
                                  pageOffset = _pageController.page! - index;
                                }
                                return _OnboardingCard(
                                  slide: _slides[index],
                                  pageOffset: pageOffset,
                                  isActive: index == _currentPage,
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Bottom controls
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            // Elastic dot indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _slides.length,
                                    (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.elasticOut,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5),
                                  width: index == _currentPage ? 32 : 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    // Each dot uses the active slide's color
                                    color: index == _currentPage
                                        ? activeColor
                                        : activeColor.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Bouncy button — accent color per slide
                            _BouncyButton(
                              label: isLast
                                  ? localizations.t('getStarted')
                                  : localizations.t('next'),
                              onPressed: _nextPage,
                              // Slide 1: forest, Slide 2: emerald, Slide 3: lime
                              gradientColors: _slideButtonGradient(_currentPage),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the two-color button gradient for each slide index.
  static List<Color> _slideButtonGradient(int page) {
    switch (page) {
      case 0:
        return const [Color(0xFF66BB6A), Color(0xFF2E7D32)]; // Forest
      case 1:
        return const [Color(0xFF26A69A), Color(0xFF00695C)]; // Emerald
      case 2:
        return const [Color(0xFF9CCC65), Color(0xFF558B2F)]; // Lime
      default:
        return const [Color(0xFF66BB6A), Color(0xFF2E7D32)];
    }
  }
}

// ── Onboarding Card (glassmorphism, parallax) — unchanged logic ────────────
class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.slide,
    required this.pageOffset,
    required this.isActive,
  });

  final _OnboardingSlide slide;
  final double pageOffset;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    final scale = 1.0 - (pageOffset.abs() * 0.1).clamp(0.0, 0.1);

    return Transform.scale(
      scale: scale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: slide.iconColor.withOpacity(0.10),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(pageOffset * -120, 0),
                      child: _FloatingGraphic(slide: slide),
                    ),
                    const SizedBox(height: 48),
                    Transform.translate(
                      offset: Offset(pageOffset * 60, 0),
                      child: Text(
                        localizations.t(slide.titleKey),
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          // Title color = darkest stop of the slide's ramp
                          color: slide.iconColor,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: Offset(pageOffset * 30, 0),
                      child: Text(
                        localizations.t(slide.descriptionKey),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.black.withOpacity(0.65),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Floating animation graphic ─────────────────────────────────────────────
class _FloatingGraphic extends StatefulWidget {
  const _FloatingGraphic({required this.slide});
  final _OnboardingSlide slide;

  @override
  State<_FloatingGraphic> createState() => _FloatingGraphicState();
}

class _FloatingGraphicState extends State<_FloatingGraphic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -12.0, end: 12.0).animate(
      CurvedAnimation(
          parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.slide.gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.slide.iconColor.withOpacity(0.30),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 20,
              offset: const Offset(-10, -10),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.slide.icon,
            size: 80,
            color: widget.slide.iconColor,
          ),
        ),
      ),
    );
  }
}

// ── Slide data model — unchanged ───────────────────────────────────────────
class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.gradient,
    required this.iconColor,
  });

  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final List<Color> gradient;
  final Color iconColor;
}

// ── Bouncy button — gradient now passed in as param ────────────────────────
class _BouncyButton extends StatefulWidget {
  const _BouncyButton({
    required this.label,
    required this.onPressed,
    required this.gradientColors,
  });

  final String label;
  final VoidCallback onPressed;
  final List<Color> gradientColors;

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.last.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}