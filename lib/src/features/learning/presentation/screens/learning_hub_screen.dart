import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import 'crop_selection_screen.dart';
import 'learning_articles_screen.dart';
import 'learning_screen.dart';

/// Learning Hub Screen - Main entry point for all learning content
/// Matches the exact design from the reference screenshot
class LearningHubScreen extends StatelessWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return PakFasalScaffold(
      title: l10n.t('learning'),
      showBottomNavigation: true,
      child: Container(
        color: isDark ? scheme.surface : const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Banner Section
            _BannerSection(),
            
            const SizedBox(height: 20),
            
            // Topics Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.t('learningTopicsLabel'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Topic Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // First Row - Learning Videos and Articles
                  Row(
                    children: [
                      Expanded(
                        child: _TopicCard(
                          title: l10n.t('learningOptionYoutube'),
                          subtitle: l10n.t('learningOptionYoutubeDesc'),
                          icon: Icons.play_circle_filled,
                          iconColor: const Color(0xFF2E7D32),
                          imagePlaceholder: _buildFarmerWithTabletImage(),
                          hasPlayButton: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LearningScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TopicCard(
                          title: l10n.t('learningOptionArticles'),
                          subtitle: l10n.t('learningOptionArticlesDesc'),
                          icon: Icons.article,
                          iconColor: const Color(0xFF2196F3),
                          imagePlaceholder: _buildFarmerReadingImage(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LearningArticlesScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Second Row - Pests & Diseases (full width)
                  _TopicCard(
                    title: l10n.t('learningOptionPests'),
                    subtitle: l10n.t('learningOptionPestsDesc'),
                    icon: Icons.bug_report,
                    iconColor: const Color(0xFFFFA726),
                    imagePlaceholder: _buildPestDiseaseImage(),
                    isFullWidth: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CropSelectionScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Banner
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? scheme.surfaceContainerHighest : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.t('learningTipBoldPrefix'),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: l10n.t('learningTipRest'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.spa,
                      size: 24,
                      color: scheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Build farmer with tablet image
  static Widget _buildFarmerWithTabletImage() {
    return Image.asset(
      'assets/images/learning/farmer_tablet.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF2E7D32),
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white, size: 40),
          ),
        );
      },
    );
  }

  // Build farmer reading image
  static Widget _buildFarmerReadingImage() {
    return Image.asset(
      'assets/images/learning/farmer_reading.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF1976D2),
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white, size: 40),
          ),
        );
      },
    );
  }

  // Build pest disease image
  static Widget _buildPestDiseaseImage() {
    return Image.asset(
      'assets/images/learning/pest_disease.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF558B2F),
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white, size: 40),
          ),
        );
      },
    );
  }
}

// Banner Section Widget — auto-sliding carousel (same height as before)
class _BannerSection extends StatefulWidget {
  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  static const _aspectRatio = 1024 / 512;
  static const _slides = <String>[
    'assets/images/learning/banner_full.jpg',
    'assets/images/learning/banner_slide_1.jpg',
    'assets/images/learning/banner_slide_2.jpg',
    'assets/images/learning/banner_slide_3.jpg',
  ];

  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? scheme.surfaceContainerHighest : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    _slides[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark
                            ? scheme.surfaceContainerHighest
                            : Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.t('learningHubEyebrow').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurfaceVariant,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.t('learningHeadlineQuestion'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.t('learningDashboardHint'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Topic Card Widget
class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget imagePlaceholder;
  final VoidCallback onTap;
  final bool isFullWidth;
  final bool hasPlayButton;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.imagePlaceholder,
    required this.onTap,
    this.isFullWidth = false,
    this.hasPlayButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? scheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: AspectRatio(
                    // Higher ratio = shorter image; half-width cards (videos/articles) stay compact
                    aspectRatio: isFullWidth ? 2.5 : 1.55,
                    child: imagePlaceholder,
                  ),
                ),
                if (hasPlayButton)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content Section
            Padding(
              padding: EdgeInsets.all(isFullWidth ? 12 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and Title Row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isFullWidth ? 8 : 6),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: isFullWidth ? 18 : 16,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isFullWidth ? 14 : 13,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: isFullWidth ? null : 2,
                              overflow: isFullWidth
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isFullWidth ? 11 : 10,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isFullWidth ? 10 : 8),
                  
                  // Available Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context).t('learningStatusAvailable'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
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

