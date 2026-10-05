import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/marketplace_image_cache.dart';
import '../../data/marketplace_labels.dart';
import '../../domain/entities/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;

  Product get product => widget.product;

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('couldNotOpenDialer')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang =
        context.watch<LocalizationController>().locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = product.title(lang);
    final description = product.description(lang);
    final cropLabel = MarketplaceLabels.crop(product.crop, lang);
    final categoryLabel = MarketplaceLabels.category(product.category, lang);
    final phone = product.primaryPhone;

    final pageBg =
        isDark ? AppColors.darkSurface : const Color(0xFFF4F7F4);
    final cardBg = isDark ? AppColors.darkSurfaceMid : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF152018);
    final muted = isDark ? Colors.white70 : const Color(0xFF6B7A6E);
    final border =
        isDark ? Colors.white12 : const Color(0xFFE2EAE2);

    final images = product.images
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return PakFasalScaffold(
      title: l10n.t('marketDetail'),
      backgroundColor: pageBg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _ImageGallery(
            images: images,
            index: _imageIndex,
            onPageChanged: (i) => setState(() => _imageIndex = i),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.3,
              color: titleColor,
            ),
          ),
          if (product.company.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    product.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Color(0xFF2E7D32),
                ),
              ],
            ),
          ],
          if (categoryLabel.isNotEmpty || cropLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (categoryLabel.isNotEmpty)
                  _TagChip(
                    label: categoryLabel,
                    bg: isDark
                        ? const Color(0xFFC62828).withValues(alpha: 0.22)
                        : const Color(0xFFFFEBEE),
                    fg: isDark
                        ? const Color(0xFFEF9A9A)
                        : const Color(0xFFC62828),
                  ),
                if (cropLabel.isNotEmpty)
                  _TagChip(
                    label: cropLabel,
                    bg: isDark
                        ? AppColors.primaryGreen.withValues(alpha: 0.22)
                        : const Color(0xFFE7F6EA),
                    fg: isDark
                        ? AppColors.lightGreen
                        : const Color(0xFF1B5E20),
                    icon: Icons.eco_rounded,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryGreen.withValues(alpha: 0.22)
                  : const Color(0xFFE7F6EA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.lightGreen.withValues(alpha: 0.25)
                    : const Color(0xFFC8E6C9),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.lightGreen
                      : AppColors.primaryGreen,
                ),
                const SizedBox(width: 10),
                Text(
                  product.priceLabel(),
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.lightGreen
                        : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 18),
            _SectionCard(
              cardBg: cardBg,
              border: border,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('marketAboutProduct'),
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (product.sku.isNotEmpty ||
              phone != null ||
              product.company.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionCard(
              cardBg: cardBg,
              border: border,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('marketProductInfo'),
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (product.company.isNotEmpty)
                    _InfoRow(
                      icon: Icons.apartment_outlined,
                      label: l10n.t('marketCompany'),
                      value: product.company,
                      isDark: isDark,
                    ),
                  if (product.sku.isNotEmpty)
                    _InfoRow(
                      icon: Icons.qr_code_2_rounded,
                      label: l10n.t('marketSku'),
                      value: product.sku,
                      isDark: isDark,
                    ),
                  if (categoryLabel.isNotEmpty)
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: l10n.t('marketCategory'),
                      value: categoryLabel,
                      isDark: isDark,
                    ),
                  if (cropLabel.isNotEmpty)
                    _InfoRow(
                      icon: Icons.eco_outlined,
                      label: l10n.t('marketCrop'),
                      value: cropLabel,
                      isDark: isDark,
                    ),
                  if (phone != null)
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: l10n.t('marketPhone'),
                      value: phone,
                      isDark: isDark,
                      isLast: true,
                      valueTextDirection: TextDirection.ltr,
                    ),
                ],
              ),
            ),
          ],
          if (phone != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _makePhoneCall(context, phone),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text(
                  l10n.t('callCompany'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor:
                      const Color(0xFF1B5E20).withValues(alpha: 0.35),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.index,
    required this.onPageChanged,
    required this.isDark,
  });

  final List<String> images;
  final int index;
  final ValueChanged<int> onPageChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: _ImageFallback(isDark: isDark),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) {
                return CachedNetworkImage(
                  imageUrl: MarketplaceImageCache.detailUrl(images[i]),
                  cacheManager: MarketplaceImageCache.manager,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  memCacheWidth: 900,
                  fadeInDuration: const Duration(milliseconds: 180),
                  placeholder: (_, __) => _ImageFallback(isDark: isDark),
                  errorWidget: (_, __, ___) =>
                      _ImageFallback(isDark: isDark),
                );
              },
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryGreen
                      : (isDark
                          ? Colors.white24
                          : const Color(0xFFC5D4C7)),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isDark
          ? AppColors.primaryGreen.withValues(alpha: 0.18)
          : const Color(0xFFE8F5E9),
      child: Center(
        child: Icon(
          Icons.agriculture_outlined,
          size: 56,
          color: isDark ? AppColors.lightGreen : const Color(0xFF1B5E20),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    required this.cardBg,
    required this.border,
    required this.isDark,
  });

  final Widget child;
  final Color cardBg;
  final Color border;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
    this.valueTextDirection,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;
  final TextDirection? valueTextDirection;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7A6E);
    final valueColor = isDark ? Colors.white : const Color(0xFF152018);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryGreen.withValues(alpha: 0.2)
                  : const Color(0xFFE7F6EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: isDark ? AppColors.lightGreen : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textDirection: valueTextDirection,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
