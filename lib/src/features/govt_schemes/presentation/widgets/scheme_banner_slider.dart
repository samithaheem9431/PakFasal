import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/govt_scheme.dart';

class SchemeBannerSlider extends StatefulWidget {
  const SchemeBannerSlider({
    super.key,
    required this.schemes,
    required this.onTap,
  });

  final List<GovtScheme> schemes;
  final ValueChanged<GovtScheme> onTap;

  @override
  State<SchemeBannerSlider> createState() => _SchemeBannerSliderState();
}

class _SchemeBannerSliderState extends State<SchemeBannerSlider> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  List<GovtScheme> get _imageSchemes =>
      widget.schemes.where((s) => s.hasImage).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(covariant SchemeBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schemes.length != widget.schemes.length) {
      _autoSlideTimer?.cancel();
      _currentPage = 0;
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    final count = _imageSchemes.length;
    if (count <= 1) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % count;
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
    final schemes = _imageSchemes;
    if (schemes.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _pageController,
            itemCount: schemes.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = schemes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _BannerImageCard(
                  imageUrl: item.imageUrl,
                  onTap: () => widget.onTap(item),
                ),
              );
            },
          ),
        ),
        if (schemes.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(schemes.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerImageCard extends StatelessWidget {
  const _BannerImageCard({
    required this.imageUrl,
    required this.onTap,
  });

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.paleGreen,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => const ColoredBox(
                color: AppColors.paleGreen,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => const ColoredBox(
                color: AppColors.paleGreen,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primaryGreen,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
