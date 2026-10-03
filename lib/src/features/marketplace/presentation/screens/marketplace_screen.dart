import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(MarketplaceProvider provider, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      provider.setSearchQuery(value);
    });
  }

  void _clearFilters(MarketplaceProvider provider) {
    _searchDebounce?.cancel();
    _searchController.clear();
    provider.clearFilters();
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
    final products = provider.pagedProducts;
    final totalCount = provider.totalFilteredCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = context.isCompact ? 14.0 : 18.0;
    final topInset = MediaQuery.paddingOf(context).top;

    return PakFasalScaffold(
      title: l10n.t('marketplace'),
      transparentChrome: true,
      backgroundColor:
          isDark ? AppColors.darkSurface : const Color(0xFFF4F7F4),
      child: RefreshIndicator(
        color: AppColors.primaryGreen,
        edgeOffset: topInset + 56,
        onRefresh: () => provider.load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: PakFasalFloatingBottomBar.scrollPadding(
            context,
            bottom: 20,
          ),
          children: [
            _MarketplaceHeroHeader(
              topInset: topInset,
              horizontalPadding: hPad,
              searchController: _searchController,
              onSearchChanged: (value) => _onSearchChanged(provider, value),
              onClearSearch: () {
                _searchDebounce?.cancel();
                _searchController.clear();
                provider.setSearchQuery('');
              },
              hint: l10n.t('marketSearchHint'),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.showingStaleCache ||
                      provider.isRefreshingInBackground)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StatusBanner(
                        icon: provider.isRefreshingInBackground
                            ? Icons.sync_rounded
                            : Icons.cloud_off_outlined,
                        message: provider.isRefreshingInBackground
                            ? l10n.t('marketUpdating')
                            : l10n.t('marketOfflineCached'),
                      ),
                    ),
                  _FilterSectionHeader(
                    title: l10n.t('marketSelectCrop'),
                    hint: l10n.t('marketSelectCropHint'),
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
                  const SizedBox(height: 18),
                  _FilterSectionHeader(
                    title: l10n.t('marketSelectCategory'),
                    hint: l10n.t('marketSelectCategoryHint'),
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown<String?>(
                          icon: Icons.apartment_outlined,
                          value: _dropdownValue(
                            provider.selectedCompany,
                            provider.companies,
                          ),
                          hint: l10n.t('marketAllCompanies'),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(l10n.t('marketAllCompanies')),
                            ),
                            ...provider.companies.map(
                              (company) => DropdownMenuItem<String?>(
                                value: company,
                                child: Text(company),
                              ),
                            ),
                          ],
                          onChanged: provider.setCompany,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterDropdown<MarketplaceSort>(
                          icon: Icons.sort_rounded,
                          value: provider.sort,
                          hint: l10n.t('marketSortRelevant'),
                          items: [
                            DropdownMenuItem(
                              value: MarketplaceSort.relevant,
                              child: Text(l10n.t('marketSortRelevant')),
                            ),
                            DropdownMenuItem(
                              value: MarketplaceSort.priceLow,
                              child: Text(l10n.t('marketSortPriceLow')),
                            ),
                            DropdownMenuItem(
                              value: MarketplaceSort.priceHigh,
                              child: Text(l10n.t('marketSortPriceHigh')),
                            ),
                            DropdownMenuItem(
                              value: MarketplaceSort.name,
                              child: Text(l10n.t('marketSortName')),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) provider.setSort(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (provider.hasActiveFilters) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => _clearFilters(provider),
                        icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                        label: Text(l10n.t('marketClearFilters')),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const BannerAdWidget(
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  const SizedBox(height: 8),
                  if (provider.isLoading && provider.allProducts.isEmpty)
                    const AppListSkeleton(itemCount: 5, itemHeight: 120)
                  else if (provider.hasError && provider.allProducts.isEmpty)
                    ErrorStateCard(
                      onRetry: () => provider.load(forceRefresh: true),
                    )
                  else if (totalCount == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              provider.allProducts.isEmpty
                                  ? l10n.t('marketEmpty')
                                  : l10n.t('marketNoProducts'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.mutedText,
                                fontSize: 15,
                              ),
                            ),
                            if (provider.hasActiveFilters &&
                                provider.allProducts.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => _clearFilters(provider),
                                child: Text(l10n.t('marketClearFilters')),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.t('marketAvailableProducts'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF152018),
                            ),
                          ),
                        ),
                        Text(
                          l10n.t(
                            'marketProductsCount',
                            params: {'count': totalCount},
                          ),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.lightGreen
                                : AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.t('marketProductsSubtitle'),
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6B7A6E),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        ),
                      );
                    }),
                    if (provider.totalPages > 1) ...[
                      const SizedBox(height: 16),
                      _PaginationBar(
                        hasPrevious: provider.hasPreviousPage,
                        hasNext: provider.hasNextPage,
                        onPrevious: provider.previousPage,
                        onNext: provider.nextPage,
                        previousLabel: l10n.t('marketPreviousPage'),
                        nextLabel: l10n.t('marketNextPage'),
                        pageLabel: l10n.t(
                          'marketPageOf',
                          params: {
                            'page': provider.pageNumber,
                            'total': provider.totalPages,
                          },
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
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

  /// Keeps DropdownButton happy when the selected company is temporarily
  /// outside the cascaded facet list (e.g. mid-refresh).
  static String? _dropdownValue(String? selected, List<String> options) {
    if (selected == null) return null;
    for (final option in options) {
      if (option.toLowerCase() == selected.toLowerCase()) return option;
    }
    return null;
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

class _MarketplaceHeroHeader extends StatelessWidget {
  const _MarketplaceHeroHeader({
    required this.topInset,
    required this.horizontalPadding,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.hint,
  });

  final double topInset;
  final double horizontalPadding;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String hint;

  static const _headerAsset =
      'assets/images/marketplace/header_banner.jpg';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: topInset + 60 + 78,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _headerAsset,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.2),
            cacheWidth: (MediaQuery.sizeOf(context).width *
                    MediaQuery.devicePixelRatioOf(context))
                .round()
                .clamp(480, 1400),
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => Container(
              color: isDark
                  ? AppColors.darkSurfaceMid
                  : const Color(0xFF1B5E20),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.28),
                  Colors.black.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 16,
            child: Material(
              color: Colors.white,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(28),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.mutedText,
                      ),
                      suffixIcon: hasText
                          ? IconButton(
                              tooltip: 'Clear',
                              onPressed: onClearSearch,
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.mutedText,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceHigh
            : const Color(0xFFE8F2E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : const Color(0xFFC5D9C7),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: isDark ? Colors.white70 : const Color(0xFF2E4A33),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.previousLabel,
    required this.nextLabel,
    required this.pageLabel,
  });

  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String previousLabel;
  final String nextLabel;
  final String pageLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurfaceMid : Colors.white;
    final border = isDark ? Colors.white24 : const Color(0xFFD5DED5);
    final fg = isDark ? Colors.white : const Color(0xFF223028);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: hasPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            label: Text(previousLabel),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              disabledForegroundColor:
                  isDark ? Colors.white38 : const Color(0xFFA0ADA4),
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            child: Text(
              pageLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
          TextButton(
            onPressed: hasNext ? onNext : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              disabledForegroundColor:
                  isDark ? Colors.white38 : const Color(0xFFA0ADA4),
              visualDensity: VisualDensity.compact,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(nextLabel),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSectionHeader extends StatelessWidget {
  const _FilterSectionHeader({
    required this.title,
    required this.hint,
  });

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B2E20);
    final hintColor =
        isDark ? Colors.white60 : const Color(0xFF5A6B5E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: TextStyle(
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: hintColor,
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
              leading: Icon(
                Icons.eco_rounded,
                size: 15,
                color: selected == null
                    ? Colors.white
                    : AppColors.primaryGreen,
              ),
              onTap: () => onSelect(null),
            ),
          ),
          ...values.map((value) {
            final current = selected;
            final selectedChip = current != null &&
                current.toLowerCase() == value.toLowerCase();
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
                onTap: () => onSelect(selectedChip ? null : value),
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

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.icon,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurfaceMid : Colors.white;
    final border = isDark ? Colors.white24 : const Color(0xFFD5DED5);
    final fg = isDark ? Colors.white : const Color(0xFF223028);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF5A6B5E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
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
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: bg,
          borderRadius: BorderRadius.circular(14),
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: iconColor,
          ),
          hint: Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Row(
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      child: item.child,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
