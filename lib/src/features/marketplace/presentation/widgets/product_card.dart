import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/performance/device_performance.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/marketplace_image_cache.dart';
import '../../data/marketplace_labels.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.languageCode,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Product product;
  final String languageCode;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = widget.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.product.title(lang);
    final description = widget.product.description(lang);
    final cropLabel = MarketplaceLabels.crop(widget.product.crop, lang);
    final categoryLabel =
        MarketplaceLabels.category(widget.product.category, lang);

    final cardBg = isDark ? AppColors.darkSurfaceMid : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF152018);
    final muted = isDark ? Colors.white70 : const Color(0xFF6B7A6E);
    final companyColor =
        isDark ? Colors.white60 : const Color(0xFF5A6B5E);
    final priceBg = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.22)
        : const Color(0xFFE7F6EA);
    final priceFg =
        isDark ? AppColors.lightGreen : const Color(0xFF1B5E20);
    final cropBg = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.22)
        : const Color(0xFFE7F6EA);
    final cropFg =
        isDark ? AppColors.lightGreen : const Color(0xFF1B5E20);
    final catBg = isDark
        ? const Color(0xFFC62828).withValues(alpha: 0.22)
        : const Color(0xFFFFEBEE);
    final catFg =
        isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        color: cardBg,
        elevation: _pressed ? 1.5 : 3,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 92,
                        height: 108,
                        child: widget.product.hasImage
                            ? CachedNetworkImage(
                                imageUrl: MarketplaceImageCache.thumbUrl(
                                  widget.product.imageUrl,
                                ),
                                cacheManager: MarketplaceImageCache.manager,
                                fit: BoxFit.cover,
                                memCacheWidth:
                                    DevicePerformance.isLowEnd ? 160 : 240,
                                fadeInDuration:
                                    const Duration(milliseconds: 180),
                                fadeOutDuration:
                                    const Duration(milliseconds: 100),
                                placeholder: (_, __) =>
                                    _ImageFallback(isDark: isDark),
                                errorWidget: (_, __, ___) =>
                                    _ImageFallback(isDark: isDark),
                              )
                            : _ImageFallback(isDark: isDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                    letterSpacing: -0.2,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                customBorder: const CircleBorder(),
                                onTap: widget.onFavoriteTap,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 220),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                    child: Icon(
                                      widget.isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      key: ValueKey(widget.isFavorite),
                                      size: 20,
                                      color: widget.isFavorite
                                          ? AppColors.error
                                          : muted,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.product.company.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.product.company,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: companyColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            children: [
                              if (categoryLabel.isNotEmpty)
                                _TagPill(
                                  label: categoryLabel,
                                  bg: catBg,
                                  fg: catFg,
                                ),
                              if (cropLabel.isNotEmpty)
                                _TagPill(
                                  label: cropLabel,
                                  bg: cropBg,
                                  fg: cropFg,
                                ),
                            ],
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: priceBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.product.priceLabel(),
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: priceFg,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.t('marketViewDetails'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark
          ? AppColors.primaryGreen.withValues(alpha: 0.2)
          : const Color(0xFFE8F5E9),
      child: Icon(
        Icons.agriculture_outlined,
        size: 36,
        color: isDark ? AppColors.lightGreen : const Color(0xFF1B5E20),
      ),
    );
  }
}
