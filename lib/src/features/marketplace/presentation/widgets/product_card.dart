import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
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
    this.onContactTap,
  });

  final Product product;
  final String languageCode;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onContactTap;

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
    final phone = widget.product.primaryPhone;

    final cardBg = isDark ? AppColors.darkSurfaceMid : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF152018);
    final muted = isDark ? Colors.white70 : const Color(0xFF6B7A6E);
    final divider =
        isDark ? Colors.white12 : const Color(0xFFE8EEE8);
    final favBg =
        isDark ? AppColors.darkSurfaceHigh : const Color(0xFFF3F6F3);
    final priceColor =
        isDark ? AppColors.lightGreen : const Color(0xFF1B5E20);
    final phoneBg = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.22)
        : const Color(0xFFE7F6EA);
    final phoneBorder = isDark
        ? AppColors.lightGreen.withValues(alpha: 0.35)
        : const Color(0xFFC8E6C9);
    final cropBg = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.22)
        : const Color(0xFFE7F6EA);
    final cropFg =
        isDark ? AppColors.lightGreen : const Color(0xFF1B5E20);
    final catBg = isDark
        ? const Color(0xFFB45309).withValues(alpha: 0.25)
        : const Color(0xFFFFF1E6);
    final catFg =
        isDark ? const Color(0xFFFFCC80) : const Color(0xFFB45309);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        color: cardBg,
        elevation: _pressed ? 1.5 : 4,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 88,
                          height: 112,
                          child: widget.product.hasImage
                              ? Image.network(
                                  widget.product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _ImageFallback(isDark: isDark),
                                )
                              : _ImageFallback(isDark: isDark),
                        ),
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
                              Material(
                                color: favBg,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: widget.onFavoriteTap,
                                  child: Padding(
                                    padding: const EdgeInsets.all(7),
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
                                        size: 18,
                                        color: widget.isFavorite
                                            ? AppColors.error
                                            : muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (widget.product.company.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.product.company,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: muted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            children: [
                              if (cropLabel.isNotEmpty)
                                _TagPill(
                                  label: cropLabel,
                                  icon: Icons.eco_rounded,
                                  bg: cropBg,
                                  fg: cropFg,
                                ),
                              if (categoryLabel.isNotEmpty)
                                _TagPill(
                                  label: categoryLabel,
                                  icon: Icons.science_outlined,
                                  bg: catBg,
                                  fg: catFg,
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
                                height: 1.4,
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
                Divider(height: 1, color: divider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      widget.product.priceLabel(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: priceColor,
                      ),
                    ),
                    if (phone != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: phoneBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: phoneBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: priceColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: priceColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    if (phone != null)
                      Material(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(20),
                        elevation: 1,
                        shadowColor: const Color(0xFF1B5E20)
                            .withValues(alpha: 0.35),
                        child: InkWell(
                          onTap: widget.onContactTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l10n.t('marketContact'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
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
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
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
