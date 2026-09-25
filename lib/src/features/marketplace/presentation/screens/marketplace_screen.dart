import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/marketplace_labels.dart';
import '../../domain/entities/product.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarketplaceProvider(),
      child: const _MarketplaceView(),
    );
  }
}

class _MarketplaceView extends StatefulWidget {
  const _MarketplaceView();

  @override
  State<_MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<_MarketplaceView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
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

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang =
        context.watch<LocalizationController>().locale.languageCode;
    final provider = context.watch<MarketplaceProvider>();
    final products = provider.filteredProducts;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = context.isCompact ? 14.0 : 18.0;

    return PakFasalScaffold(
      title: l10n.t('marketplace'),
      child: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () => provider.load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: PakFasalFloatingBottomBar.scrollPadding(
            context,
            left: hPad,
            top: 12,
            right: hPad,
            bottom: 20,
          ),
          children: [
            TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkText,
              ),
              decoration: InputDecoration(
                hintText: l10n.t('marketSearchHint'),
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : AppColors.mutedText,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white70 : AppColors.mutedText,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceMid
                    : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white24
                        : const Color(0xFFD5DED5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white24
                        : const Color(0xFFD5DED5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.lightGreen
                        : AppColors.primaryGreen,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _FilterScenicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    icon: Icons.eco,
                    label: l10n.t('marketSelectCrop'),
                    hint: l10n.t('marketSelectCropHint'),
                    onImage: true,
                  ),
                  const SizedBox(height: 10),
                  _FilterChipRow(
                    allLabel: l10n.t('marketAllCrops'),
                    selected: provider.selectedCrop,
                    values: provider.crops,
                    labelOf: (slug) => MarketplaceLabels.crop(slug, lang),
                    iconOf: _cropIcon,
                    iconColorOf: _cropIconColor,
                    onSelect: provider.setCrop,
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel(
                    icon: Icons.science_outlined,
                    label: l10n.t('marketSelectCategory'),
                    hint: l10n.t('marketSelectCategoryHint'),
                    onImage: true,
                  ),
                  const SizedBox(height: 10),
                  _FilterChipRow(
                    allLabel: l10n.t('marketAllCategories'),
                    selected: provider.selectedCategory,
                    values: provider.categories,
                    labelOf: (slug) =>
                        MarketplaceLabels.category(slug, lang),
                    iconOf: _categoryIcon,
                    iconColorOf: (_) => AppColors.primaryGreen,
                    onSelect: provider.setCategory,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionLabel(
              icon: Icons.apartment_outlined,
              label: l10n.t('marketFilterCompany'),
            ),
            const SizedBox(height: 8),
            _CompanyDropdown(
              value: provider.selectedCompany,
              companies: provider.companies,
              allLabel: l10n.t('marketAllCompanies'),
              onChanged: provider.setCompany,
            ),
            const SizedBox(height: 10),
            const BannerAdWidget(
              padding: EdgeInsets.symmetric(vertical: 4),
            ),
            const SizedBox(height: 8),
            if (provider.isLoading && provider.allProducts.isEmpty)
              const LoadingStateCard()
            else if (provider.hasError && provider.allProducts.isEmpty)
              ErrorStateCard(
                onRetry: () => provider.load(forceRefresh: true),
              )
            else if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    provider.allProducts.isEmpty
                        ? l10n.t('marketEmpty')
                        : l10n.t('marketNoProducts'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.mutedText,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(products.length, (index) {
                final product = products[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == products.length - 1 ? 0 : 12,
                  ),
                  child: ProductCard(
                    product: product,
                    languageCode: lang,
                    isFavorite: provider.isFavorite(product.id),
                    onFavoriteTap: () =>
                        provider.toggleFavorite(product.id),
                    onTap: () => _openDetail(product),
                    onContactTap: product.primaryPhone == null
                        ? null
                        : () => _callPhone(context, product.primaryPhone!),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static IconData _cropIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'wheat':
        return Icons.grass;
      case 'rice':
        return Icons.spa_outlined;
      case 'cotton':
        return Icons.local_florist_outlined;
      default:
        return Icons.eco_outlined;
    }
  }

  static Color _cropIconColor(String slug) {
    switch (slug.toLowerCase()) {
      case 'wheat':
        return const Color(0xFFC47A1A);
      case 'rice':
        return const Color(0xFF2E7D32);
      case 'cotton':
        return const Color(0xFF43A047);
      default:
        return AppColors.primaryGreen;
    }
  }

  static IconData _categoryIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'fungicides':
        return Icons.science_outlined;
      case 'herbicides':
        return Icons.compost_outlined;
      case 'insecticides':
        return Icons.bug_report_outlined;
      case 'seedcare':
        return Icons.agriculture_outlined;
      case 'specialty-nutrition':
        return Icons.water_drop_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _FilterScenicCard extends StatelessWidget {
  const _FilterScenicCard({required this.child});

  final Widget child;

  static const _fieldAsset =
      'assets/images/marketplace/filter_crops_light.png';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.16),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _fieldAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: isDark
                    ? AppColors.darkSurfaceMid
                    : const Color(0xFFC8E6C9),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFF0A160E).withValues(alpha: 0.78),
                          const Color(0xFF102017).withValues(alpha: 0.72),
                          const Color(0xFF1B5E20).withValues(alpha: 0.55),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.38),
                          const Color(0xFF1B5E20).withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.22),
                        ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.label,
    this.hint,
    this.onImage = false,
  });

  final IconData icon;
  final String label;
  final String? hint;
  /// When true, label sits on the crop filter image (use light text in dark).
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // On light image card in light mode keep dark text.
    final titleColor = onImage
        ? (isDark ? Colors.white : const Color(0xFF1B2E20))
        : (isDark ? Colors.white : const Color(0xFF1B2E20));
    final hintColor = onImage
        ? (isDark
            ? Colors.white.withValues(alpha: 0.78)
            : const Color(0xFF5A6B5E))
        : (isDark ? Colors.white70 : const Color(0xFF5A6B5E));
    final iconColor = isDark && onImage
        ? const Color(0xFF81C784)
        : AppColors.primaryGreen;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              if (hint != null && hint!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  hint!,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: hintColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.allLabel,
    required this.selected,
    required this.values,
    required this.labelOf,
    required this.iconOf,
    required this.iconColorOf,
    required this.onSelect,
  });

  final String allLabel;
  final String? selected;
  final List<String> values;
  final String Function(String slug) labelOf;
  final IconData Function(String slug) iconOf;
  final Color Function(String slug) iconColorOf;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _MarketChip(
              label: allLabel,
              selected: selected == null,
              leading: selected == null
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
              onTap: () => onSelect(null),
            ),
          ),
          ...values.map((value) {
            final selectedChip = selected == value;
            final tint = iconColorOf(value);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _MarketChip(
                label: labelOf(value),
                selected: selectedChip,
                leading: Icon(
                  iconOf(value),
                  size: 15,
                  color: selectedChip ? Colors.white : tint,
                ),
                onTap: () => onSelect(value),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MarketChip extends StatelessWidget {
  const _MarketChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg =
        isDark ? AppColors.darkSurfaceHigh : Colors.white;
    final unselectedBorder =
        isDark ? Colors.white24 : const Color(0xFFD5DED5);
    final unselectedText =
        isDark ? Colors.white : const Color(0xFF223028);

    return Material(
      color: selected ? const Color(0xFF1B5E20) : unselectedBg,
      elevation: selected ? 2 : 0,
      shadowColor: const Color(0xFF1B5E20).withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? const Color(0xFF1B5E20) : unselectedBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : unselectedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyDropdown extends StatelessWidget {
  const _CompanyDropdown({
    required this.value,
    required this.companies,
    required this.allLabel,
    required this.onChanged,
  });

  final String? value;
  final List<String> companies;
  final String allLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurfaceMid : Colors.white;
    final border =
        isDark ? Colors.white24 : const Color(0xFFD5DED5);
    final fg = isDark ? Colors.white : const Color(0xFF223028);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF5A6B5E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          dropdownColor: bg,
          borderRadius: BorderRadius.circular(14),
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: iconColor,
          ),
          hint: Text(
            allLabel,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                allLabel,
                style: TextStyle(fontWeight: FontWeight.w600, color: fg),
              ),
            ),
            ...companies.map(
              (company) => DropdownMenuItem<String?>(
                value: company,
                child: Text(company, style: TextStyle(color: fg)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
